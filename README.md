# Deformable Mirrors

## SMXM7X API
The SMXM7X API folder contains scripts for using a Sumix M7x model (M71,M72,M73) CMOS camera in Python scripts. It was coded following [this](https://riptutorial.com/cython/example/11296/wrapping-a-dll--cplusplus-to-cython-to-python) tutorial.

Our system specifications and files/programs used:
- Windows 10
- Python (32-bit) version 3.7
- [the cython package](https://cython.org/)
- Python Imaging Library (PIL)
- numpy
- SMXM7X API files (included in this repo)
- [MinGW](http://www.mingw.org/) for the compilers

The SMX7MX.h, SMXM7X.c, SMXM7X.cpp and associated SMXM7X.dll contain the camera source code. In particular, refer to the SMXM7X.h for a full list of available functionality. The SMXM7X.pyx and SMX7MX.pxd file contain the pseudo-C/python code written to use the original C/C++ code in python. To compile these files, run the setup.py file in a command line as follows:

'''
python setup.py build_ext --inplace
'''

This will produce a file called SMXM7X.pyd, which behaves like a standard python module. Copy this file and the SMXM7X.dll file to the same location as your python script. An example on how a to use python to take a picture is given below, and in the example module called "testmodule.py".

'''python
import SMXM7X
camera = SMXM7X.Cam()
camera.OpenDevice()
snap = camera.GetSnapshot()
'''
