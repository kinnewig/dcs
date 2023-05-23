#!/bin/bash
set -a

# Set default values
PREFIX=~/dealii
BUILD=dealii_build
USER_INTERACTION=ON

# Default number of threads
THREADS=$(($(nproc)-2))


while [ -n "$1" ]; do
  param="$1"
  case $param in

    # Help
    -h|--help)
      echo "deal.II CMake SuberBuild, Version $(cat VERSION)"
      echo "Usage: $0 [options]"
      echo "  -h, --help                   Print this message"
      echo "  -p <path>, --prefix=<path>   Set a different prefix path (default ${PREFIX})"
      echo "  -b <path>, --build=<path>    Set a different build path (default ${BUILD})"
      echo "  -j <path>, --parallel=<path> Set number of threads to use (default ${THREADS})"
      echo "  -U                           Do not interupt (TODO)"
      echo "  -v, --version                Print the version number"
      exit 0
    ;;

    # Prefix path
    -p)
      shift
      PREFIX="${1}"
    ;;
      -p=*|--prefix=*)
      PREFIX="${param#*=}"
    ;;
    
    # Build path
    -b)
      shift
      BUILD="${1}"
    ;;
      -b=*|--build=*)
      BUILD="${param#*=}"
    ;;

    # Threads
    -j)
      shift
      THREADS="${1}"
    ;;
      -j=*|--parallel=*)
      THREADS="${param#*=}"
    ;;    

    # Version
    -v|--version)
      echo "$(cat VERSION)"
    ;;

    # User interaction
    -U)
      USER_INTERACTION=OFF
    ;;

    # Unknwon flag
    *) 
    echo "invalid command line option <$param>. See -h for more information."
    exit 1

  esac
  shift
done

# Check the input argument of the install path and (if used) replace the tilde
# character '~' by the users home directory ${HOME}. Afterwards clear the
# PREFIX input variable.
PREFIX_PATH=${PREFIX/#~\//$HOME\/}
unset PREFIX

# Read user selection from dcs.cfg
PACKAGES=""
source dcs.cfg


# ++============================================================++
# ||                         Premilaris                         ||
# ++============================================================++

# Colours for progress and error reporting
BAD="\033[1;31m"
GOOD="\033[1;32m"
WARN="\033[1;35m"
INFO="\033[1;34m"
BOLD="\033[1m"

cecho() {
    # Display messages in a specified colour
    COL=$1; shift
    echo -e "${COL}$@\033[0m"
}


# ++============================================================++
# ||                      Guess the platform                    ||
# ++============================================================++

# TODO: This is not modular! Need to rewrite this part in a modular fashion
guess_platform() {
  # Try to guess the name of the platform we're running on
  if [ -f /usr/bin/cygwin1.dll ]; then
    echo cygwin

  elif [ -x /usr/bin/sw_vers ]; then
    local MACOS_PRODUCT_NAME=$(sw_vers -productName)
    local MACOS_VERSION=$(sw_vers -productVersion)

    if [ "${MACOS_PRODUCT_NAME}" == "macOS" ]; then
        echo macos

    else
      case ${MACOS_VERSION} in
        10.11*) echo macos_elcapitan;;
        10.12*) echo macos_sierra;;
        10.13*) echo macos_highsierra;;
        10.14*) echo macos_mojave;;
        10.15*) echo macos_catalina;;
        11.4*)  echo macos_bigsur;;
        11.5*)  echo macos_bigsur;;
      esac
    fi

  elif [ ! -z "${CRAYOS_VERSION}" ]; then
    echo cray

  elif [ -f /etc/os-release ]; then
    local OS_ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
    local OS_VERSION_ID=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
    local OS_MAJOR_VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"' | grep -oE '[0-9]+' | head -n 1)
    local OS_NAME=$(grep -oP '(?<=^NAME=).+' /etc/os-release | tr -d '"')
    local OS_PRETTY_NAME=$(grep -oP '(?<=^PRETTY_NAME=).+' /etc/os-release | tr -d '"')

    if [ "${OS_ID}" == "fedora" ]; then
      echo fedora

    elif [ "${OS_ID}" == "centos" ]; then
      echo centos${OS_VERSION_ID}

    elif [ "${OS_ID}" == "almalinux" ]; then
      echo almalinux${OS_MAJOR_VERSION}

    elif [ "${OS_ID}" == "rhel" ]; then
      echo rhel${OS_MAJOR_VERSION}

    elif [ "$OS_ID" == "debian" ]; then
      echo debian

    elif [ "$OS_ID" == "ubuntu" ]; then
      echo ubuntu

    elif [ "${OS_NAME}" == "openSUSE Leap" ]; then
      echo opensuse15

    elif [ "${OS_PRETTY_NAME}" == "Arch Linux" ]; then
      echo arch

    elif [ "${OS_PRETTY_NAME}" == "Manjaro Linux" ]; then
      echo arch
    fi
  fi
}




# ++============================================================++
# ||                      User interaction                      ||
# ++============================================================++
echo "-------------------------------------------------------------------------------"
cecho ${WARN} "Please read carefully your operating system notes below!"
cecho ${INFO} "If you do not want to see this message use \"-U\""
echo

# Operating system (PLATFORM) check
PLATFORM_SUPPORTED=platform/$(guess_platform).platform
if [ -e ${PLATFORM_SUPPORTED} ]; then
  echo "$(cat ${PLATFORM_SUPPORTED})"
else
  cecho ${WARN} "Warning: Your operating system could not be automatically recognised."
  echo "Please inform yourself which dependcies are needed."
fi

# If interaction is enabled, let the user confirm, that the platform is set up correctly"
if [ ${USER_INTERACTION} = ON ]; then
  echo "--------------------------------------------------------------------------------"
  cecho ${GOOD} "Please make sure you've read the instructions above and your system"
  cecho ${BAD} "If not, please abort the installer by pressing <CTRL> + <C> !"
  cecho ${INFO} "Then copy and paste these instructions into this terminal."
  echo

  cecho ${GOOD} "Once ready, hit enter to continue!"
  read
fi

# If interaction is enabled, let us confirm, that the correct packages where selected
if [ ${USER_INTERACTION} = ON ]; then
  echo "--------------------------------------------------------------------------------"
  cecho ${INFO} "deal.II will be installed in version: ${DEALII_VERSION}"
  echo
  cecho ${INFO} "The following packages will be build"
  for PACKAGE in ${PACKAGES[@]}; do
    echo ${PACKAGE}
  done
  echo
  cecho ${GOOD} "If the selection is correct, hit enter to continue!"
  cecho ${BAD} "If not, please abort the installer by pressing <CTRL> + <C> !"
  cecho ${INFO} "Then edit dcs.cfg"
  read
fi


# ++============================================================++
# ||                Apply package selection                     ||
# ++============================================================++

# List of all available packages
ALL_PACKAGES=""
ALL_PACKAGES="${ALL_PACKAGES} assimp"
ALL_PACKAGES="${ALL_PACKAGES} gmsh"
ALL_PACKAGES="${ALL_PACKAGES} opencascade"
ALL_PACKAGES="${ALL_PACKAGES} p4est"
ALL_PACKAGES="${ALL_PACKAGES} parmetis"
ALL_PACKAGES="${ALL_PACKAGES} ginkgo"
ALL_PACKAGES="${ALL_PACKAGES} mumps"
ALL_PACKAGES="${ALL_PACKAGES} superlu_dist"
ALL_PACKAGES="${ALL_PACKAGES} trilinos"
ALL_PACKAGES="${ALL_PACKAGES} adolc"
ALL_PACKAGES="${ALL_PACKAGES} arpack"
ALL_PACKAGES="${ALL_PACKAGES} sundials"
ALL_PACKAGES="${ALL_PACKAGES} symengine"
ALL_PACKAGES="${ALL_PACKAGES} hdf5"

# First disable all packages
for PACKAGE in ${ALL_PACKAGES[@]}; do
  sed -i "s/^list(APPEND INSTALL_TPLS \"${PACKAGE}\")/#list(APPEND INSTALL_TPLS \"${PACKAGE}\")/g" CMakeLists.txt
done

# Next reenable the selected packages
for PACKAGE in ${PACKAGES[@]}; do
  sed -i "s/#list(APPEND INSTALL_TPLS \"${PACKAGE}\")/list(APPEND INSTALL_TPLS \"${PACKAGE}\")/g" CMakeLists.txt
done


# ++============================================================++
# ||                Start the Installation                      ||
# ++============================================================++

# set enviroment (TODO: needs to be improved)
echo CC=mpicc
echo CXX=mpicxx
echo FC=mpifort
echo FF=mpifort
echo MPI_CC=mpicc
echo MPI_CXX=mpicxx
echo MPI_FC=mpifort
echo MPI_FF=mpifort

# TODO Mirror: -D MIRROR=http://distribution.ifam.uni-hannover.de/ASBT/DEAL/candi/V7/

cmake -S . -B ${BUILD} -D CMAKE_INSTALL_PREFIX=${PREFIX_PATH} -D THREAD_COUNT=${THREADS} -D MIRROR=http://distribution.ifam.uni-hannover.de/ASBT/DEAL/candi/V7/
cmake --build ${BUILD} --parallel ${THREADS} 2> >(tee error.log) | tee install.log
