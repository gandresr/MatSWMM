import tswmm as swmm

'''
	This script is used to test the swmm_get_nobjects function
'''

inp = '3tanks.inp'
swmm.open_file(inp)
swmm.start(1)
swmm.run_step()

while not swmm.is_over():
	swmm.run_step()
	#print swmm._elapsedTime

swmm.end()
#print swmm.get_mass_bal_error()

# Tests
assert swmm.nObjects(swmm.SUBCATCH) == 4
assert swmm.nObjects(swmm.NODE) == 13
assert swmm.nObjects(swmm.LINK) == 12
assert swmm.nObjects(swmm.NODE, swmm.JUNCTION) == 7
assert swmm.nObjects(swmm.NODE, swmm.OUTFALL) == 3
assert swmm.nObjects(swmm.NODE, swmm.STORAGE) == 3
assert swmm.nObjects(swmm.NODE, swmm.DIVIDER) == 0
assert swmm.nObjects(swmm.LINK, swmm.CONDUIT) == 9
assert swmm.nObjects(swmm.LINK, swmm.PUMP) == 0
assert swmm.nObjects(swmm.LINK, swmm.ORIFICE) == 3
assert swmm.nObjects(swmm.LINK, swmm.WEIR) == 0
assert swmm.nObjects(swmm.LINK, swmm.OUTLET) == 0

swmm.close()