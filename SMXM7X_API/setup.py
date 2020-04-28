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


#from distutils.core import setup
#from Cython.Build import cythonize
#
#setup(
#    ext_modules = cythonize("SMXM7X.pyx", language='c++', libraries = ['SMXM7X'])
#)
