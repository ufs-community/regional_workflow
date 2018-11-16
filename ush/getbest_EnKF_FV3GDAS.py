"""
 Name:  getbest_EnKF.py            Author:  Jacob Carley 

 Abstract:
 This Python script returns the closest valid EnKF forecast output in the form
 of complete file paths in a user defined outputfile.

 Usage: python getbest_EnKF.py -d [COM_EnKF] -v [valid time in YYYYMMDDHH] -t [hours] -r [resolution]
                               -o [output file] -m [ens mean?] -s [starting fhr] --retro=yes/no --exact=yes/no
                               --minsize=x --o3fname=filename --4d=[start,stop,inchrs] --gfs_nemsio=yes/no -h

 -d [COM_EnKF] = Directory where EnKF output resides, e.g. /com/gfs/prod/enkf (omit the .YYYYMMDDHH)
 -v [vtime] = valid time in YYYYMMDDHH (i.e. GSI analysis time)
 -t [hours] = Look back time, in hours from vtime, to start search for best set of EnKF members
 -r [resolution] = Full res or low res enkf members (f or l).
 -o [output file] = Name of the outputfile
 -m [ens mean?] = yes/no on whether or not to return the ens mean (default is yes)
 -s [starting fhr] = Minimum limit on EnKF member forecast length (i.e. return no matches less than or equal this number)
 --retro=yes/no: whether or not this is a retro run (default is no). If yes it grabs the INPUT envar and searches only that directory
 --exact=yes/np: whether the retrieved EnKF members must be valid exactly at vtime (default is NO)
 --minsize=x : minimum acceptable number of ensemble members (default=81 w/ mean, 80 w/o; includes the mean if -m is YES)
 --o3fname=filename : file name to use as sym link to ensemble mean.  Will not run unless -m is True (default=None)
 --4d=[start,stop,inchrs] : If set script assumes ensembles for 4DEnVar are requested.  Default is OFF.
                                  [start=YYYMMDDHH,end=YYYYMMDDHH,inchrs=3]  
                                  In this mode:
                                      the number of output fill lists will equal the number of ensemble fhrs.
                                      The setting for -v [vtime] is ignored.
 --gfs_nemsio=yes/no : Whether to look for input EnKF files from the GFS in nemsio format (Deafult is NO).
 -h = Prints this output

 History: 2015-09-04    Carley       Initial implementation
          2015-09-18    Carley       Updated for retro runs, exact dates, min ensemble size, and o3 file linking
          2015-09-18    Carley       Updated for 4DEnVar, where we want all EnKF forecasts to be from the same cycle
          2017-01-03    Carley       Updated for new gfs file name conventions
"""

import sys,os,getopt,time,errno
from datetime import datetime,timedelta

def usage():
    print ("Usage: python %s -d [COM_EnKF] -v [valid time in YYYYMMDDHH] -t [hours] -r [resolution] \n" 
           "\t\t\t\t-o [output file] -m [ens mean?] -s [starting fhr] --retro=yes/no --exact=yes/no \n"
           "\t\t\t\t--minsize=x --o3fname=filename --4d=[start,stop,inchrs] -h") % (sys.argv[0])
    print
    print " -d [COM_EnKF] = Directory where EnKF output resides, e.g. /com/gfs/prod/enkf (omit the .YYYYMMDDHH)"
    print " -v [vtime] = valid time in YYYYMMDDHH (i.e. GSI analysis time)"
    print " -t [hours] = Look back time, in hours from vtime, to start search for best set of EnKF members"
    print " -r [resolution] = Full res or low res enkf members (f or l)."
    print " -o [output file] = Name of the outputfile"
    print " -m [ens mean?] = yes/no on whether or not to return the ens mean (default is yes)"
    print " -s [starting fhr] = Minimum limit on EnKF member forecast length (i.e. return no matches less than or equal this number)"
    print " --retro=yes/no: whether or not this is a retro run (default is no). If yes it grabs the INPUT envar and searches only that directory"
    print " --exact=yes/no: whether the retrieved EnKF members must be valid exactly at vtime (default is NO)"
    print " --minsize=x : minimum acceptable number of ensemble members (default=81 w/ mean, 80 w/o; includes the mean if -m is YES)"
    print " --o3fname=filename : file name to use as sym link to ensemble mean.  Will not run unless -m is True (default=None)"
    print (" --4d=[start,stop,inchrs] : If set script assumes ensembles for 4DEnVar are requested.  Default is OFF. \n"\
          "\t\t\t\t[start=YYYMMDDHH,end=YYYYMMDDHH,inchrs=3] \n"
          "\t\t\t\tIn this mode: \n"
          "\t\t\t\t\t The number of output fill lists will equal the number of ensemble fhrs. \n"
          "\t\t\t\t\t The setting for -v [vtime] is ignored. \n"
          "\t\t\t\t\t The setting for --exact [yes/no] is ignored and is alsways assumed true. \n"
          "\t\t\t\t\t The starting forecast hour, -s [starting fhr], must be evenly divisble by inchrs. " )
    print " --gfs_nemsio=yes/no : Whether to look for input EnKF files from the GFS in nemsio format (Deafult is NO)."
    print " -h = Prints this output"

def is_non_zero_file(fpath):
    return True if os.path.isfile(fpath) and os.path.getsize(fpath) > 0 else False

def force_symlink(f1,f2):
    try:
        os.symlink(f1,f2)
    except OSError, e:
        if e.errno == errno.EEXIST:
            os.remove(f2)
            os.symlink(f1,f2)

def write_filelist(fname,comenkf,fsave,svdate,retro,path,suf,o3fname,getmean,gfs_nemsio):
    svcdate=svdate.strftime('%Y%m%d%H')
    svPDY=svdate.strftime('%Y%m%d')
    svCYC=svdate.strftime('%H')
    if retro:
        if 'INPUT' in os.environ:
            path=os.environ['INPUT']
        else:
            sys.exit("Unable to locate INPUT in your environment!\n" \
                     "Therefore cannot find where EnKF members reside for Retro. Exit.")
    else:
        path=comenkf+'.'+svPDY+'/'+svCYC
    f=open(fname,'w')
    havefile=True   
    if getmean:
        if gfs_nemsio:
            en=path+'/gdas.t'+svCYC+'z.atmf'+str(fsave).zfill(3)+'.ensmean.nemsio'
        else:
            en=path+'/sfg_'+svcdate+'_fhr'+str(fsave).zfill(2)+'_ensmean'+suf
        f.write(en+'\n')
        if o3fname is not None: force_symlink(en,o3fname)
    n=0
    while havefile: # first while loop code
        n=n+1
        mem=str(n).zfill(3)
        if gfs_nemsio:
            en=path+'/mem'+mem+'/gdas.t'+svCYC+'z.atmf'+str(fsave).zfill(3)+'s.nemsio'
        else:
            en=path+'/sfg_'+svcdate+'_fhr'+str(fsave).zfill(2)+'s_mem'+mem+suf
        if is_non_zero_file(en):
            f.write(en+'\n')
        else:
            havefile=False
            n=n-1   # Remove the erroneously added member
    if getmean: n=n+1
    f.close()
    print 'Grabbed %d members at fhr %s from the %s EnKF Cycle' % (n,fsave,svcdate)


def checkmembers(thispath,fhr,thiscdate,thissuf,gfs_nemsio):
    n=0
    havefile=True
    fhrs=str(fhr).zfill(2)
    while havefile:
        n=n+1
        mem=str(n).zfill(3)
        if gfs_nemsio:
            CYC=thiscdate[8:10] 
            f=thispath+'/mem'+mem+'/gdas.t'+CYC+'z.atmf'+str(fhr).zfill(3)+'s.nemsio'
        else:
            f=thispath+'/sfg_'+thiscdate+'_fhr'+str(fhr).zfill(2)+'s_mem'+mem+thissuf
        if not is_non_zero_file(f):
            havefile=False
            n=n-1   # Remove the erroneously added member
    return n

def main():

    try:
        opts, args = getopt.getopt(sys.argv[1:], "d:v:t:r:o:m:s:h",["retro=","exact=","minsize=","o3fname=","4d=","gfs_nemsio="])
    except getopt.GetoptError as err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        usage()
        sys.exit()

    # Set the defaults
    svdate=None
    cdate=datetime.today().strftime('%Y%m%d%H')#Use current YYYYMMDDHH as default
    comenkf='/com/gfs/prod/enkf'
    tm=24
    suf=""      #Use full resolution
    fname='filelist'
    getmean=True
    sfhr=3
    retro=False
    exact=False
    minsize=81
    o3fname=None
    fourd=None
    gfs_nemsio=False

    for o, a in opts:
        if o == "-d":
            comenkf=str(a)
        elif o == "-v":
            cdate=str(a)
        elif o == "-t":
            tm=int(a)
        elif o == "-r":
            if a.strip().upper()=='L':
                suf="_t254"
            elif a.strip().upper()=='F':
                suf=""
            else:
                usage()
                sys.exit("Invalid choice for resoltuion.")     
        elif o == "-o":
            fname=str(a)
        elif o == "-m":
            if str(a).upper() == 'NO' or str(a).upper() == 'N':
                getmean = False
                minsize=minsize-1
            elif str(a).upper() == 'YES' or str(a).upper() == 'Y':
                getmean = True
            else:
                usage()
                sys.exit("Invalid choice for returning ensemble mean. yes or no only..")
        elif o == "-s":
            sfhr=int(a)
        elif o == "--retro":
            if str(a).upper() == 'NO' or str(a).upper() == 'N':
                retro = False
            elif str(a).upper() == 'YES' or str(a).upper() == 'Y':
                retro = True
            else:
                usage()
                sys.exit("Invalid choice for --retro. yes or no only..")
        elif o == "--exact":
            if str(a).upper() == 'NO' or str(a).upper() == 'N':
                exact = False
            elif str(a).upper() == 'YES' or str(a).upper() == 'Y':
                exact = True
            else:
                usage()
                sys.exit("Invalid choice for --exact. yes or no only..")
        elif o == "--minsize":
            minsize=int(a)
        elif o == "--o3fname":
            o3fname=str(a)
        elif o == "--4d":
            fourd=str(a).split(',')
            fourd=[q.replace('[','') for q in fourd]
            fourd=[q.replace(']','') for q in fourd]
        elif o == "--gfs_nemsio":
            if str(a).upper() == 'NO' or str(a).upper() == 'N':
               gfs_nemsio = False
            elif str(a).upper() == 'YES' or str(a).upper() == 'Y':
               gfs_nemsio = True
            else:
                usage()
                sys.exit("Invalid choice for --exact. yes or no only..")
        elif o == "-h":
            usage()
            sys.exit()
        else:           
            usage()
            sys.exit("Unhandled option.")   


    if gfs_nemsio and suf !="":        
        suf=""
        print("When gfs_nemsio=YES we must use hi-res EnKF members! Resetting resolution ot hi-res!")

    # For 4D, we want the nearest cycledate having a complete set of fhrs
    #  if a complete set is found, exit the loop and write out
    if fourd is not None:
        inchr=int(fourd[2])
        if int(sfhr)%int(inchr) is not 0:
            usage()
            sys.exit("The starting ensemble forecast hour MUST be evenly divisble by the 4D time increment!")  
        start=fourd[0]
        stop=fourd[1]
        # Convert cdate to a datetime object
        stopdate=datetime.strptime(stop,'%Y%m%d%H')
        startdate=datetime.strptime(start,'%Y%m%d%H')
        diff=stopdate-startdate
        windlength=int(abs((diff.days*24.)+(diff.seconds/3600.)))
        fourdtdeltas=[x for x in range(0,windlength+inchr,inchr)]
        fourdvtimes=[startdate+timedelta(hours=tdelta) for tdelta in fourdtdeltas]
        # Start by looking at cycles closest to the start of the 4D window, looking bakcward only
        #  really necessary.  Note that we cannot really look back farther than, perhaps 12 hours or so
        tm=tm+fourdvtimes[0].hour%6
        tmlist=range(fourdvtimes[0].hour%6,tm+6,6)
        tmlist=[x for x in tmlist if x >= 0] #make sure we only keep the positive elements
        dateobjs=[startdate+timedelta(hours=-tm) for tm in tmlist]
        found=[False for x in range(0,windlength+inchr,inchr)]
        cdate_save=9999999999999
        for dateobj in dateobjs:
            cdate=dateobj.strftime('%Y%m%d%H')
            PDY=dateobj.strftime('%Y%m%d')
            CYC=dateobj.strftime('%H')
            x=-1
            for indate in fourdvtimes:
                x=x+1
                if found[x] is False:                
                    for f in range(9,sfhr-inchr,-inchr):                
                   # if False in found:
                        if retro:
                            if 'INPUT' in os.environ:
                                path=os.environ['INPUT']
                            else:
                                sys.exit("Unable to locate INPUT in your environment!\n" \
                                         "Therefore cannot find where EnKF members reside for Retro. Exit.")
                        else:
                            path=comenkf+'.'+PDY+'/'+CYC                
                        if gfs_nemsio:
                            en=path+'/gdas.t'+CYC+'z.atmf'+str(f).zfill(3)+'.ensmean.nemsio'
                        else:
                            en=path+'/sfg_'+cdate+'_fhr'+str(f).zfill(2)+'_ensmean'+suf
                        print 'Checking in %s for forecast hour %s for 4D Time %s' % (path,str(f).zfill(2),indate.strftime('%Y%m%d%H'))
                        if is_non_zero_file(en):
                            age=(time.time()-os.stat(en).st_mtime)/60. #get difference in seconds and convert to minutes
                            if age > 5.:
                                # If the files exists and has not been modified for 5 minutes
                                #  let's calculate the forecast valid date and make sure it is what 
                                fvalid=dateobj+timedelta(hours=f)
                                tdelt=fvalid-indate
                                diff = abs( (tdelt.days * 24. ) + (tdelt.seconds/(3600.)) )                               
                                if diff <= 0.0001 and int(cdate) <= cdate_save:
                                    nens=checkmembers(path,f,cdate,suf,gfs_nemsio)
                                    if getmean: nens=nens+1
                                    if nens>=minsize:
                                        cdate_save=int(cdate)
                                        svdate=dateobj
                                        found[x]=int(f)
        if False in found: 
            print 'Unable to find matching EnKF members.'
            sys.exit()
        for fhr in found:
            if o3fname is not None: 
                thiso3fname=o3fname+str(fhr).zfill(2)
            else:
                thiso3fname=o3fname
            write_filelist(fname+str(fhr).zfill(2),comenkf,fhr,svdate,
                           retro,path,suf,thiso3fname,getmean,gfs_nemsio)

   
    elif fourd==None:
        # Convert cdate to a datetime object
        indate=datetime.strptime(cdate,'%Y%m%d%H')
        # Starting cdate for searching - find by looking back tm hours
        #  from closest, valid global cdate (something evenly divisible by 6)
        tm=tm+indate.hour%6
        tmlist=range(tm,0-indate.hour%6,-6)
        tmlist=[x for x in tmlist if x >= 0] #make sure we only keep the positive elements
        dateobjs=[indate+timedelta(hours=-tm) for tm in tmlist]
        hdiff=999
        fsave=999
        for dateobj in dateobjs:
            cdate=dateobj.strftime('%Y%m%d%H')
            PDY=dateobj.strftime('%Y%m%d')
            CYC=dateobj.strftime('%H')
            for f in range(sfhr,10):
                if retro:
                    if 'INPUT' in os.environ:
                        path=os.environ['INPUT']
                    else:
                        sys.exit("Unable to locate INPUT in your environment!\n" \
                                 "Therefore cannot find where EnKF members reside for Retro. Exit.")
                else:
                    path=comenkf+'.'+PDY+'/'+CYC

                if gfs_nemsio:
                    en=path+'/gdas.t'+CYC+'z.atmf'+str(f).zfill(3)+'.ensmean.nemsio'
                else:
                    en=path+'/sfg_'+cdate+'_fhr'+str(f).zfill(2)+'_ensmean'+suf
                print 'Checking in %s for forecast hour %s' % (path,str(f).zfill(2))
                if is_non_zero_file(en):
                    age=(time.time()-os.stat(en).st_mtime)/60. #get difference in seconds and convert to minutes
                    if age > 5.:
                        # If the files exists and has not been modified for 5 minutes
                        #  let's calculate the forecast valid date and update hdiff
                        fvalid=dateobj+timedelta(hours=f)
                        tdelt=fvalid-indate
                        diff = abs( (tdelt.days * 24. ) + (tdelt.seconds/(3600.)) )
                        if exact:
                            if diff <= 0.0001 and f<=fsave:
                                nens=checkmembers(path,f,cdate,suf,gfs_nemsio)
                                if getmean: nens=nens+1
                                if nens>=minsize:
                                    hdiff=diff
                                    svdate=dateobj
                                    fsave=f
                        else:
                            if diff <= hdiff or (diff <= hdiff and f<fsave):
                                nens=checkmembers(path,f,cdate,suf,gfs_nemsio)
                                if getmean: nens=nens+1
                                if nens>=minsize:
                                    hdiff=diff
                                    svdate=dateobj
                                    fsave=f

        if svdate is None: 
            print 'Unable to find matching EnKF members.'
            sys.exit()
        write_filelist(fname,comenkf,fsave,svdate,retro,path,suf,o3fname,getmean,gfs_nemsio)


if __name__ == '__main__': main()
