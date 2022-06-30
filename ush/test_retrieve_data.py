import glob
import os
import tempfile
import unittest

import retrieve_data

class Testing(unittest.TestCase):


    def setUp(self):
        self.PATH = os.path.dirname(__file__)
        self.config = f'{self.PATH}/templates/data_locations.yml'

    def test_fv3gfs_lbcs_from_hpss(self):

        ''' Get FV3GFS grib2 files from HPSS for LBCS, offset by 6 hours

        '''

        with tempfile.TemporaryDirectory(dir='.') as tmp_dir:

            args = [
                '--anl_or_fcst', 'fcst',
                '--config', self.config,
                '--cycle_date', '2022062512',
                '--data_stores', 'hpss',
                '--external_model', 'FV3GFS',
                '--fcst_hrs', '6', '12', '3',
                '--output_path', tmp_dir,
                '--debug',
                '--file_type', 'grib2',
            ]

            retrieve_data.main(args)

            # Verify files exist in temp dir

            os.chdir(os.path.dirname(__file__))
            path = os.path.join(tmp_dir, '*')
            files_on_disk = glob.glob(path)
            self.assertEqual(len(files_on_disk), 3)

    # GDAS Tests
    def test_gdas_ics_from_aws(self):

        ''' In real time, GDAS is used for LBCS with a 6 hour offset.
        '''

        with tempfile.TemporaryDirectory(dir='.') as tmp_dir:
            out_path_tmpl = f'{tmp_dir}/mem{{mem:03d}}'

            args = [
                '--anl_or_fcst', 'anl',
                '--config', self.config,
                '--cycle_date', '2022052512',
                '--data_stores', 'aws',
                '--external_model', 'GDAS',
                '--fcst_hrs', '6', '9', '3',
                '--output_path', out_path_tmpl,
                '--debug',
                '--file_type', 'netcdf',
                '--members', '9', '10',
            ]

            retrieve_data.main(args)

            # Verify files exist in temp dir

            for mem in [9, 10]:
                files_on_disk = glob.glob(
                    os.path.join(out_path_tmpl.format(mem=mem), '*')
                    )
                self.assertEqual(len(files_on_disk), 2)


    # GEFS Tests
    def test_gefs_grib2_ICS_from_aws(self):

        ''' Get GEFS grib2 a & b files for ICS offset by 6 hours.

        '''

        with tempfile.TemporaryDirectory(dir='.') as tmp_dir:
            out_path_tmpl = f'{tmp_dir}/mem{{mem:03d}}'

            args = [
                '--anl_or_fcst', 'anl',
                '--config', self.config,
                '--cycle_date', '2022052512',
                '--data_stores', 'aws',
                '--external_model', 'GEFS',
                '--fcst_hrs', '6',
                '--output_path', out_path_tmpl,
                '--debug',
                '--file_type', 'netcdf',
                '--members', '1', '2',
            ]

            retrieve_data.main(args)

            # Verify files exist in temp dir
            for mem in [1, 2]:
                files_on_disk = glob.glob(
                    os.path.join(out_path_tmpl.format(mem=mem), '*')
                    )
                self.assertEqual(len(files_on_disk), 2)



    # HRRR Tests
    def test_hrrr_ICS_from_hpss(self):

        ''' Get HRRR ICS from hpss '''

        with tempfile.TemporaryDirectory(dir='.') as tmp_dir:

            args = [
                '--anl_or_fcst', 'anl',
                '--config', self.config,
                '--cycle_date', '2022062512',
                '--data_stores', 'hpss',
                '--external_model', 'HRRR',
                '--fcst_hrs', '0',
                '--output_path', tmp_dir,
                '--debug',
            ]

            retrieve_data.main(args)

            # Verify files exist in temp dir

            os.chdir(os.path.dirname(__file__))
            path = os.path.join(tmp_dir, '*')
            files_on_disk = glob.glob(path)
            self.assertEqual(len(files_on_disk), 1)

    def test_hrrr_LBCS_from_hpss(self):

        ''' Get HRRR LBCS from hpss for 3 hour boundary conditions '''

        with tempfile.TemporaryDirectory(dir='.') as tmp_dir:

            args = [
                '--anl_or_fcst', 'fcst',
                '--config', self.config,
                '--cycle_date', '2022062512',
                '--data_stores', 'hpss',
                '--external_model', 'HRRR',
                '--fcst_hrs', '3', '24', '3',
                '--output_path', tmp_dir,
                '--debug',
            ]

            retrieve_data.main(args)

            # Verify files exist in temp dir

            os.chdir(os.path.dirname(__file__))
            path = os.path.join(tmp_dir, '*')
            files_on_disk = glob.glob(path)
            self.assertEqual(len(files_on_disk), 8)

    def test_hrrr_ICS_from_aws(self):

        ''' Get HRRR ICS from aws '''

        with tempfile.TemporaryDirectory(dir='.') as tmp_dir:

            args = [
                '--anl_or_fcst', 'anl',
                '--config', self.config,
                '--cycle_date', '2022062512',
                '--data_stores', 'aws',
                '--external_model', 'HRRR',
                '--fcst_hrs', '0',
                '--output_path', tmp_dir,
                '--debug',
            ]

            retrieve_data.main(args)

            # Verify files exist in temp dir

            os.chdir(os.path.dirname(__file__))
            path = os.path.join(tmp_dir, '*')
            files_on_disk = glob.glob(path)
            self.assertEqual(len(files_on_disk), 1)

    def test_hrrr_LBCS_from_aws(self):

        ''' Get HRRR LBCS from aws for 3 hour boundary conditions '''

        with tempfile.TemporaryDirectory(dir='.') as tmp_dir:

            args = [
                '--anl_or_fcst', 'fcst',
                '--config', self.config,
                '--cycle_date', '2022062512',
                '--data_stores', 'aws',
                '--external_model', 'HRRR',
                '--fcst_hrs', '3', '24', '3',
                '--output_path', tmp_dir,
                '--debug',
            ]

            retrieve_data.main(args)

            # Verify files exist in temp dir

            os.chdir(os.path.dirname(__file__))
            path = os.path.join(tmp_dir, '*')
            files_on_disk = glob.glob(path)
            self.assertEqual(len(files_on_disk), 8)

    # RAP tests
    def test_rap_ICS_from_aws(self):

        ''' Get RAP ICS from aws offset by 3 hours '''

        with tempfile.TemporaryDirectory(dir='.') as tmp_dir:

            args = [
                '--anl_or_fcst', 'anl',
                '--config', self.config,
                '--cycle_date', '2022062509',
                '--data_stores', 'aws',
                '--external_model', 'RAP',
                '--fcst_hrs', '3',
                '--output_path', tmp_dir,
                '--debug',
            ]

            retrieve_data.main(args)

            # Verify files exist in temp dir

            os.chdir(os.path.dirname(__file__))
            path = os.path.join(tmp_dir, '*')
            files_on_disk = glob.glob(path)
            self.assertEqual(len(files_on_disk), 1)

    def test_rap_LBCS_from_aws(self):

        ''' Get RAP LBCS from aws for 6 hour boundary conditions offset
        by 3 hours. Use 09Z start time for longer LBCS.'''

        with tempfile.TemporaryDirectory(dir='.') as tmp_dir:

            args = [
                '--anl_or_fcst', 'fcst',
                '--config', self.config,
                '--cycle_date', '2022062509',
                '--data_stores', 'aws',
                '--external_model', 'RAP',
                '--fcst_hrs', '3', '30', '6',
                '--output_path', tmp_dir,
                '--debug',
            ]

            retrieve_data.main(args)

            # Verify files exist in temp dir

            os.chdir(os.path.dirname(__file__))
            path = os.path.join(tmp_dir, '*')
            files_on_disk = glob.glob(path)
            self.assertEqual(len(files_on_disk), 5)

