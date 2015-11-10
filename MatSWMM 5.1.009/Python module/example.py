# Imported modules
import swmm  # The SWMM module
import matplotlib.pyplot as plt  # Module for plotting

# ***********************************************************************
#  Declaration of simulation files and variables
# ***********************************************************************

inp    = "swmm_files/3tanks.inp"  # Input file
flow   = []
vol    = []
time   = []

# ***********************************************************************
#  Initializing SWMM
# ***********************************************************************

swmm.initialize(inp)  # Step 1

# ***********************************************************************
#  Step Running
# ***********************************************************************

# Main loop: finished when the simulation time is over.
while( not swmm.is_over() ): 

	# ----------------- Run step and retrieve simulation time -----------
	
	time.append( swmm.get_time() )
	swmm.run_step()  # Step 2
	
	# --------- Retrieve & modify information during simulation ---------
	# Retrieve information about flow in C-5
	f = swmm.get('C-5', swmm.FLOW, swmm.SI)   
	# Stores the information in the flow vector
	flow.append(f)					 
	# Retrieve information about volume in V-1
	v = swmm.get('V-1', swmm.VOLUME, swmm.SI) 
	# Stores the information in the volume vector
	vol.append(v)					 

	# --------------------------- Control Actions ------------------------
	
	# If the flow in C-5 is greater or equal than 2 m3/s the setting 
	# upstream of the link is completely closed, else it is completely 
	# opened.

	if f >= 2:
		swmm.modify_setting('R-4', 0)
	else:
		swmm.modify_setting('R-4', 1)

# ************************************************************************
#  End of simulation
# ************************************************************************

errors = swmm.finish() # Step 3

# ************************************************************************
#  Interacting with the retrieved data
# ************************************************************************

print "\n	Runoff error: %.2f %%\n \
	Flow routing error: %.2f %%\n \
	Quality routing error: %.2f %%\n" % (errors[0], errors[1], errors[2])
       
plt.plot(time, flow)
plt.title('C-5 flow [m3/s]')
plt.xlabel('Time [hours]')
plt.show()