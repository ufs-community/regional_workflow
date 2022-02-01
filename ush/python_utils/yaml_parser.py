#!/usr/bin/env python3

import argparse
import yaml
import sys

from python_utils.environment import list_to_str
from python_utils.print_msg import print_err_msg_exit
 
def yaml_to_str(cfg):
    """ Get contents of yaml file as string """

    return yaml.dump(cfg, sort_keys=False, default_flow_style=False)

def yaml_to_shell_str(cfg):
    """ Get contents of yaml file as shell script
        key value pairs string.

    Args:
        cfg: dictionary of key-value pairs
    Returns:
        string of k=v pairs
    """

    shell_str = ''
    for k,v in cfg.items():
        v1 = list_to_str(v)
        if isinstance(v,list):
            shell_str += f'{k}={v1}\n'
        else:
            shell_str += f'{k}="{v1}"\n'
    return shell_str

def yaml_safe_load(file_name):
    """ Safe load a yaml file """

    try:
        with open(file_name,'r') as f:
            cfg = yaml.safe_load(f)
    except yaml.YAMLError as e:
        print_err_msg_exit(e)

    return cfg

def join(loader, node):
    """ Custom tag hangler to join strings """
    seq = loader.construct_sequence(node)
    return ''.join([str(i) for i in seq])

yaml.add_constructor('!join', join, Loader=yaml.SafeLoader)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=\
                        'Prints contents of yaml file as bash argument-value pairs.')
    parser.add_argument('--cfg','-c',dest='cfg',required=True,
                        help='yaml configuration file to parse')
    parser.add_argument('--out_type','-o',dest='out_type',required=False,
                        help='output type: could be one of "str": yaml string or "shell": shell string ')

    args = parser.parse_args()

    cfg = yaml_safe_load(args.cfg)

    if args.out_type == 'shell':
        print( yaml_to_shell_str(cfg) )
    else:
        print( yaml_to_str(cfg) )

