# Imported modules
from swmm import *  # The SWMM module
import matplotlib.pyplot as plt  # Module for plotting
inp = "swmm_files/3tanks.inp"  # Input file

# ****************************************************************************************************
# ********************************** MODIFYING INITIAL CONDITIONS ************************************
# ****************************************************************************************************


#print "The roughness of PLT85723 is: %.3f" % get_from_input(inp, "PLT85723", ROUGHNESS) # 2 ms
#modify_input(inp, "PLT85723", ROUGHNESS, 0.024)
#print "The new roughness of PLT85723 is: %.3f" % get_from_input(inp, "PLT85723", ROUGHNESS) # 2 ms

# ****************************************************************************************************
# ******************************** RUNNING A SIMULATION WITH CONTROL *********************************
# ****************************************************************************************************

# Control Actions
#def control_actions():
#	if get("PLC94199-2", FLOW, SI) > 0.015:
#		modify_setting("PLC94199-2", 0)
# Running the simulation
conduits = get_all(inp, LINK) # 80 ms
v_time, values, errors = cosimulate(inp, None, ('C-5',), FLOW, SI) # 12 s

print len(values[0])
print len(v_time)
plt.plot(v_time, values[0])
plt.title('Flujo en C-5 [m3/s]')
plt.xlabel('Tiempo [horas]')
plt.show()

# ****************************************************************************************************
# ************************************** GETTING OPTIMAL VALUES **************************************
# ****************************************************************************************************

#maximum, max_index = find_max(values) # 20 ms
#minimum, min_index = find_min(values) # 20 ms
#print ( "The maximum flow registered is %.2f m3/s from conduit %s" % (maximum[0], conduits[max_index[0]]) )
#print ( "The minimum flow registered is %.2f m3/s from conduit %s" % (minimum[0], conduits[min_index[0]]) )

# ****************************************************************************************************
# ************************************* PLOTTING THE RESULTS *****************************************
# ****************************************************************************************************

#for v in values[0]: # Plotting flows
#	plt.plot(v_time, v)
#plt.show()
#for v in values[1]: # Plotting Froude numbers
#	plt.plot(v_time, v)
#plt.show()