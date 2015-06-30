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
import math, re # Used to create .rpt and .out paths

# ------------------------ CONSTANTS ---------------------------

# Types of objects
JUNCTION = 0
SUBCATCH = 1
NODE = 2
LINK = 3
STORAGE = 4
ORIFICE = 414
OUTFALL = 417

# Unit system
US = 0
SI = 1
DIMENSIONLESS = 0

# Attributes
DEPTH = 200			# [LINK] && [NODE]
VOLUME = 201		# [LINK] && [NODE]
FLOW = 202			# [LINK]
SETTING = 203		# [LINK]
FROUDE = 204		# [LINK]
INFLOW = 205		# [NODE]
FLOODING = 206		# [NODE]
PRECIPITATION = 207	# [SUBCATCHMENT]
RUNOFF = 208		# [SUBCATCHMENT]
LINK_AREA = 209		# [LINK]

# Start options
NO_REPORT = 0
WRITE_REPORT = 1

# Input file constants
INVERT = 400		# [NODE]
DEPTH_SIZE = 401	# [LINK] [NODE]
STORAGE_A = 402		# [NODE]
STORAGE_B = 403		# [NODE]
STORAGE_C = 404		# [NODE]
LENGTH = 405		# [LINK]
ROUGHNESS = 406		# [LINK]
IN_OFFSET = 407		# [LINK]
OUT_OFFSET = 408	# [LINK]
AREA = 409			# [SUBCATCHMENTS]
IMPERV = 410		# [SUBCATCHMENTS]
WIDTH = 411			# [SUBCATCHMENTS]
SLOPE = 412			# [SUBCATCHMENTS]
OUTLET = 413		# [SUBCATCHMENTS]
FROM_NODE = 415		# [LINK]
TO_NODE = 416		# [LINK]

# ------------------- GLOBAL PRIVATE CONSTANTS -----------------

_ERROR_PATH = -300
_ERROR_ATR = -299
_ERROR_TYPE = -298
_ERROR_NFOUND = -297
_ERROR_INCOHERENT = -296
_ERROR_IS_NUMERIC = -295

_ERROR_MSG_NFOUND = AttributeError("Error: Object not found")
_ERROR_MSG_TYPE = AttributeError("Error: Type of object not compatible")
_ERROR_MSG_ATR = AttributeError("Error: Attribute not compatible")
_ERROR_MSG_PATH = AttributeError("Error: Incorrect file path")
_ERROR_MSG_INCOHERENT = TypeError("Error: Incoherent parameter")
_ERROR_MSG_IS_NUMERIC = TypeError("Error: This function just handle numerical attributes")

# ------------------- GLOBAL PRIVATE VARIABLES -----------------

_swmmDLL = WinDLL("swmm5.dll") # Loads the DLL
_swmmDLL.swmm_get.restype = c_double # Define the return type of the DLL function swmm_get
_swmmDLL.swmm_get_from_input.restype = c_double # Define the return type of the DLL function swmm_get_from_input
_elapsedTime = c_double(0.000001) # Elapsed time in decimal days
_ptrTime = pointer( _elapsedTime ) # Pointer to elapsed time
_start_time = time() # Simulation start time
_end_time = time() # Simulation end time
_pattern = re.compile(".inp", re.IGNORECASE) # Used to create paths for report and output files
_type_constants = (JUNCTION, SUBCATCH, NODE, LINK, STORAGE, ORIFICE, OUTFALL,)
_unit_constants = (US, SI, DIMENSIONLESS, )
_attribute_constants = (DEPTH, VOLUME, FLOW, SETTING, FROUDE, INFLOW, FLOODING, PRECIPITATION, RUNOFF, LINK_AREA,)
_report_constants = (NO_REPORT, WRITE_REPORT,)
_input_file_constants = (INVERT, DEPTH_SIZE, STORAGE_A, STORAGE_B, STORAGE_C, LENGTH, ROUGHNESS, IN_OFFSET, OUT_OFFSET,
						AREA, IMPERV, WIDTH, SLOPE, OUTLET, FROM_NODE, TO_NODE,)

#############################################################################################
# Useful Data Structures
#############################################################################################

class SWMMTree:
	'''Tree data structure for a SWMM network'''
	class Node:
		'''Node object for the tree data structure'''
		def __init__(self, container, node_id, invert, parent = None, length = 0):
			'''
			Constructor:
				Inputs:
				- container (SWMMTree) - It is the tree whose the node is going to belong
				- node_id	(str)	   - ID of the node, the same from SWMM
				- invert	(float)	   - Invert elevation of the node
				- parent	(*Node)	   - Pointer to the parent of the node
				- length	(float)	   - Lenght between the node and its parent (conduit lenght)
			'''
			self.container = container
			self.id = node_id
			self.invert = invert
			self.parent = parent
			if parent and length == 0:
				raise ValueError('The length of the parent conduit is needed')
			self.length = length
			self.children = [] # List of the children of the Node

	def __init__(self):
		'''Constructor of the SWMMTree class'''
		self.size = 0
		self.root = None

	def validate(self, node):
		'''Checks if a node belongs to the Tree, or if it has been deleted'''
		if node.container is not self:
			raise ValueError('The node does not belong to this container')
		if node.parent is node:
			raise ValueError('This node is no longer valid')
		return node

	def root(self):
		return self.root

	def parent(self, node):
		node = self.validate(node)
		return node.parent

	def children(self, node):
		node = self.validate(node)
		return node.children

	def add_root(self, root_id, invert = 0):
		'''Adds a root node to the Tree if it does not exist'''
		if self.root: raise ValueError('Root Exists')
		self.size = 1
		self.root = self.Node(self, root_id, invert)
		return self.root

	def add_child(self, node, child_id, length, invert = 0):
		'''Adds a child to the children list of a node'''
		if length <= 0:
			raise ValueError('Length must be a value higher than zero')
		node = self.validate(node)
		self.size += 1
		child = self.Node(self, child_id, invert, node, length)
		node.children.append(child)
		return node.children

class SWMMGraph:
	'''Graph data structure for a SWMM network'''

	class Node:
		'''Node object for the graph data structure'''
		def __init__(self, node_ID, invert):
			self.id = node_ID
			self.invert = invert
			self.neighbors = []

	class Link:
		'''Link object for the graph data structure'''
		def __init__(self, link_ID, length):
			self.id = link_ID
			self.length = length

	def __init__(self):
		'''Constructor of the SWMMGraph class'''
		self.nodes = {} # Table with references to node objects, i.e. {'Node_ID' : <*pointer_to_node>}
		self.links = {} # Table with references to link objects, i.e. {'Link_ID' : <*pointer_to_link>}

	def __len__(self):
		return len(self.nodes)

	def add_node(self, node_ID, invert):
		if node_ID not in self.nodes:
			self.nodes[node_ID] = self.Node(node_ID, invert)

	def add_link(self, link_ID, length):
		if link_ID not in self.links:
			self.links[link_ID] = self.Link(link_ID, length)

	def modify_link_ID(self, old_ID, new_ID):
		if old_ID not in self.links:
			raise ValueError('The link does not belong to this graph')
		link = self.links[old_ID]
		self.links.pop(old_ID)
		self.links[new_ID] = link

	def modify_node_ID(self, old_ID, new_ID):
		if old_ID not in self.nodes:
			raise ValueError('The node does not belong to this graph')
		node = self.nodes[old_ID]
		self.nodes.pop(old_ID)
		self.nodes[new_ID] = node

	def add_neighbor(self, node, neighbor, nInvert, link_ID, length):
		if node not in self.nodes:
			raise ValueError('The main node does not belong to this graph')
		if neighbor not in self.nodes:
			self.add_node(neighbor, nInvert)
		if link_ID not in self.links:
			if length < 0:
				raise ValueError('Length must be a positive value')
			self.add_link(link_ID, length)
		n1 = self.nodes[node]
		n2 = self.nodes[neighbor]
		if neighbor not in n1.neighbors:
			n1.neighbors.append( (neighbor, link_ID) ) ; n2.neighbors.append( (node, link_ID) )

	def get_neighbors(self, node):
		if node not in self.nodes:
			raise ValueError('The node does not belong to this graph')
		n = self.nodes[node].neighbors
		return [n[i][0] for i in xrange(len(n))]

	def get_length(self, link_ID):
		if link_ID not in self.links:
			raise ValueError('The link does not belong to this graph')
		return self.links[link_ID].length

#############################################################################################
# Useful functions related to Data Structures
#############################################################################################

def create_graph(inp):
	g = SWMMGraph()
	lFrom = get_all(inp, LINK, FROM_NODE)
	lTo = get_all(inp, LINK, TO_NODE)
	llength = get_all(inp, LINK, LENGTH)
	oFrom = get_all(inp, ORIFICE, FROM_NODE)
	oTo = get_all(inp, ORIFICE, TO_NODE)
	links = lFrom.keys()
	orifices = oFrom.keys()

	for link in links:
		n1 = lFrom[link]
		n2 = lTo[link]
		g.add_node( n1 , 0 )
		g.add_neighbor( n1, n2, 0, link, llength[link] )

	for orifice in orifices:
		n1 = oFrom[orifice]
		n2 = oTo[orifice]
		g.add_node( n1, 0 )
		g.add_neighbor( n1, n2, 0, orifice, 0)

	return g

def bfs(graph, start):
	if start not in graph.nodes:
		raise ValueError('The node does not belong to this graph')
	visited, queue = set(), [start]
	while queue:
		vertex = queue.pop(0)
		if vertex not in visited:
			visited.add(vertex)
			queue.extend(graph.get_neighbors(vertex))
	return visited


#############################################################################################
# SWMM DLL default functionality
#############################################################################################

def open_file(inp, msg=False):

	'''
	Inputs:  inp (str) -> Path to the input file .inp
			 msg (Bool)-> Display message in the terminal if True.
	Outputs: None
	Purpose: opens the files required to run a SWMM simulation
	'''

	# Creates paths for the report and the output files
	rpt = _pattern.sub(".rpt", inp)
	out = _pattern.sub(".out", inp)

	error = _swmmDLL.swmm_open(inp, rpt, out)
	if (error != 0):
		raise _ERROR_MSG_PATH
	if msg:
		print "Openning SWMM  -  OK"


def start(write_report, msg=False):

	'''
	Inputs:  write_report (int) -> swmm.py constant related to the write report
			 file option.
			 msg (Bool)-> Display message in the terminal if True.
	Outputs: None
	Purpose: starts a SWMM simulation. Raise Exception if there is an error.
	'''

	# Parameter Error
	if write_report not in _report_constants:
		raise _ERROR_MSG_INCOHERENT

	_start_time = time()
	error = _swmmDLL.swmm_start(write_report)
	if (error != 0):
		raise SystemError ("Error %d occured during the initialization of the simulation" % error)
	if msg:
		print "Initializing SWMM  -  OK"


def run_step():

	'''
	Inputs:  None
	Outputs: None
	Purpose: advances the simulation by one routing time step. Raise Exception
			 if there is an error.
	'''

	error = _swmmDLL.swmm_step(_ptrTime)
	if (error != 0):
		raise SystemError ("Error %d ocurred at time %.2f" % (error, _elapsedTime.value))


def end(msg=False):

	'''
	Inputs:  msg (Bool)-> Display message in the terminal if True.
	Outputs: None
	Purpose: ends a SWMM simulation. Raise Exception if there is an error.
	'''

	error = _swmmDLL.swmm_end()

	if (error != 0):
		raise SystemError ("Error %d: The simulation can not be ended" % error)
	_end_time = time()
	if msg:
		print ("Correctly Ended in %.2f seconds!" % (_end_time - _start_time))


def save_report(msg=False):

	'''
	Inputs:  msg (Bool)-> Display message in the terminal if True.
	Outputs: None
	Purpose: writes simulation results to report file. Raise Exception if there is an error.
	'''

	error = _swmmDLL.swmm_report()

	if (error != 0):
		raise SystemError ("Error %d: The report file could not be written correctly" % error)
	if msg:
		print ("Report file correctly written!")


def close(msg=False):

	'''
	Inputs:  msg (Bool)-> Display message in the terminal if True.
	Outputs: None
	Purpose: closes a SWMM project. Raise Exception if there is an error.
	'''

	error = _swmmDLL.swmm_close()
	if (error != 0):
		raise SystemError ("Error %d: The file can not be closed correctly" % error)
	if msg:
		print ("Correctly Closed!")


def get_mass_bal_error():

	'''
	Inputs: None.
	Outputs: _ (tuple) -> Values of the errors related to mass balance.
			 			  [0] -> Runoff error
			 			  [1] -> Flow error
			 			  [2] -> Quality error
	Purpose: gets the mass balance errors of the simulation.
	'''

	runOffErr = c_float(0)
	flowErr = c_float(0)
	qualErr = c_float(0)
	ptrRunoff = pointer(runOffErr)
	ptrFlow = pointer(flowErr)
	ptrQual = pointer(qualErr)

	error = _swmmDLL.swmm_getMassBalErr(ptrRunoff, ptrFlow, ptrQual)
	if (error != 0):
		raise SystemError ("Error %d: The errors can not be retrieved" % error)

	return (runOffErr.value, flowErr.value, qualErr.value)


#############################################################################################
# Getters & Setters
#############################################################################################

def get(object_id, attribute, unit_system):

	'''
	Inputs:  object_id	 (str) -> ID of the object, as saved in SWMM.
			 attribute 	 (int) -> swmm.py constant, related to the attribute of the object.
			 unit_system (int) -> swmm.py constant, related to the units of the attribute that is going
			 					  to be retrieved.
	Outputs: _ (double) -> This is the value of the attribute being sought.
	Purpose: returns the value of the attribute.
	'''

	# Parameter error
	if attribute not in _attribute_constants:
		raise _ERROR_MSG_INCOHERENT
	elif unit_system not in _unit_constants:
		raise _ERROR_MSG_INCOHERENT

	value =  _swmmDLL.swmm_get(object_id, attribute, unit_system)

	# Handling errors
	if value == _ERROR_NFOUND:
		raise _ERROR_MSG_NFOUND
	elif value == _ERROR_TYPE:
		raise _ERROR_MSG_TYPE
	elif value == _ERROR_ATR:
		raise _ERROR_MSG_ATR

	return value

def get_from_input(input_file, object_id, attribute):
	'''
	Inputs:  input_file  (str) -> Path to input file.
             object_id   (str) -> ID of the object, as saved in SWMM.
	 	     attribute   (int) -> constant, related to the attribute of the object.
	Outputs: value (double) -> This is the value of the attribute being sought in the input file.
	Purpose: returns the value of the attribute in the input file.
	'''
	# Parameter error
	if attribute not in _input_file_constants:
		raise _ERROR_MSG_INCOHERENT

	value = _swmmDLL.swmm_get_from_input(input_file, object_id, attribute)
	if value == _ERROR_NFOUND:
		raise _ERROR_MSG_NFOUND
	elif value == _ERROR_TYPE:
		raise _ERROR_MSG_TYPE
	elif value == _ERROR_ATR:
		raise _ERROR_MSG_ATR
	elif value == _ERROR_PATH:
		raise _ERROR_MSG_PATH
	elif value == _ERROR_IS_NUMERIC:
		raise _ERROR_MSG_IS_NUMERIC

	return value


def get_all(input_file, object_type, attribute=-1, save_file=False):
	'''
	Inputs:  input_file  (str) -> Path to input file.
             object_type (int) -> constant, related to the type of the object.
	 	     attribute   (int) -> constant, related to the attribute of the object.
	Outputs: all_list	 (dict/list)
							-> If (list) -> List of all the objects of type "object_type"
							-> If (dict) -> Dictionary with all the objects of type "object_type"
											as keys. The values are the attributes "attribute" of
											each object.
	Purpose: returns an iterable object (dict/list) with the information that was requested.
			 If attribute == -1 -> Returns a list.
	'''

	# Parameter error
	if attribute != -1:
		if attribute not in _input_file_constants:
			raise _ERROR_MSG_INCOHERENT
	elif object_type not in _type_constants:
		raise _ERROR_MSG_INCOHERENT

	# Saves requested info in a temporal file
	error = _swmmDLL.swmm_save_all(input_file, object_type, attribute)

	# Handling errors
	if (error == _ERROR_PATH):
		raise _ERROR_MSG_PATH
	elif (error == _ERROR_NFOUND):
		remove('info.dat')
		raise _ERROR_MSG_NFOUND
	elif (error == _ERROR_ATR):
		remove('info.dat')
		raise _ERROR_MSG_ATR
	elif (error == _ERROR_TYPE):
		remove('info.dat')
		raise _ERROR_MSG_TYPE

	# Initializes iterable object to be returned
	if (attribute == -1):
		all_list = []
	else:
		all_list = {}

	# Retrieves information from the data file
	# Saves the information in the iterable object
	with open('info.dat') as info_file:
		for line in info_file:
			if (attribute == -1):
				all_list.append(line.strip())
			else:
				l = line.split(" ")
				key = l[0]
				if attribute not in (OUTLET, FROM_NODE, TO_NODE,):
					value = float(l[1])
				else:
					value = l[1].strip('\n')
				all_list.update({key: value})

	info_file.close()

	# Deletes the file if not requested.
	if not save_file:
		remove('info.dat')

	return all_list # Return iterable


def modify_settings(orifices_ids, new_settings):

	'''
	Inputs:  orifices_ids	(str)    -> List of orifices IDs, as saved in SWMM.
			 new_setting 	(double) -> List of Percentage of openning of the orifices.
	Outputs: None.
	Purpose: modifies the setting of an orifice during the simulation.
	'''

	if type(orifices_ids) in (tuple, list):
		if len(orifices_ids) > 0:
			if type(orifices_ids[0]) == str:
				pass
			else:
				raise _ERROR_MSG_INCOHERENT
		else:
			raise _ERROR_MSG_INCOHERENT
	elif type(orifices_ids) is str:
		modify_setting(orifices_ids, new_settings)
	else:
		raise _ERROR_MSG_INCOHERENT


	for i in range(len(orifices_ids)):
			modify_setting(orifices_ids[i], new_settings[i])

def modify_input(input_file, object_id, attribute, value):

	'''
	Inputs:  input_file  (str)    -> Path to the input file.
			 object_id	 (str)    -> ID of the object that is going to be changed.
			 attribute   (int)    -> Constant - Attribute that is going to be changed.
			 value       (double) -> Value of the attribute that is going to be changed.
	Purpose: It modifies a specific attribute from the input file.
	'''
	# Parameter error
	if attribute not in _input_file_constants:
		raise _ERROR_MSG_INCOHERENT

	new_value = c_double(value)
	error =  _swmmDLL.swmm_modify_input(input_file, object_id, attribute, new_value)
	if error == _ERROR_NFOUND:
		raise _ERROR_MSG_NFOUND
	elif error == _ERROR_TYPE:
		raise _ERROR_MSG_TYPE
	elif error == _ERROR_ATR:
		raise _ERROR_MSG_ATR
	elif error == _ERROR_PATH:
		raise _ERROR_MSG_PATH

#############################################################################################
# Enhanced Functionality
#############################################################################################

def initialize(inp):
	open_file(inp)  # Step 1
	start(WRITE_REPORT)  # Step 2

def finish():
	end()  # Step 4
	errors = get_mass_bal_error()  # Step 5
	save_report()  # Step 6
	error = _swmmDLL.swmm_save_results()
	close()  # Step 7
	return errors

def cosimulate(input_file, step_actions, variables_iterable, attributes, units, time_resolution = 1, show_error = False):
	'''
	Inputs:  input_file   		(str) 			-> Path to input file.
             step_actions 		(fcn) 			-> Function with instructions to manipulate variables during simulation.
	 	     variables_iterable (list/dict) 	-> constant, related to the attribute of the object.
	 	     attributes 		(list/dict/num)	-> constant or list of constants, related to the attribute of the object.
	 	     units 				(int)			-> constant, related to the units of the simulation.
	 	     time_resolution	(int)			-> sampling time in seconds,
	 	     show_error			(Bool)			-> prints the errors of the simulation on the terminal.
	Outputs: time 				(float[])		-> vector of time in hours.
			 vectors 			(nD Array)		-> n-dimensional array with the value the attributes requested by the user.
			 errors 			(tuple)			-> Values of the errors related to mass balance. [0] -> Runoff error [1] -> Flow error [2] -> Quality error
	Purpose: Runs a SWMM simulation, modify parameters during the simulation, retrieves information during the simulation.
			 Raises Exception if there is an error.
	'''

	time_resolution = int(time_resolution)

	# Parameter Errors.
	if units not in _unit_constants:
		raise _ERROR_MSG_INCOHERENT
	elif time_resolution < 1:
		raise _ERROR_MSG_INCOHERENT


	# Dynamic handling of data types
	if(variables_iterable == None):
		v_size = 0
	else:
		if type(variables_iterable) == dict:
			variables = variables_iterable.keys()
		elif type(variables_iterable) in (list, tuple):
			variables = variables_iterable
		else:
			raise _ERROR_MSG_INCOHERENT

	# Dynamic handling of attributes data type.
	if type(attributes) in (tuple, list):
		ATTRIBUTE_ITERABLE = True
		# Check errors
		for a in attributes:
			if a not in _attribute_constants:
				raise _ERROR_MSG_ATR
	# Single attribute request
	elif type(attributes) == int:
		ATTRIBUTE_ITERABLE = False
		# Check errors
		if attributes not in _attribute_constants:
			raise _ERROR_MSG_ATR
	else:
		return _ERROR_MSG_INCOHERENT

	# Allocating memory for the requested vectors
	if ATTRIBUTE_ITERABLE:
		vectors = []
		# Allocate space in the matrix
		for i in range(len(attributes)):
			vectors.append( [[] for j in range(len(variables))] )
	else:
		vectors = [[] for i in range(len(variables))] # Creates MxN Array -> M: len(variables) N: len(attributes)

	# Run starts
	open_file(input_file, False)  # Step 1
	start(WRITE_REPORT, False)  # Step 2
	time = []

	while( not is_over() ):
		# ----------------- Run step and run the actions given by the user -----------
		time_step = int(get_time()*3600*100)/100 # Get time_step in seconds as an integer
		if ( int(time_step % time_resolution) == 0): # Checks sampling time
			time.append(get_time())
		run_step()  # Step 3

		# -------- Retrieves the variables requested by the user --------
		# The variables are saved in accordance with the time resolution variable
		if ( int(time_step % time_resolution) == 0): # Checks sampling time
			if (variables_iterable != None):
				for i in range(len(variables)):
					# Dynamic handling
					if ATTRIBUTE_ITERABLE:
						for j in range(len(attributes)):
							vectors[j][i].append(  get(variables[i], attributes[j], units) )
					else:
						vectors[i].append( get(variables[i], attributes, units) )

		# -------- Implements Control Actions if exist -----------
		if (step_actions != None):
			step_actions()

	errors = finish()

	# --------- Prints simulation error if requested ----------

	if(show_error):
		print "\n		Runoff error: %.2f %%\n\
		Flow routing error: %.2f %%\n \
		Quality routing error: %.2f %%\n" % (errors[0], errors[1], errors[2])

	return time, vectors, errors


def find_max(iterable):
	'''
	Purpose: determines the max value of an iterable object.
	'''
	return _find(iterable, True)


def find_min(iterable):
	'''
	Purpose: determines the max value of an iterable object.
	'''
	return _find(iterable, False)

def get_link_area(input_file, link_id, units):
	'''
	Inputs: input_file  (str/list) -> Path to the input file.
			object_id	(str) 	   -> ID of the object, as saved in SWMM.
			unit_system (int) 	   -> swmm.py constant, related to the units of the attribute that is going
			 					  	  to be retrieved.
	Outputs: value of area or list with the values of areas.
	Purpose: return the crossed section area of a conduit
	'''
	initialize(input_file)
	run_step()
	if isinstance(link_id, (tuple, list, set)):
		areas = []
		for link in link_id:
			areas.append( get(link, LINK_AREA, units) )
		finish()
		return areas
	area = get(link_id, LINK_AREA, units); finish()
	return area

#############################################################################################
# Auxiliar Functions
#############################################################################################

def is_over():
	'''
	Inputs: None
	Outputs: _ (Bool) -> True if the simulation is over, False otherwise
	Purpose: determines if the simulation is over or not.
	'''

	return _elapsedTime.value == 0.0


def get_time():
	'''
	Inputs: None
	Outputs: _ (float) -> Value of the current time of the simulation in hours.
	Purpose: returns the current hour of the simulation.
	'''
	return _elapsedTime.value*24


def _find(iterable, is_max):
	'''
	Inputs:  iterable 	(list/dict)  -> Iterable object with float values. It can be a 3/2-dimensional Array too.
			 is_max 	(Bool)		 -> Define the type of search: the max. or the min.
	Outputs: max/min 	(float)		 -> Max. or min. value of the iterable.
	Purpose: Determine the max or the min of an iterable object.
	'''

	error_msg = Exception("The type of the parameter is not iterable or it does not contain numbers")

	# If iterable is a dict
	if type(iterable) == dict:
		if len(iterable)>0:
			values = iterable.values()
			ARRAY_DICT = True
			if type(values[0]) not in (int, float):
				raise error_msg
		else:
			raise error_msg
	else:
		ARRAY_DICT = False
		# Defining dimension of iterable
		try:
			iterable[0][0][0][0]
			raise _ERROR_MSG_INCOHERENT
		except:
			try:
				iterable[0][0][0]
				values = iterable[0][0]
				ARRAY_3D = True
			except:
				ARRAY_3D = False
				try:
					iterable[0][0]
					values = iterable[0]
					ARRAY_2D = True
				except:
					values = iterable
					ARRAY_1D = True
					ARRAY_2D = False

	# Error Handling
	if not ARRAY_DICT:
		if type(values) in (list, tuple):
			if len(values)>0:
				if type(values[0]) not in (int, float):
					raise error_msg
				else:
					values = iterable
			else:
				raise error_msg
		else:
			raise error_msg

	# Calculates the maximum depending on the data type.
	if ARRAY_3D:
		indexes = []
		optimals = []
		for v in values:
			if is_max:
				maximum = map(max, v)
				optimal = max(maximum)
				optimals.append(optimal)
				indexes.append(maximum.index(optimal))
			else:
				minimum = map(min, v)
				optimal = min(minimum)
				optimals.append(optimal)
				indexes.append(minimum.index(optimal))
		return optimals, indexes
	elif ARRAY_2D:
		if is_max:
			maximum = map(max, values)
			optimals = max(maximum)
			indexes = maximum.index(optimals)
		else:
			minimum = map(min, values)
			optimals = min(minimum)
			indexes = minimum.index(optimals)
		return optimals, indexes
	elif ARRAY_1D:
		if is_max:
			optimals = max(values)
			indexes = values.index(optimals)
			if ARRAY_DICT:
				indexes = iterable.keys()[indexes]
		else:
			optimals = min(values)
			indexes = values.index(optimals)
			if ARRAY_DICT:
				indexes = iterable.keys()[indexes]
		return optimals, indexes

def modify_setting(orifice_id, new_setting):

	'''
	Inputs:  orifice_id  (str)    -> ID of the orifice, as saved in SWMM.
			 new_setting (double) -> Percentage of openning of the orifice.
	Outputs: None.
	Purpose: modifies the setting of an orifice during the simulation.
	'''

	target = c_double(new_setting)
	tstep  = c_double(0)
	error = _swmmDLL.swmm_modify_setting(orifice_id, target, tstep)
	if error == _ERROR_INCOHERENT:
		raise _ERROR_MSG_INCOHERENT
	elif error == _ERROR_NFOUND:
		raise _ERROR__MSG_NFOUND