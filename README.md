# Deformable Mirrors
This repository contains the code which was used throughout the project to control a 5 channels deformable mirror and use it to optimise the focal spot of a low power test laser.

## Controlling the Pi
As the DAC board is controlled directly from the Raspberry Pi, the modules "DAC_control_fast_off.py" and "ServoPi.py" contain the commands to change the Pi outputs. 

## Server-Client
As part of the code was ran on a Raspberry Pi 3 and part on a laptop, we set up a simple server-client comunication within the two, with the Pi being the server.
To run the server, simply use a Python 3 shell to run on the Pi the module called "pi_server.py". This will run in a loop waiting for connections from the laptop. Make sure to change the Host variable, which should be the IP address of the Pi.
This module will import "pi_server_functions.py", which also needs the two modules that control the Pi output: "DAC_control_fast_off.py" and "ServoPi.py". 

On the Laptop side, you can either use a simple GUI to change channel voltages ("GUI_laptop.py", simply run it to open the GUI) or run the "pc_server_functions.py" module and use the functions within to communicate with the Pi.


## SMXM7X API
The SMXM7X API folder contains scripts for using a Sumix M7x model (M71,M72,M73) CMOS camera in Python scripts. It was coded following [this](https://riptutorial.com/cython/example/11296/wrapping-a-dll--cplusplus-to-cython-to-python) tutorial. Please recompile these files before using the camera.

Our system specifications and files/programs used:
- Windows 10
- Python (32-bit) version 3.7
- [the cython package](https://cython.org/)
- Python Imaging Library (PIL)
- numpy
- SMXM7X API files (included in this repo)
- [MinGW](http://www.mingw.org/) for the compilers

The SMX7MX.h, SMXM7X.c, SMXM7X.cpp and associated SMXM7X.dll contain the camera source code. In particular, refer to the SMXM7X.h for a full list of available functionality. The SMXM7X.pyx and SMX7MX.pxd file contain the pseudo-C/python code written to use the original C/C++ code in python. To compile these files, run the setup.py file in a command line as follows:

```
python setup.py build_ext --inplace
```

This will produce a file called SMXM7X.pyd, which behaves like a standard python module. Copy this file and the SMXM7X.dll file to the same location as your python script. An example on how a to use python to take a picture is given below, and in the example module called "testmodule.py".

```python
import SMXM7X
camera = SMXM7X.Cam()
camera.OpenDevice()
snap = camera.GetSnapshot()
```
