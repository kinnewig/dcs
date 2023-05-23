cmake_minimum_required(VERSION 3.24) #minimum 3.19 for MUMPS

project(dcs VERSION 1.0.0 LANGUAGES Fortran C CXX)
################################################################################
##Policies includes and default variables                                     ##
################################################################################
cmake_policy(SET CMP0057 NEW)
cmake_policy(SET CMP0135 NEW)  #<-- Requires CMake Verision > 3.24

include(ExternalProject)
include(FetchContent)
include(GNUInstallDirs)
include(ProcessorCount)

# Include our own macros
add_subdirectory(macros)

# Include the macros to build TPLS
add_subdirectory(packages)

# Include the macros to build applications
add_subdirectory(applications)

#set Install prefix to install subdirectory of build dir.
if(NOT CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX
      "${CMAKE_BINARY_DIR}/install"
      CACHE STRING "Final install location." FORCE)
endif()

# Try to get the compiler
if(NOT DEFINED MPI_C_COMPILER OR NOT DEFINED MPI_CXX_COMPILER OR NOT DEFINED MPI_Fortran_COMPILER)
  message("No specific MPI Compiler defined, searching the system")
  find_package(MPI)
  if(MPI_FOUND)
    message("MPI found with the following compilers")
    set(CMAKE_MPI_C_COMPILER ${MPI_C_COMPILER})
    set(CMAKE_MPI_CXX_COMPILER ${MPI_CXX_COMPILER})
    set(CMAKE_MPI_Fortran_COMPILER ${MPI_Fortran_COMPILER})
    print(CMAKE_MPI_C_COMPILER)
    print(CMAKE_MPI_CXX_COMPILER)
    print(CMAKE_MPI_Fortran_COMPILER)
  else()
    message(WARNING "MPI not found, please specify compilers!")
    return()
  endif()
endif()

# If NUM_BUILD_JOBS not specified grab number of processors on machine
# and leave 2 for tasks other than building. 
# If this slows your machine too much try even fewer.
ProcessorCount(PROCESSOR_COUNT)
MATH(EXPR PROCESSOR_COUNT "${PROCESSOR_COUNT}-2")
if(PROCESSOR_COUNT LESS 1)
  set(PROCESSOR_COUNT 1)
endif()

set(NUM_BUILD_JOBS ${PROCESSOR_COUNT} CACHE STRING 
      "Number of build jobs '-j <n>'")

# Remark: CMAKE_BUILD_PARALLEL_LEVEL only defines the maximum number of parallel jobs, 
#         therfore this line is not usefull
#set(CMAKE_BUILD_PARALLEL_LEVEL ${NUM_BUILD_JOBS})
if(NOT DEFINED THREAD_COUNT)
  set(THREAD_COUNT "1")
endif()
#set(DEFAULT_BUILD_COMMAND cmake --build . --config release --parallel ${THREAD_COUNT})

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
  set(DEFAULT_BUILD_COMMAND "$(MAKE)" )
else()
  set(DEFAULT_BUILD_COMMAND cmake --build . --config release) 
endif()

################################################################################
## USER SPECIFIED THIRD PARTY LIBRARIES AND APPLICATIONS                      ##
################################################################################
#Only download and extract (needed for cluster machines w.o. web access)
set(DOWNLOAD_ONLY FALSE) 
set(INSTALL_TPLS "") #For safety reset this variable
set(INSTALL_APPS "") #For safety reset this variable

##GEOMETRY/CAD PACKAGES
#list(APPEND INSTALL_TPLS "assimp")
#list(APPEND INSTALL_TPLS "gmsh")
list(APPEND INSTALL_TPLS "opencascade")

## Basic Linear Algebra
list(APPEND INSTALL_TPLS "openblas")

##Parallel Tools
list(APPEND INSTALL_TPLS "p4est")
list(APPEND INSTALL_TPLS "parmetis")
list(APPEND INSTALL_TPLS "scalapack")

##Solvers/Linear Algebra
#list(APPEND INSTALL_TPLS "ginkgo") 
list(APPEND INSTALL_TPLS "mumps")
list(APPEND INSTALL_TPLS "superlu_dist")

##Parallel Linear Algebra Packages
list(APPEND INSTALL_TPLS "trilinos")

##Advanced Maths packages
#list(APPEND INSTALL_TPLS "adolc") 
#list(APPEND INSTALL_TPLS "arpack") 
#list(APPEND INSTALL_TPLS "sundials")  
#list(APPEND INSTALL_TPLS "symengine")

##Output
#list(APPEND INSTALL_TPLS "hdf5")

##Applications using deal.II
#list(APPEND INSTALL_APPS "aspect")

## Get Versions
include(TLS_VERSIONS.cmake)


################################################################################
## ROUTINES FOR CHECKING AND BUILDING DEPENDENCIES OF DEAL_II                 ##
################################################################################

# Sadly this seems to be extrem buggy...
#Fetch cpu info cmake project and use get cpu info from there
#message("checking for cpu vendor")
#FetchContent_Declare(
#  CmakeCpuDetection
#  GIT_REPOSITORY https://github.com/scivision/cmake-cpu-detect.git
#  GIT_TAG 2e4e56500383e5483f64deeb48e1c9935d8975a0
#)
#FetchContent_MakeAvailable(CmakeCpuDetection)
#GetHostCPUInfo()

# set INSTALL_<pkgname> to TRUE for all packages in INSTALL_TPLS
# and check for package dependencies
set_packages_and_dependencies()

#this routine calls all build_<pkgname>() enabled by user or dependency
build_packages()
 

###################################################################################
## DEALII ITSELF                                                                 ##
###################################################################################
build_dealii(
  VERSION ${DEALII_VERSION} 
  MD5     ${DEALII_MD5}
  MAIN    TRUE
)


###################################################################################
## APPLICATIONS AND SUMMARY                                                      ##  
###################################################################################
build_applications()
print_config_summary()
