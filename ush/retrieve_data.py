'''
Script is meant to use a YAML file to retrive data from a variety of
sources, including known locations on disk, URLs, and HPSS (from
supported NOAA platforms only).
'''

import argparse

import yaml

def load_config(arg):

    '''
    Check to ensure that the provided config file exists. If it does, load it
    with YAML's safe loader and return the resulting dict.
    '''

    # Check for existence of file
    if not os.path.exists(arg):
        msg = f'{arg} does not exist!'
        raise argparse.ArgumentTypeError(msg)

    return yaml.safe_load(arg)

def fill_template(template_str, cdate, fcst_hr):


def download_file(target_path, url):

    '''
    Download a file from a url source, and place it in a target location
    on disk.

    Arguments:
      target_path  full path to a location on disk where file will be
                   stored
      url          url to file to be downloaded

    Return:
      None
    '''

    with requests.get(url, stream=True) as r:
        with open(target_path, 'wb') as f:
            shutil.copyfileobj(r.raw, f)

def main(cla):
    '''
    Uses known location information to try the known locations and file
    paths in priority order.
    '''

    known_data_info = cla.config.get(cla.external_model)
    if known_data_info is None:
        msg = (f'No data stores have been defined for',
               f'{cla.external_model}!')
        raise KeyError(msg)

    for data_store in cla.data_stores:
        print(f'Checking {data_store} for {cla.external_model}')
        store_specs = known_data_info.get(data_store)

        if store_specs is None:
            msg = (f'No information is available for {data_store}.')
            raise KeyError(msg)

        if store_specs == 'download':
            base_urls = store_specs['url']
            base_urls = base_urls if isinstance(base_urls, list) else [base_urls]

            file_names = store_specs.get('file_names', {})
            if cla.file_type is not None:
                file_names = file_names[cla.file_type]
            file_names = file_names[cla.anl_or_fcst]

            for base_url in base_urls:
                for file_name in file_names:
                    url = fill_template(os.path.join(base_url, file_name),
                                        cla.cdate,
                                        fcst_hr)
                    target_path = fill_template(os.path.join(cla.output,
                                                             file_name,
                                                             ),
                                                cla.cdate,
                                                fcst_hr)

                    download_file(
                        target_path=target_path
                        url=url
                        )

def parse_args():

    '''
    Function maintains the arguments accepted by this script. Please see
    Python's argparse documenation for more information about settings of each
    argument.
    '''

    parser = argparse.ArgumentParser(
        description='Retrieve data from various sources.',
    )

    help_msg = 'Full path to YAML with known data information'
    parser.add_argument('-c', '--config',
                        help=help_msg,
                        type=load_config,
                        )
    parser.add_argument('-e', '--external_model',
                        choices=('FV3GFS', 'GSMGFS', 'HRRR', 'NAM', 'RAP'),
                        help='External model label',
                        )
    parser.add_argument('-d', '--data_stores',
                        choices=('hpss', 'nomads', 'aws'),
                        help='List of priority data_stores. Tries first \
                        list item first.',
                        nargs='*',
                        )
    return parser.parse_args()

if __name__ == '__main__':

    cla = parse_args()
    main(cla)
