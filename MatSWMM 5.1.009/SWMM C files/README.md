# SWMM C FILES #

### What is this repository for? ###

It includes the files in C that are required to get the DLL functions used in the toolboxes - the files are for SWMM 5.1:

* cosimulation.c
* cosimulation.h
* swmm5.c (modified)
* swmm5.h (modified)
* swmm5.def (modified)

### How do I get set up? ###

1. Download the SWMM 5.1 source code from: http://www.epa.gov/nrmrl/wswrd/wq/models/swmm/swmm51006_engine.zip

2. Save the repo files in the source code folder "source5_1_006" (replace the repeated files). 

3. Add the new files to the project in your compiler (Visual C++ 2010 is necessary).

4. Finally, compile it as DLL. 

Now you have got set up, you have succesfully modified the SWMM 5.1 code in order to get the DLL for the SWMM toolboxes.

### Who do I talk to? ###

If you have any doubt or you want to fork the repo for new DLL functions, please send an email to:

* Gerardo Riaño Briceño - ga.riano949@uniandes.edu.co