#!/usr/bin/env python
import argparse
import datetime as dt
import os

def create_cycle_yaml(template, inputdir, outputdir, cycle, dtcycle):
    """
    find and replace strings in a template file with the correct
    strings and write to an output file in a working directory

    create_cycle_yaml(template, inputdir, outputdir, cycle)
    template - str of basename of file 'template.yaml'
    inputdir - str path of directory containing template file
    outputdir - str path of directory to save final file to
    cycle - datetime object of valid time
    dtcycle - integer hours between cycles
    """
    # define variables to substitute in templates
    windowbdt = cycle - dt.timedelta(hours=(dtcycle/2.))
    winbegin = windowbdt.strftime('%Y-%m-%dT%H:%M:%SZ')
    cycledate = cycle.strftime('%Y-%m-%dT%H:%M:%SZ')
    bkgdir = 'Data/bkg/'
    bkgprefix = cycle.strftime('%Y%m%d.%H%M%S')
    obsdate = cycle.strftime('%Y%m%d%H')

    SubVars = {
              '%windowbegin%': winbegin,
              '%windt%': str(dtcycle),
              '%bkgdir%': bkgdir,
              '%bkgprefix%': bkgprefix,
              '%obsdate%': obsdate,
              '%bumpdate%': cycledate,
              }

    # open files and perform substitutions
    infile = os.path.join(inputdir, template)
    outfile = os.path.join(outputdir, template)
    with open(infile) as f1:
        with open(outfile, 'w') as f2:
            for line in f1:
                for src, target in SubVars.items():
                    line = line.replace(src, target)
                f2.write(line)
    print(f"YAML file written to {outfile}")


parser = argparse.ArgumentParser(description='Generate YAML from templates'+\
                                ' to run BUMP and a JEDI analysis')
parser.add_argument('-i', '--input', type=str,
                    help='path to directory of template YAML files',
                    required=True)
parser.add_argument('-o', '--output', type=str,
                    help='path to output working directory',
                    required=True)
parser.add_argument('-y', '--yaml', type=str,
                    help='list of template YAML files to process',
                    nargs='+', required=True)
parser.add_argument('-c', '--cycle', help='analysis cycle time',
                    type=str, metavar='YYYYMMDDHH', required=True)
parser.add_argument('-t', '--dtcycle', help='number of hours between cycles',
                    type=int, required=False, default=6)
args = parser.parse_args()

cycle = dt.datetime.strptime(args.cycle, "%Y%m%d%H")

for template in args.yaml:
    create_cycle_yaml(template, args.input, args.output, cycle, args.dtcycle)
