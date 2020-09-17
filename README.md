**MatSWMM** is an open-source Matlab, Python, and LabVIEW-based software package for the analysis and design of real-time control (RTC) strategies in urban drainage systems (UDS). MatSWMM includes control-oriented models of UDS, and the storm water management model (SWMM) of the US Environmental Protection Agency (EPA), as well as systematic-system edition functionalities. Furthermore, MatSWMM is also provided with a population-dynamics-based controller for UDS with three of the fundamental dynamics, i.e., the Smith, projection, and replicator dynamics. The simulation algorithm, and a detailed description of the features of MatSWMM are presented in this wiki in order to illustrate the capabilities that the tool has for educational and research purposes.

### Check out our last [publication](http://www.sciencedirect.com/science/article/pii/S1364815216301451)!

## Resources

* [Overview](https://github.com/water-systems/MatSWMM/wiki/Overview)
* [Functionalities](https://github.com/water-systems/MatSWMM/wiki/Functionalities)
* [Constants](https://github.com/water-systems/MatSWMM/wiki/Constants)

## What is this repository for?

* Project:  MatSWMM
* Version:  1.0
* Date:     06/23/14
* License:  GNU General Public License v3.0

This is an open source toolbox with basic functions to compute cosimulation processes with SWMM. The main goal of this module is to allow its users to design optimization models and real time control systems, for drainage systems (e.g. it can be used to link SWMM with ArcGIS).

### How do I get set up?

##### MatSWMM for Matlab

>1. Download the repo
>2. Select your toolbox DLL depending on your Matlab architecture (32bits or 64bits)
>3. Save the "swmm.dll" and the "swmm.h" files in the "SWMM Matlab" folder
>4. Create a SWMM object to use the functionalities

> ```matlab
> swmm = SWMM;
> ```

>* Check the example file, run it and learn its structure to develop a new project with SWMM for Matlab

##### MatSWMM for Python

> 1. Download swmm.py and swmm.dll (Be careful saving the files, both have to be saved in the same folder)
> 2. Import swmm.py 

> ```python

> import swmm
> # Or import everything directly
> from swmm import *
> ```
>* You got set up! If you need help read the documentation of the module and its functions
>* Try the demo - example.py

##### MatSWMM for LabVIEW

> 1. Download all the files from the [LabVIEW module folder](https://github.com/water-systems/MatSWMM/tree/master/MatSWMM%205.1.009/LabVIEW%20module/x64), (if your system is Win32 download the [appropiate DLL](https://github.com/water-systems/MatSWMM/blob/master/MatSWMM%205.1.009/LabVIEW%20module/x86/swmm5.dll) for your system and replace the one that you downloaded from the LabVIEW module folder with it). 
> 2. Open the SWMM_toolkit project file and check the functionalities that are available.

> * That's all, with the downloaded files you can now run the _example.vi_ file.

### Who do I talk to? ###

If you have any doubt or you want to fork the repo for new DLL functions, please send an email to:

* Gerardo Riaño Briceño - ga.riano949@uniandes.edu.co
