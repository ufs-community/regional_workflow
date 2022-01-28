#!/usr/bin/env python3

import os
import inspect
import shlex
from datetime import datetime, date

def str_to_date(s):
    """ Get python datetime object from string.
    It tests for only two formats used in RRFS: YYYYMMDD and YYYYMMDDHHMM

    Args:
        s: a string
    Returns:
        datetime object or None
    """
    try:
        v = datetime.strptime(s, "%Y%m%d%H%M")
        return v
    except:
        try:
            v = datetime.strptime(s, "%Y%m%d")
            return v
        except:
            return None

def get_str_type(s, just_get_me_the_string = False):
    """ Check if the string contains a float, int, boolean, or just reguar string
    This will be used to automatically convert environment variables to data types
    that are more convenient to work with. If you don't want this functionality,
    pass just_get_me_the_string = True

    Args:
        s: a string
        just_get_me_the_string: Set to True to return the string itself
    Returns:
        a float, int, boolean, date, or the string itself when all else fails
    """
    if not just_get_me_the_string:
        if s.lower() in ['true','yes','yeah']:
            return True
        elif s.lower() in ['false','no','nope']:
            return False
        v = str_to_date(s)
        if v:
            return v
        if s.isnumeric():
            return int(s)
        try:
            v = float(s)
            return v
        except:
            pass
    return s

def list_to_shell_str(v, oneline=False):
    """ Given a string or list of string, construct a string
    to be used on right hand side of shell environement variables

    Args:
        v: a string/number, list of strings/numbers, or null string('')
    Returns:
        A string
    """
    if isinstance(v,bool) or \
       isinstance(v,int) or \
       isinstance(v,float) or \
       isinstance(v,date):
        return str(v)
    elif not v:
        return ''
    elif isinstance(v, list):
        v = [str(i) for i in v]
        if oneline or len(v) <= 4:
            shell_str = f'( "' + '" "'.join(v) + '" )'
        else:
            shell_str = f'( \\\n"' + '" \\\n"'.join(v) + '"\\\n)'
    else:
        v1 = shlex.quote(str(v))
        shell_str = f'{v1}'

    return shell_str

def shell_str_to_list(v):
    """ Given a string, construct a string or list of strings.
    Basically does the reverse operation of `list_to_shell_string`.

    Args:
        v: a string
    Returns:
        a string, list of strings or null string('')
    """
    
    if not isinstance(v,str):
        return v
    if not v:
        return None
    elif v[0] == '(':
        v = v[1:-1]
        tokens = shlex.split(v)
        lst = [ get_str_type(itm.strip()) for itm in tokens ]
        return lst
    else:
        return get_str_type(v)

def set_env_var(param,value):
    """ Set an environement variable

    Args:
        param: the variable to set
        value: either a string, list of strings or None
    Returns:
        None
    """

    os.environ[param] = list_to_shell_str(value)

def get_env_var(param):
    """ Get the value of an environement variable

    Args:
        param: the environement variable
    Returns:
        Returns either a string, list of strings or None
    """

    if not param in os.environ:
        return None
    else:
        value = os.environ[param]
        return shell_str_to_list(value)

def import_vars(dictionary=os.environ, target_dict=None, env_vars=None):
    """ Import all (or select few) environment/dictionary variables as python global 
    variables of the caller module. Call this function at the beginning of a function
    that uses environment variables.

    Note: For ready-only environmental variables calling this function once should be enough.
    However, if the variable is mutable in the module it is called from, the variable should be
    explicitly tagged as `global`, and then the variable's value be exported back to the environment
    with a call to export_vars()
        
        import_vars()
        global MYVAR
        MYVAR.append("Hello")
        export_vars()

    There doesn't seem to an easier way of imitating the shell script doing way of things, which
    assume that everything is global unless specifically tagged local, while the opposite is true
    for python.

    Args:
        dictionary: source dictionary (default=os.environ)
        target_dict: target dictionary (default=caller module's globals())
        env_vars: list of selected environement/dictionary variables to import, or None,
        in which case all environment/dictionary variables are imported
    Returns:
        None
    """
    if not target_dict:
        target_dict = inspect.stack()[1][0].f_globals

    if env_vars == None:
        env_vars = dictionary
    else:
        env_vars = { k: dictionary[k] if k in dictionary else None for k in env_vars }

    for k,v in env_vars.items():
        target_dict[k] = shell_str_to_list(v) 

def export_vars(dictionary=os.environ, source_dict=None, env_vars=None):
    """ Export all (or select few) global variables of the caller module
    to either the environement/dictionary. Call this function at the end of
    a function that updates environment variables.

    Args:
        dictionary: target dictionary to set (default=os.environ)
        source_dict: source dictionary (default=caller modules globals())
        env_vars: list of selected environement/dictionary variables to export, or None,
        in which case all environment/dictionary variables are exported
    Returns:
        None
    """
    if not source_dict:
        source_dict = inspect.stack()[1][0].f_globals

    if env_vars == None:
        env_vars = source_dict
    else:
        env_vars = { k: source_dict[k] if k in source_dict else None for k in env_vars }

    for k,v in env_vars.items():
        dictionary[k] = list_to_shell_str(v)

