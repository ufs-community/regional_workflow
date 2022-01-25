#!/usr/bin/env python3

import os
from python_utils.print_msg import print_err_msg_exit

def cmd_vrfy(*args):
    """ Execute system command

    Args:
        cmd: a linux command
        *args: arguments of the command
    Returns:
        Exit code
    """

    cmd = ''
    for a in args:
        cmd += ' ' + str(a)
    ret = os.system(cmd)
    if ret != 0:
        print_err_msg_exit(f'System call "{cmd}" failed.')
    return ret

def cp_vrfy(*args):
    return cmd_vrfy('cp', *args)
def mv_vrfy(*args):
    return cmd_vrfy('mv', *args)
def rm_vrfy(*args):
    return cmd_vrfy('rm', *args)
def ln_vrfy(*args):
    return cmd_vrfy('ln', *args)
def mkdir_vrfy(*args):
    return cmd_vrfy('mkdir', *args)
def cd_vrfy(*args):
    return cmd_vrfy('cd', *args)

