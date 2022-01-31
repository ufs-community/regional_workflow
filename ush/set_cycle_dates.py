#!/usr/bin/env python3

import unittest
from datetime import datetime,timedelta

from python_utils import process_args, import_vars, print_input_args, print_err_msg_exit

def set_cycle_dates(**kwargs):
    """ This file defines a function that, given the starting date (date_start, 
    in the form YYYYMMDD), the ending date (date_end, in the form YYYYMMDD), 
    and an array containing the cycle hours for each day (whose elements 
    have the form HH), returns an array of cycle date-hours whose elements
    have the form YYYYMMDD.  Here, YYYY is a four-digit year, MM is a two-
    digit month, DD is a two-digit day of the month, and HH is a two-digit
    hour of the day.

    Args:
        date_start: YYYYMMDD 
        date_end: YYYYMMDD
        cycle_hrs: [ HH0, HH1, ...]
        incr_cycl_freq: cycle frequency increment in hours
    Returns:
        A list of dates in a format YYYYMMDDHH
    """

    valid_args = ['date_start', 'date_end', 'cycle_hrs', 'incr_cycl_freq']
    dictionary = process_args(valid_args, **kwargs)
    print_input_args(dictionary)
    import_vars(dictionary=dictionary)

    #calculate date increment
    if incr_cycl_freq <= 24:
        incr_days = 1
    else:
        incr_days = incr_cycl_freq // 24
        if incr_cycl_freq % 24 != 0:
            print_err_msg_exit(f'''
                INCR_CYCL_FREQ is not divided by 24:
                  INCR_CYCL_FREQ = \"{incr_cycl_freq}\"''')

    #iterate over days and cycles
    all_cdates = []
    d = date_start
    while d <= date_end:
        for c in cycle_hrs:
            dc = d + timedelta(hours=c)
            v = datetime.strftime(dc,'%Y%m%d%H')
            all_cdates.append(v)
        d += timedelta(days=incr_days)

    return all_cdates
   
class Testing(unittest.TestCase):
    def test_set_cycle_dates(self):
        cdates = set_cycle_dates(date_start='20220101', date_end='20220104',
                        incr_cycl_freq='48', cycle_hrs='("6" "12")') 
        self.assertEqual(cdates, ['2022010106', '2022010112','2022010306', '2022010312'])
