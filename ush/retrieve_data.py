'''
Script is meant to use a YAML file to retrive data from a variety of
sources, including known locations on disk, URLs, and HPSS (from
supported NOAA platforms only).
'''

import argparse
import datetime as dt
import os
import shutil
import subprocess

import requests
import yaml

def download_file(target_path, url):

    '''
    Download a file from a url source, and place it in a target location
    on disk.

    Arguments:
      target_path  full path to a location on disk where file will be
                   stored
      url          url to file to be downloaded

    Return:
      boolean value reflecting state of download.
    '''

    print(f'Trying to download file: {url} to {target_path}')

    with requests.get(url, stream=True) as req:
        if req.status_code != 200:
            print(f'INFO: {url} cannot be reached!')
            return False
        with open(target_path, 'wb') as target:
            shutil.copyfileobj(req.raw, target)

    return True

def download_requested_files(cla, store_specs):

    ''' This function interacts with the "download" protocol in a
    provided data store specs file to download a set of files requested
    by the user. It calls download_file for each individual file that
    should be downloaded. '''

    base_urls = store_specs['url']
    base_urls = base_urls if isinstance(base_urls, list) else [base_urls]

    file_names = store_specs.get('file_names', {})
    if cla.file_type is not None:
        file_names = file_names[cla.file_type]
    file_names = file_names[cla.anl_or_fcst]

    unavialable = {}
    for base_url in base_urls:
        for fcst_hr in cla.fcst_hrs:
            for file_name in file_names:
                url = os.path.join(base_url, file_name)
                url = fill_template(url, cla.cycle_date, fcst_hr)
                target_path = os.path.join(cla.output_path, file_name)
                target_path = fill_template(target_path,
                                            cla.cycle_date, fcst_hr)
                downloaded = download_file(
                    target_path=target_path,
                    url=url,
                    )
                if not downloaded:
                    unavailable[fcst_hr] = target_path
    return unavailable

def fhr_list(args):

    '''
    Given an argparse list argument, return the sequence of forecast hours to
    process.

    The length of the list will determine what forecast hours are returned:

      Length = 1:   A single fhr is to be processed
      Length = 2:   A sequence of start, stop with increment 1
      Length = 3:   A sequence of start, stop, increment
      Length > 3:   List as is

    argparse should provide a list of at least one item (nargs='+').

    Must ensure that the list contains integers.
    '''

    args = args if isinstance(args, list) else [args]
    arg_len = len(args)
    if arg_len in (2, 3):
        args[1] += 1
        return list(range(*args))

    return args

def fill_template(template_str, cycle_date, fcst_hr=0):

    ''' Fill in the provided template string with date time information,
    and return the resulting string.

    Arguments:
      template_str    a string containing Python templates
      cycle_date      a datetime object that will be used to fill in
                      date and time information
      fcst_hr         an integer forecast hour. string formatting should
                      be included in the template_str

    Rerturn:
      filled template string
    '''
    return template_str.format(
        fcst_hr=fcst_hr,
        dd=cycle_date.strftime('%d'),
        hh=cycle_date.strftime('%H'),
        mm=cycle_date.strftime('%m'),
        jjj=cycle_date.strftime('%j'),
        yyyy=cycle_date.strftime('%Y'),
        yyyymm=cycle_date.strftime('%Y%m'),
        yyyymmdd=cycle_date.strftime('%Y%m%d'),
        yyyymmddhh=cycle_date.strftime('%Y%m%d%H'),
        )

def htar_requested_files(cla, store_specs):

    ''' This function interacts with the "hpss" protocol in a
    provided data store specs file to download a set of files requested
    by the user. It calls retrieve_tar for each individual file that
    should be fetched and then untar_file to stage individual files on
    disk. '''

    archive_paths = store_specs['archive_path']
    archive_paths = archive_paths if isinstance(archive_paths, list) \
        else [archive_paths]

    # Could be a list of lists
    archive_file_names = store_specs.get('archive_file_names', {})
    if cla.file_type is not None:
        archive_file_names = archive_file_names[cla.file_type]
    archive_file_names = archive_file_names[cla.anl_or_fcst]

    unavailable = {}
    existing_archive = None

    # Narrow down which HPSS files are available for this date
    for archive_path, archive_file_names in zip(archive_paths, archive_file_names):
        if not isinstance(archive_file_names, list):
            archive_file_names = [archive_file_names]

        # Only test the first item in the list, it will tell us if this
        # set exists at this date.
        file_path = os.path.join(archive_path, archive_file_names[0])
        file_path = fill_template(file_path, cla.cycle_date)

        cmd = f'hsi ls {file_path}'
        try:
            output = subprocess.run(cmd,
                                    capture_output=True,
                                    check=True,
                                    shell=True,
                                    )
        except subprocess.CalledProcessError as excep:
            print(f'{file_path} is not available!')
        else:
            if output.returncode == 0:
                existing_archive = file_path
                print(f'Found HPSS file: {file_path}')
                break

    if not existing_archive:
        print(f'No archive files were found!')
        return unavailable

    # Use the found archive file path to get the necessary files
    file_names = store_specs.get('file_names', {})
    if cla.file_type is not None:
        file_names = file_names[cla.file_type]
    file_names = file_names[cla.anl_or_fcst]

    archive_internal_dirs = store_specs.get('archive_internal_dir', [''])

    output_path = fill_template(cla.output_path, cla.cycle_date)
    print(f'Will place files in {os.path.abspath(output_path)}')
    orig_path = os.getcwd()
    os.chdir(output_path)

    files_exist = False
    source_paths = []
    for archive_internal_dir in archive_internal_dirs:
        for fcst_hr in cla.fcst_hrs:
            for file_name in file_names:
                source_path = os.path.join(archive_internal_dir, file_name)
                source_paths.append(fill_template(source_path,
                    cla.cycle_date, fcst_hr))
        cmd = f'htar -xvf {existing_archive} {" ".join(source_paths)}'
        print(f'Running command \n {cmd}')
        output = subprocess.run(cmd,
                                capture_output=True,
                                check=True,
                                shell=True,
                                )
        if output.returncode == 0:
            break
    os.chdir(orig_path)

def load_config(arg):

    '''
    Check to ensure that the provided config file exists. If it does, load it
    with YAML's safe loader and return the resulting dict.
    '''

    # Check for existence of file
    if not os.path.exists(arg):
        msg = f'{arg} does not exist!'
        raise argparse.ArgumentTypeError(msg)

    with open(arg, 'r') as config_path:
        cfg = yaml.load(config_path, Loader=yaml.SafeLoader)
    return cfg

def path_exists(arg):

    ''' Check whether the supplied path exists and is writeable '''

    if not os.path.exists(arg):
        msg = f'{arg} does not exist!'
        raise argparse.ArgumentTypeError(msg)

    if not os.access(arg, os.X_OK|os.W_OK):
        print(f'ERROR: {arg} is not writeable!')
        raise argparse.ArgumentTypeError(msg)

    return arg

def to_datetime(arg):
    ''' Return a datetime object give a string like YYYYMMDDHH.
    '''

    return dt.datetime.strptime(arg, '%Y%m%d%H')

def main(cla):
    '''
    Uses known location information to try the known locations and file
    paths in priority order.
    '''

    known_data_info =  cla.config.get(cla.external_model)
    if known_data_info is None:
        msg = ('No data stores have been defined for',
               f'{cla.external_model}!')
        raise KeyError(msg)

    unavailable = {}
    for data_store in cla.data_stores:
        print(f'Checking {data_store} for {cla.external_model}')
        store_specs = known_data_info.get(data_store)

        if store_specs is None:
            msg = (f'No information is available for {data_store}.')
            raise KeyError(msg)

        if store_specs['protocol'] == 'download':
            unavailable = download_requested_files(cla, store_specs)

        if store_specs['protocol'] == 'htar':
            unavailable = htar_requested_files(cla, store_specs)

        if not unavailable:
            # All files are found. Stop looking!
            break

def parse_args():

    '''
    Function maintains the arguments accepted by this script. Please see
    Python's argparse documenation for more information about settings of each
    argument.
    '''

    parser = argparse.ArgumentParser(
        description='Retrieve data from various sources.',
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
        )
    parser.add_argument(
        '--external_model',
        choices=('FV3GFS', 'GSMGFS', 'HRRR', 'NAM', 'RAP'),
        help='External model label',
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
        )

    # Optional
    parser.add_argument(
        '--config',
        help='Full path to YAML with known data information',
        type=load_config,
        )
    parser.add_argument(
        '--file_type',
        choices=('grib2', 'nemsio', 'netcdf'),
        help='External model file format',
        )
    return parser.parse_args()

if __name__ == '__main__':

    CLA = parse_args()
    CLA.output_path = path_exists(CLA.output_path)
    CLA.fcst_hrs = fhr_list(CLA.fcst_hrs)
    main(CLA)
