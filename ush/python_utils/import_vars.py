#!/usr/bin/env python3

import os
import inspect

def import_vars(dictionary=os.environ, env_vars=None):
    """ Import all (or select few) environment/dictionary variables as python global 
    variables of the caller module. 

    Args:
        env_vars: list of selected environement/dictionary variables to import, or None,
        in which case all environment/dictionary variables are imported
    Returns:
        None
    """

    if env_vars == None:
        env_vars = dictionary
    else:
        env_vars = { k: dictionary[k] if k in dictionary else None for k in env_vars }

    for k,v in env_vars.items():
        inspect.stack()[1][0].f_globals[k] = v 

