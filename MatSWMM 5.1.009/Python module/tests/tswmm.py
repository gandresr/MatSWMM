# -*- coding:utf-8 -*-
'''
#   swmm.py
#	(Universidad de los Andes - GIAP)
#
#	Project:  SWMM 5.1 Python Toolbox
#   Version:  0.0.1
#   Date:     06/23/14
#   Author:   Gerardo Andrés Riaño Briceño
#	Visit us: http://giap.uniandes.edu.co
#
#	 This is a python module with basic functions to compute
#	 cosimulation processes with SWMM. The main goal of this
#	 module is to allow its users to design optimization
#	 models and real time control systems, for drainage
#	 systems.
#
'''

# ------------------------- MODULES ---------------------------

from ctypes import c_double, WinDLL, c_float, pointer # Required to handle with DLL variables
from time import time # Required to get computational times.
from os import remove # Required to clear info file.
from SWMMconstants import *
import math, re # Used to create .rpt and .out paths

_swmmDLL = WinDLL("swmm5.dll") # Loads the DLL
_swmmDLL.swmm_get.restype = c_double # Define the return type of the DLL function swmm_get
_elapsedTime = c_double(0.000001) # Elapsed time in decimal days
_ptrTime = pointer( _elapsedTime ) # Pointer to elapsed time
_start_time = time() # Simulation start time
_end_time = time() # Simulation end time
_pattern = re.compile(".inp", re.IGNORECASE) # Used to create paths for report and output files

def open_file(inp):

	'''
	+ Inputs:
	  * inp [string] Path to the input file .inp
	  * msg [boolean] Display message in the terminal if True.
	+ Outputs: None
	+ Purpose: opens the files required to run a SWMM simulation
	'''

	# Creates paths for the report and the output files
	rpt = _pattern.sub(".rpt", inp)
	out = _pattern.sub(".out", inp)

	error = _swmmDLL.swmm_open(inp, rpt, out)
	if (error != 0):
		raise _ERROR_MSG_PATH

def start(write_report):

	'''
	+ Inputs:
	  * write_report [integer] Constant related to the write report
	  file option.
	  * msg [boolean] Display message in the terminal if True.
	+ Outputs: None
	+ Purpose: starts a SWMM simulation. Raise Exception if there is an error.
	'''
	_start_time = time()
	error = _swmmDLL.swmm_start(write_report)
	if error:
		print error

def run_step():

	'''
	+ Inputs: None
	+ Outputs: None
	+ Purpose: advances the simulation by one routing time step. Raise Exception
	if there is an error.
	'''
	error = _swmmDLL.swmm_step(_ptrTime)

def end():
	'''
	+ Inputs: None.
	+ Outputs: None
	+ Purpose: Ends a SWMM simulation. Raise Exception if there is an error.
	'''
	error = _swmmDLL.swmm_end()
	_end_time = time()

def close(msg=False):

	'''
	+ Inputs: msg [boolean] Display message in the terminal if True.
	+ Outputs: None
	+ Purpose: closes a SWMM project. Raise Exception if there is an error.
	'''
	error = _swmmDLL.swmm_close()

def get_mass_bal_error():

	'''
	+ Inputs: None.
	+ Outputs: [tuple] Values of the errors related to mass balance.
	[Runoff error, Flow error, Quality error]
	+ Purpose: gets the mass balance errors of the simulation.
	'''

	runOffErr = c_float(0)
	flowErr = c_float(0)
	qualErr = c_float(0)
	ptrRunoff = pointer(runOffErr)
	ptrFlow = pointer(flowErr)
	ptrQual = pointer(qualErr)

	_swmmDLL.swmm_getMassBalErr(ptrRunoff, ptrFlow, ptrQual)
	return runOffErr.value, flowErr.value, qualErr.value

def is_over():
	'''
	+ Inputs: None
	+ Outputs: [boolean] True if the simulation is over, False otherwise
	+ Purpose: determines if the simulation is over or not.
	'''
	return _elapsedTime.value == 0.0

def end():

	'''
	+ Inputs: msg [boolean] Display message in the terminal if True.
	+ Outputs: None
	+ Purpose: ends a SWMM simulation. Raise Exception if there is an error.
	'''
	error = _swmmDLL.swmm_end()
	_end_time = time()

def close():
	'''
	+ Inputs: msg [boolean] Display message in the terminal if True.
	+ Outputs: None
	+ Purpose: closes a SWMM project. Raise Exception if there is an error.
	'''
	error = _swmmDLL.swmm_close()
	_elapsedTime = c_double(0.000001) # Elapsed time in decimal days

def nObjects(swmmType, swmmSubType=-1):
	return _swmmDLL.swmm_get_nobjects(swmmType, swmmSubType)
