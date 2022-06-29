#!/usr/bin/env python3
# pylint: disable=logging-fstring-interpolation
'''
This script helps users pull data from known data streams, including
URLS and HPSS (only on supported NOAA platforms), or from user-supplied
data locations on disk.

Several supported data streams are included in
ush/templates/data_locations.yml, which provides locations and naming
conventions for files commonly used with the SRW App. Provide the file
to this tool via the --config flag. Users are welcome to provide their
own file with alternative locations and naming conventions.

When using this script to pull from disk, the user is required to
provide the path to the data location, which can include Python
templates. The file names follow those included in the --config file by
default, or can be user-supplied via the --file_name flag. That flag
takes a YAML-formatted string that follows the same conventions outlined
in the ush/templates/data_locations.yml file for naming files.

To see usage for this script:

    python retrieve_data.py -h

Also see the parse_args function below.
'''

import argparse
import datetime as dt
import logging
import os
import shutil
import subprocess
import sys
from textwrap import dedent


import yaml

def clean_up_output_dir(expected_subdir, local_archive, output_path, source_paths):

    ''' Remove expected sub-directories and existing_archive files on
    disk once all files have been extracted and put into the specified
    output location. '''

    unavailable = {}
    # Check to make sure the files exist on disk
    for file_path in source_paths:
        local_file_path = os.path.join(output_path, file_path.lstrip("/"))
        if not os.path.exists(local_file_path):
            logging.info(f'File does not exist: {local_file_path}')
            unavailable['hpss'] = source_paths
        else:
            file_name = os.path.basename(file_path)
            expected_output_loc = os.path.join(output_path, file_name)
            if not local_file_path == expected_output_loc:
                logging.info(f'Moving {local_file_path} to ' \
                             f'{expected_output_loc}')
                shutil.move(local_file_path, expected_output_loc)

    # Clean up directories from inside archive, if they exist
    if os.path.exists(expected_subdir) and expected_subdir != './':
        logging.info(f'Removing {expected_subdir}')
        os.removedirs(expected_subdir)

    # If an archive exists on disk, remove it
    if os.path.exists(local_archive):
        os.remove(local_archive)

    return unavailable

def copy_file(source, destination):

    '''
    Copy a file from a source and place it in the destination location.
    Return a boolean value reflecting the state of the copy.

    Assumes destination exists.
    '''

    if not os.path.exists(source):
        logging.info(f'File does not exist on disk \n {source}')
        return False

    # Using subprocess here because system copy is much faster than
    # python copy options.
    cmd = f'cp {source} {destination}'
    logging.info(f'Running command: \n {cmd}')
    try:
        subprocess.run(cmd,
            check=True,
            shell=True,
            )
    except subprocess.CalledProcessError as err:
        logging.info(err)
        return False
    return True

def download_file(url):

    '''
    Download a file from a url source, and place it in a target location
    on disk.

    Arguments:
      url          url to file to be downloaded

    Return:
      boolean value reflecting state of download.
    '''

    # wget flags:
    # -c continue previous attempt
    # -T timeout seconds
    # -t number of tries
    cmd = f'wget -c -T 30 -t 3 {url}'
    logging.info(f'Running command: \n {cmd}')
    try:
        subprocess.run(cmd,
            check=True,
            shell=True,
            )
    except subprocess.CalledProcessError as err:
        logging.info(err)
        return False
    except:
        logging.error('Command failed!')
        raise

    return True

def arg_list_to_range(args):

    '''
    Given an argparse list argument, return the sequence to process.

    The length of the list will determine what sequence items are returned:

      Length = 1:   A single item is to be processed
      Length = 2:   A sequence of start, stop with increment 1
      Length = 3:   A sequence of start, stop, increment
      Length > 3:   List as is

    argparse should provide a list of at least one item (nargs='+').

    Must ensure that the list contains integers.
    '''

    args = args if isinstance(args, list) else list(args)
    arg_len = len(args)
    if arg_len in (2, 3):
        args[1] += 1
        return list(range(*args))

    return args

def fill_template(template_str, cycle_date, templates_only=False, **kwargs):

    ''' Fill in the provided template string with date time information,
    and return the resulting string.

    Arguments:
      template_str    a string containing Python templates
      cycle_date      a datetime object that will be used to fill in
                      date and time information
      templates_only  boolean value. When True, this function will only
                      return the templates available.

    Keyword Args:
      ens_group       a number associated with a bin where ensemble
                      members are stored in archive files
      fcst_hr         an integer forecast hour. string formatting should
                      be included in the template_str
      mem             a single ensemble member. should be a positive integer value

    Return:
      filled template string
    '''

    # Parse keyword args
    ens_group = kwargs.get('ens_group')
    fcst_hr = kwargs.get('fcst_hr', 0)
    mem = kwargs.get('mem', '')
    # -----

    cycle_hour = cycle_date.strftime('%H')
    # One strategy for binning data files at NCEP is to put them into 6
    # cycle bins. The archive file names include the low and high end of the
    # range. Set the range as would be indicated in the archive file
    # here. Integer division is intentional here.
    low_end = int(cycle_hour) // 6 * 6
    bin6 = f'{low_end:02d}-{low_end+5:02d}'

    # Another strategy is to bundle odd cycle hours with their next
    # lowest even cycle hour. Files are named only with the even hour.
    # Integer division is intentional here.
    hh_even = f'{int(cycle_hour) // 2 * 2:02d}'

    format_values = dict(
        bin6=bin6,
        ens_group=ens_group,
        fcst_hr=fcst_hr,
        dd=cycle_date.strftime('%d'),
        hh=cycle_hour,
        hh_even=hh_even,
        jjj=cycle_date.strftime('%j'),
        mem=mem,
        mm=cycle_date.strftime('%m'),
        yy=cycle_date.strftime('%y'),
        yyyy=cycle_date.strftime('%Y'),
        yyyymm=cycle_date.strftime('%Y%m'),
        yyyymmdd=cycle_date.strftime('%Y%m%d'),
        yyyymmddhh=cycle_date.strftime('%Y%m%d%H'),
        )
    if templates_only:
        return f'{",".join((format_values.keys()))}'
    return template_str.format(**format_values)

def create_target_path(target_path):

    '''
    Append target path and create directory for ensemble members
    '''
    if not os.path.exists(target_path):
        os.makedirs(target_path)
    return target_path

def find_archive_files(paths, file_names, cycle_date, ens_group):

    ''' Given an equal-length set of archive paths and archive file
    names, and a cycle date, check HPSS via hsi to make sure at least
    one set exists. Return the path of the existing archive, along with
    the item in set of paths that was found.'''

    zipped_archive_file_paths = zip(paths, file_names)

    # Narrow down which HPSS files are available for this date
    for list_item, (archive_path, archive_file_names) in \
        enumerate(zipped_archive_file_paths):

        if not isinstance(archive_file_names, list):
            archive_file_names = [archive_file_names]

        # Only test the first item in the list, it will tell us if this
        # set exists at this date.
        file_path = os.path.join(archive_path, archive_file_names[0])
        file_path = fill_template(file_path, cycle_date, ens_group=ens_group)

        existing_archive = hsi_single_file(file_path)

        if existing_archive:
            logging.info(f'Found HPSS file: {file_path}')
            return existing_archive, list_item

    return '', 0

def get_requested_files(cla, file_templates, input_locs, method='disk',
        **kwargs):

    # pylint: disable=too-many-locals

    ''' This function copies files from disk locations
    or downloads files from a url, depending on the option specified for
    user.

    This function expects that the output directory exists and is
    writeable.

    Arguments:

    cla            Namespace object containing command line arguments
    file_templates a list of file templates
    input_locs      A string containing a single data location, either a url
                   or disk path, or a list of paths/urls.
    method         Choice of disk or download to indicate protocol for
                   retrieval

    Keyword args:
    members        a list integers corresponding to the ensemble members
    check_all      boolean flag that indicates all urls should be
                   checked for all files

    Returns:
    unavailable  a list of locations/files that were unretrievable
    '''

    members = kwargs.get('members', '')
    members = members if isinstance(members, list) else [members]

    check_all = kwargs.get('check_all', False)

    logging.info(f'Getting files named like {file_templates}')

    # Make sure we're dealing with lists for input locations and file
    # templates. Makes it easier to loop and zip.
    file_templates = file_templates if isinstance(file_templates, list) else \
        [file_templates]

    input_locs = input_locs if not isinstance(input_locs, list) else \
        [input_locs]

    orig_path = os.getcwd()
    unavailable = []

    locs_files = pair_locs_with_files(input_locs, file_templates, check_all)
    for mem in members:
        target_path = fill_template(cla.output_path,
                                    cla.cycle_date,
                                    mem=mem)
        target_path = create_target_path(target_path)

        logging.info(f'Retrieved files will be placed here: \n {target_path}')
        os.chdir(target_path)

        for fcst_hr in cla.fcst_hrs:
            for loc, templates in locs_files:

                templates = templates if isinstance(templates, list) \
                    else [templates]

                for template in templates:
                    input_loc = os.path.join(loc, template)
                    input_loc = fill_template(input_loc, cla.cycle_date, fcst_hr, mem=mem)
                    logging.debug(f'Full file path: {input_loc}')

                    if method == 'disk':
                        retrieved = copy_file(input_loc, target_path)

                    if method == 'download':
                        retrieved = download_file(input_loc)

                    if not retrieved:
                        unavailable.append(input_loc)
                        # Go on to the next location if the first file
                        # isn't found here.
                        break

    os.chdir(orig_path)
    return unavailable

def hsi_single_file(file_path, mode='ls'):

    ''' Call hsi as a subprocess for Python and return information about
    whether the file_path was found.

    Arguments:
        file_path    path on HPSS
        mode         the hsi command to run. ls is default. may also
                     pass "get" to retrieve the file path

    '''
    cmd = f'hsi {mode} {file_path}'

    logging.info(f'Running command \n {cmd}')
    try:
        subprocess.run(cmd,
                       check=True,
                       shell=True,
                       )
    except subprocess.CalledProcessError:
        logging.warning(f'{file_path} is not available!')
        return ''

    return file_path

def hpss_requested_files(cla, file_names, store_specs, members=-1,
        ens_group=-1):

    # pylint: disable=too-many-locals

    ''' This function interacts with the "hpss" protocol in a provided
    data store specs file to download a set of files requested by the
    user. Depending on the type of archive file (zip or tar), it will
    either pull the entire file and unzip it, or attempt to pull
    individual files from a tar file.

    It cleans up local disk after files are deemed available to remove
    any empty subdirectories that may still be present.

    This function exepcts that the output directory exists and is
    writable.
    '''
    members = [-1] if members == -1 else members

    archive_paths = store_specs['archive_path']
    archive_paths = archive_paths if isinstance(archive_paths, list) \
        else [archive_paths]

    # Could be a list of lists
    archive_file_names = store_specs.get('archive_file_names', {})
    if cla.file_type is not None:
        archive_file_names = archive_file_names[cla.file_type]

    if isinstance(archive_file_names, dict):
        archive_file_names = archive_file_names[cla.anl_or_fcst]

    unavailable = {}
    existing_archive = None

    logging.debug(f'Will try to look for: '\
            f' {list(zip(archive_paths, archive_file_names))}')

    existing_archive, which_archive = find_archive_files(archive_paths,
                                           archive_file_names,
                                           cla.cycle_date,
                                           ens_group=ens_group,
                                           )

    if not existing_archive:
        logging.warning('No archive files were found!')
        unavailable['archive'] = list(zip(archive_paths, archive_file_names))
        return unavailable

    logging.info(f'Files in archive are named: {file_names}')

    archive_internal_dirs = store_specs.get('archive_internal_dir', [''])
    if isinstance(archive_internal_dirs, dict):
        archive_internal_dirs = archive_internal_dirs.get(cla.anl_or_fcst, [''])


    # which_archive matters for choosing the correct file names within,
    # but we can safely just try all options for the
    # archive_internal_dir
    logging.debug(f'Checking archive number {which_archive} in list.')

    for archive_internal_dir_tmpl in archive_internal_dirs:
        archive_internal_dir = fill_template(archive_internal_dir_tmpl,
                                             cla.cycle_date)

        for mem in members:
            output_path = fill_template(cla.output_path, cla.cycle_date)
            logging.info(f'Will place files in {os.path.abspath(output_path)}')
            orig_path = os.getcwd()
            logging.debug(f'CWD: {os.getcwd()}')
            os.chdir(orig_path)

            if mem != -1:
                archive_internal_dir = fill_template(archive_internal_dir_tmpl,
                                                     cla.cycle_date,
                                                     mem=mem,
                                                     )
                output_path = create_target_path(output_path)
                logging.info(f'Will place files in {os.path.abspath(output_path)}')

            os.chdir(output_path)

            source_paths = []
            for fcst_hr in cla.fcst_hrs:
                for file_name in file_names:
                    source_paths.append(fill_template(
                        os.path.join(archive_internal_dir, file_name),
                        cla.cycle_date,
                        fcst_hr,
                        mem=mem,
                        ens_group=ens_group,
                        ))

            if store_specs.get('archive_format', 'tar') == 'zip':
                # Get the entire file from HPSS
                existing_archive = hsi_single_file(existing_archive, mode='get')

                # Grab only the necessary files from the archive
                cmd = f'unzip -o {os.path.basename(existing_archive)} {" ".join(source_paths)}'

            else:
                cmd = f'htar -xvf {existing_archive} {" ".join(source_paths)}'

            logging.info(f'Running command \n {cmd}')
            subprocess.run(cmd,
                           check=True,
                           shell=True,
                           )

            # Check that files exist and Remove any data transfer artifacts.
            unavailable = clean_up_output_dir(
                   expected_subdir=archive_internal_dir,
                   local_archive=os.path.basename(existing_archive),
                   output_path=output_path,
                   source_paths=source_paths,
                   )

        if not unavailable:
            return unavailable

    os.chdir(orig_path)

    return unavailable

def load_str(arg):

    ''' Load a dict string safely using YAML. Return the resulting dict.  '''
    return yaml.load(arg, Loader=yaml.SafeLoader)

def config_exists(arg):

    '''
    Check to ensure that the provided config file exists. If it does,
    load it with YAML's safe loader and return the resulting dict.
    '''

    # Check for existence of file
    if not os.path.exists(arg):
        msg = f'{arg} does not exist!'
        raise argparse.ArgumentTypeError(msg)

    with open(arg, 'r') as config_path:
        cfg = yaml.load(config_path, Loader=yaml.SafeLoader)
    return cfg

def pair_locs_with_files(input_locs, file_templates, check_all):

    '''
    Given a list of input locations and files, return an iterable that
    contains the multiple locations and file templates for files that
    should be searched in those locations.

    check_all indicates that all locations should be paired with all
    avaiable file templates.

    The different possibilities:
    1. Get one or more files from a single path/url
    2. Get multiple files from multiple corresponding
       paths/urls
    3. Check all paths for all file templates until files are
       found

    The default will be to handle #1 and #2. #3 will be
    indicated by a flag in the yaml: "check_all: True"

    '''

    if not check_all:

        # Make sure the length of both input_locs and
        # file_templates is consistent

        # Case 2 above
        if len(file_templates) == len(input_locs):
            locs_files = zip(input_locs, file_templates)

        # Case 1 above
        elif len(file_templates) > len(input_locs) and \
            len(input_locs) == 1:

            locs_files = zip(input_locs, [file_templates])
        else:
            msg = "Please check your input locations and templates."
            raise KeyError(msg)
    else:
        # Case 3 above
        locs_files = [(loc, file_templates) for loc in input_locs]

    return locs_files
def path_exists(arg):

    ''' Check whether the supplied path exists and is writeable '''

    if not os.path.exists(arg):
        msg = f'{arg} does not exist!'
        raise argparse.ArgumentTypeError(msg)

    if not os.access(arg, os.X_OK|os.W_OK):
        logging.error(f'{arg} is not writeable!')
        raise argparse.ArgumentTypeError(msg)

    return arg

def setup_logging(debug=False):

    ''' Calls initialization functions for logging package, and sets the
    user-defined level for logging in the script.'''

    level = logging.WARNING
    if debug:
        level = logging.DEBUG

    logging.basicConfig(format='%(levelname)s: %(message)s \n ', level=level)
    if debug:
        logging.info('Logging level set to DEBUG')



def write_summary_file(cla, data_store, file_templates):

    ''' Given the command line arguments and the data store from which
    the data was retrieved, write a bash summary file that is needed by
    the workflow elements downstream. '''

    files = []
    for tmpl in file_templates:
        files.extend([fill_template(tmpl, cla.cycle_date, fh) for fh in cla.fcst_hrs])

    summary_fp = os.path.join(cla.output_path, cla.summary_file)
    logging.info(f'Writing a summary file to {summary_fp}')
    file_contents = dedent(f'''
        DATA_SRC={data_store}
        EXTRN_MDL_CDATE={cla.cycle_date.strftime('%Y%m%d%H')}
        EXTRN_MDL_STAGING_DIR={cla.output_path}
        EXTRN_MDL_FNS=( {' '.join(files)} )
        EXTRN_MDL_FHRS=( {' '.join([str(i) for i in cla.fcst_hrs])} )
        ''')
    logging.info(f'Contents: {file_contents}')
    with open(summary_fp, "w") as summary:
        summary.write(file_contents)


def to_datetime(arg):
    ''' Return a datetime object give a string like YYYYMMDDHH.
    '''
    return dt.datetime.strptime(arg, '%Y%m%d%H')

def to_lower(arg):
    ''' Return a string provided by arg into all lower case. '''
    return arg.lower()

def main(cla):
    '''
    Uses known location information to try the known locations and file
    paths in priority order.
    '''

    data_stores = cla.data_stores
    known_data_info =  cla.config.get(cla.external_model, {})
    if not known_data_info:
        msg = dedent(f'''No data stores have been defined for
               {cla.external_model}!''')
        if cla.input_file_path is None:
            data_stores = ['disk']
            raise KeyError(msg)
        logging.info(msg + ' Only checking provided disk location.')

    unavailable = {}
    for data_store in data_stores:
        logging.info(f'Checking {data_store} for {cla.external_model}')
        store_specs = known_data_info.get(data_store, {})

        if data_store == 'disk':
            file_templates = cla.file_templates if cla.file_templates else \
                known_data_info.get('hpss', {}).get('file_names')
            if isinstance(file_templates, dict):
                if cla.file_type is not None:
                    file_templates = file_templates[cla.file_type]
                file_templates = file_templates[cla.anl_or_fcst]
            logging.debug(f'User supplied file names are: {file_templates}')
            if not file_templates:
                msg = ('No file naming convention found. They must be provided \
                        either on the command line or on in a config file.')
                raise argparse.ArgumentTypeError(msg)
            unavailable = get_requested_files(cla,
                                              check_all=known_data_info.get('check_all',
                                                  False),
                                              file_templates=file_templates,
                                              input_locs=cla.input_file_path,
                                              method='disk',
                                              )

        elif not store_specs:
            msg = (f'No information is available for {data_store}.')
            raise KeyError(msg)

        else:

            file_templates = store_specs.get('file_names')
            if isinstance(file_templates, dict):
                if cla.file_type is not None:
                    file_templates = file_templates[cla.file_type]
                file_templates = file_templates[cla.anl_or_fcst]
            if not file_templates:
                msg = ('No file name naming convention found. They must be provided \
                        either on the command line or on in a config file.')
                raise argparse.ArgumentTypeError(msg)

            if store_specs.get('protocol') == 'download':
                unavailable = get_requested_files(cla,
                                                  check_all=known_data_info.get('check_all',
                                                      False),
                                                  file_templates=file_templates,
                                                  input_locs=store_specs['url'],
                                                  method='download',
                                                  members=cla.members,
                                                  )

            if store_specs.get('protocol') == 'htar':
                if cla.members:
                    ens_groups = get_ens_groups(cla.members)
                    for ens_group, members in ens_groups.items():
                        unavailable = hpss_requested_files(
                            cla,
                            file_templates,
                            store_specs,
                            members=members,
                            ens_group=ens_group,
                            )
                else:
                    unavailable = hpss_requested_files(cla, file_templates, store_specs)

        if not unavailable:
            # All files are found. Stop looking!
            # Write a variable definitions file for the data, if requested
            if cla.summary_file:
                write_summary_file(cla, data_store, file_templates)
            break

        logging.warning(f'Requested files are unavailable from {data_store}')

    if unavailable:
        logging.error('Could not find any of the requested files.')
        sys.exit(1)

def get_ens_groups(members):

    ''' Given a list of ensemble members, return a dict with keys for
    the ensemble group, and values are lists of ensemble members
    requested in that group. '''

    ens_groups = {}
    for mem in members:
        ens_group = mem // 10 + 1
        if ens_groups.get(ens_group) is None:
            ens_groups[ens_group] = [mem]
        else:
            ens_groups[ens_group].append(mem)
    return ens_groups

def parse_args():

    '''
    Function maintains the arguments accepted by this script. Please see
    Python's argparse documenation for more information about settings of each
    argument.
    '''

    description=(
    'Allowable Python templates for paths, urls, and file names are '\
    ' defined in the fill_template function and include:\n' \
    f'{"-"*120}\n' \
    f'{fill_template("null", dt.datetime.now(), templates_only=True)}')
    parser = argparse.ArgumentParser(
        description=description,
    )

    # Required
    parser.add_argument(
        '--anl_or_fcst',
        choices=('anl', 'fcst'),
        help='Flag for whether analysis or forecast \
        files should be gathered',
        required=True,
        )
    parser.add_argument(
        '--config',
        help='Full path to a configuration file containing paths and \
        naming conventions for known data streams. The default included \
        in this repository is in ush/templates/data_locations.yml',
        type=config_exists,
        )
    parser.add_argument(
        '--cycle_date',
        help='Cycle date of the data to be retrieved in YYYYMMDDHH \
        format.',
        required=True,
        type=to_datetime,
        )
    parser.add_argument(
        '--data_stores',
        help='List of priority data_stores. Tries first list item \
        first. Choices: hpss, nomads, aws, disk',
        nargs='*',
        required=True,
        type=to_lower,
        )
    parser.add_argument(
        '--external_model',
        choices=('FV3GFS','GDAS', 'GEFS', 'GSMGFS', 'HRRR', 'NAM', 'RAP', 'RAPx',
        'HRRRx'),
        help='External model label. This input is case-sensitive',
        required=True,
        )
    parser.add_argument(
        '--fcst_hrs',
        help='A list describing forecast hours.  If one argument, \
        one fhr will be processed.  If 2 or 3 arguments, a sequence \
        of forecast hours [start, stop, [increment]] will be \
        processed.  If more than 3 arguments, the list is processed \
        as-is.',
        nargs='+',
        required=True,
        type=int,
        )
    parser.add_argument(
        '--output_path',
        help='Path to a location on disk. Path is expected to exist.',
        required=True,
        type=os.path.abspath,
        )

    # Optional
    parser.add_argument(
        '--debug',
        action='store_true',
        help='Print debug messages',
        )
    parser.add_argument(
        '--file_templates',
        help='One or more file template strings defining the naming \
        convention the be used for the files retrieved from disk. If \
        not provided, the default names from hpss are used.',
        nargs='*',
        )
    parser.add_argument(
        '--file_type',
        choices=('grib2', 'nemsio', 'netcdf'),
        help='External model file format',
        )
    parser.add_argument(
        '--input_file_path',
        help='A path to data stored on disk. The path may contain \
        Python templates. File names may be supplied using the \
        --file_templates flag, or the default naming convention will be \
        taken from the --config file.',
        )
    parser.add_argument(
        '--members',
        help='A list describing ensemble members.  If one argument, \
        one member will be processed.  If 2 or 3 arguments, a sequence \
        of members [start, stop, [increment]] will be \
        processed.  If more than 3 arguments, the list is processed \
        as-is.',
        nargs='*',
        type=int,
        )
    parser.add_argument(
        '--summary_file',
        help='Name of the summary file to be written to the output \
        directory',
        )
    return parser.parse_args()

if __name__ == '__main__':

    CLA = parse_args()
    CLA.output_path = path_exists(CLA.output_path)
    CLA.fcst_hrs = arg_list_to_range(CLA.fcst_hrs)

    if CLA.members:
        CLA.members = arg_list_to_range(CLA.members)

    setup_logging(CLA.debug)
    print("Running script retrieve_data.py with args:\n",
          f"{('-' * 80)}\n{('-' * 80)}")
    for name, val in CLA.__dict__.items():
        if name not in ['config']:
            print(f"{name:>15s}: {val}")
    print(f"{('-' * 80)}\n{('-' * 80)}")

    if 'disk' in CLA.data_stores:
        # Make sure a path was provided.
        if not CLA.input_file_path:
            raise argparse.ArgumentTypeError(
                ('You must provide an input_file_path when choosing ' \
                 ' disk as a data store!'))

    if 'hpss' in CLA.data_stores:
        # Make sure hpss module is loaded
        try:
            output = subprocess.run('which hsi',
                                    check=True,
                                    shell=True,
                                    )
        except subprocess.CalledProcessError:
            logging.error('You requested the hpss data store, but ' \
                    'the HPSS module isn\'t loaded. This data store ' \
                    'is only available on NOAA compute platforms.')

    main(CLA)
