#!/usr/bin/env python3

import argparse
import yaml
import sys
import os
from textwrap import dedent

from .environment import list_to_str, str_to_list
from .print_msg import print_err_msg_exit
from .run_command import run_command

def load_shell_config(config_file):
    """ Loads old style shell config files.
    First comments are ripped out, and then a dictionary of key-value
    pairs is constructed with appropriate python data types. The resulting
    dictionary should be equivalent to one obtained from parsing a yaml file.
    For more complicated config scripts, use `load_shell_config_complex` instead

    Args:
        config_file: file name
    Returns:
        a dictionary
    """

    with open(config_file) as f:
        config_str = f.read()

        #take care of nasty same line comments and line continuations
        config_str = config_str.replace(" #"," \n#")
        lines = config_str.splitlines()
        lines = [l.strip() for l in lines \
                    if (l and l[0] != '#' and l[0] != '\n')]
        config_str = "\n".join(lines)
        config_str = config_str.replace("\\\n","")
        lines = config_str.splitlines()

        #build the dictionary
        cfg = {}
        for l in lines:
            idx = l.find("=")
            k = l[:idx]
            v = str_to_list(l[idx+1:])
            cfg[k] = v
        return cfg

    return None 

def load_shell_config_complex(config_file):
    """ If the shell script has more logic than just setting variables,
    we source the config script in a subshell and gets the variables it set
    """

    # Save env vars before and after sourcing the scipt and then
    # do a diff to get variables specifically defined/updated in the script
    # Method sounds brittle but seems to work ok so far
    code = dedent(f'''
      (set -o posix; set) > /tmp/t1
      {{ . {config_file}; set +x; }} &>/dev/null
      (set -o posix; set) > /tmp/t2
      diff /tmp/t1 /tmp/t2 | grep "> " | cut -c 3-
    ''')
    (_,config_str,_) = run_command(code)
    lines = config_str.splitlines()
    
    #build the dictionary
    cfg = {}
    for l in lines:
        idx = l.find("=")
        k = l[:idx]
        v = str_to_list(l[idx+1:])
        cfg[k] = v
    return cfg

def cfg_to_yaml_str(cfg):
    """ Get contents of config file as a yaml string """

    return yaml.dump(cfg, sort_keys=False, default_flow_style=False)

def cfg_to_shell_str(cfg):
    """ Get contents of yaml file as shell script string"""

    shell_str = ''
    for k,v in cfg.items():
        v1 = list_to_str(v)
        if isinstance(v,list):
            shell_str += f'{k}={v1}\n'
        else:
            shell_str += f"{k}='{v1}'\n"
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

def load_config_file(file_name):
    """ Choose yaml/shell file based on extension """
    ext = os.path.splitext(file_name)[1][1:]
    if ext == "sh":
        return load_shell_config_complex(file_name)
    else:
        return yaml_safe_load(file_name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=\
                        'Prints contents of yaml file as bash argument-value pairs.')
    parser.add_argument('--cfg','-c',dest='cfg',required=True,
                        help='yaml or regular shell config file to parse')
    parser.add_argument('--output-type','-o',dest='out_type',required=False,
                        help='output format: "shell": shell format, any other: yaml format ')

    args = parser.parse_args()
    cfg = load_config_file(args.cfg)

    if args.out_type == 'shell':
        print( cfg_to_shell_str(cfg) )
    else:
        print( cfg_to_yaml_str(cfg) )

