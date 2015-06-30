# Imported modules
from swmm import *  # The SWMM module
import matplotlib.pyplot as plt  # Module for plotting

# ***********************************************************************
#  Declaration of simulation files and variables
# ***********************************************************************

inp    = "swmm_files/3tanks.inp"  # Input file
report = "swmm_files/3tanks.rpt"  # Report file
out    = "swmm_files/3tanks.out"  # Output file
flow   = []
vol    = []
time   = []

# ***********************************************************************
#  Initializing SWMM
# ***********************************************************************

open_file(inp, report, out)  # Step 1
start(NO_REPORT)  # Step 2

# ***********************************************************************
#  Step Running
# ***********************************************************************

# Main loop: finished when the simulation time is over.
while( not is_over() ): 

	# ----------------- Run step and retrieve simulation time -----------
	
	time.append(get_time())
	run_step()  # Step 3
	
	# --------- Retrieve & modify information during simulation ---------
	# Retrieve information about flow in C-5
	f = get(LINK, 'C-5', FLOW, SI)   
	# Stores the information in the flow vector
	flow.append(f)					 
	# Retrieve information about volume in V-1
	v = get(NODE, 'V-1', VOLUME, SI) 
	# Stores the information in the volume vector
	vol.append(v)					 

	# --------------------------- Control Actions ------------------------
	
	# If the flow in C-5 is greater or equal than 2 m3/s the setting 
	# upstream of the link is completely closed, else it is completely 
	# opened.

	if f >= 2:
		modify_setting('R-4', 0)
	else:
		modify_setting('R-4', 1)

# ************************************************************************
#  End of simulation
# ************************************************************************

end()  # Step 4
errors = get_mass_bal_error()  # Step 5
save_report()  # Step 6
close()  # Step 7

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