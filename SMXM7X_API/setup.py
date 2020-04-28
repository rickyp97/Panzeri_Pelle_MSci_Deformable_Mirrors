"""
This script builds the python "SMXM7X" module from the SMXM7X.pyx source file to access a SUMIX M7x camera
Run in command line as follows:
python setup.py build_ext --inplace

copy the resulting SMXM7X.pyd file and the SMXM7X.dll file to the directory
of your python script and import the SMXM7X module as a normal python module.
Refer to the testmodule.py for an example of usage
"""

print("Compiling SMXM7X wrapper...")

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [
    Extension('SMXM7X',
              ['SMXM7X.pyx'],
              # Note here that the C++ language was specified
              # The default language is C
              language="c++",  
              libraries=['SMXM7X'],
              library_dirs=['.'])
    ]

setup(
    name = 'SMXM7X',
    cmdclass = {'build_ext': build_ext},
    ext_modules = ext_modules,
)
