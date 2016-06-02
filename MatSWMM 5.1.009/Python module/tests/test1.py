import tswmm as swmm

'''
	This script is used to check the functionality of basic functionalities
	related to the SWMM algorithm.
	1 - A .inp file is opened
	2 - The swmm framework is initialized
	3 - The simulation is run step by step
	4 - The simulation is ended
	5 - Mass balance errors are displayed
	6 - The framework is closed and memory is free
'''

inp = '3tanks.inp'
swmm.open_file(inp)
swmm.start(1)
swmm.run_step()

while not swmm.is_over():
	swmm.run_step()
	print swmm._elapsedTime

swmm.end()
print swmm.get_mass_bal_error()
swmm.close()