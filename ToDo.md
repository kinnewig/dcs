# ToDo

## Functionality

### ScaLAPACK
1. At the moment only Scivision ScaLAPACK can be installed, add support for AMD-ScaLAPACK
2. Download Only Option is missing

### MUMPS
1. At the moment only Scivision MUMPS can be installed, add support for AMD-MUMPS

### Dynamic Package Dependencies
At the moment the dependencies of the packages are hard coded in the package/<TPL>.cmake
For example this means, that if you select MUMPS you also have to build ScaLAPACK


## Bugs

### Fedora Support
1. Add missing packages (mpfr-devel)
2. Problem with Symengine (see subsection)

### Git-Problem
Starting with Git v2.30 introduced safe.directory https://git-scm.com/docs/git-config/2.35.2#Documentation/git-config.txt-safedirectory 
at the moment the only work arround ist to disable this behaivior with
git config --global --add safe.directory '*'


### Problem with symengine (Symengine can not be installed on Fedora, CentOS9, Rocky Linux 9 and AlmaLinux 9)
https://github.com/r-lib/testthat/issues/1373
</path/to/build>/dealii-9.4.1/symengine/source/symengine/utilities/catch/catch.hpp:6546:33: error: size of array ‘altStackMem’ is not an integral constant-expression
