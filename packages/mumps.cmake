macro(build_mumps)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_MUMPS "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  set(TMP_NAME "v${BUILD_MUMPS_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/scivision/mumps/archive/refs/tags/")
  set(BUILD_MUMPS_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    set(BUILD_MUMPS_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_MUMPS_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()
   
  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Overwrite MUMPS_CONFOPTS in order to use IntelMKL
  if (BLAS_TYPE STREQUAL "IntelMKL")
    set(MUMPS_CONFOPTS -D MKLROOT=${MKL_ROOT})
  endif()

  set(BUILD_MUMPS_C_FLAGS "-g -fPIC -O3")
  set(BUILD_MUMPS_F_FLAGS "-fallow-argument-mismatch")
  
  if(DOWNLOAD_ONLY) 
    string(REPLACE "." ";" TMP_LIST ${BUILD_MUMPS_VERSION})
    list(POP_BACK TMP_LIST)
    list(POP_FRONT TMP_LIST TMPVAR)
    set(TMP_VERSION ${TMPVAR})
    list(POP_FRONT TMP_LIST TMPVAR)
    string(CONCAT TMP_VERSION ${TMP_VERSION} "." ${TMPVAR})
    list(POP_FRONT TMP_LIST TMPVAR)
    string(CONCAT TMP_VERSION ${TMP_VERSION} "." ${TMPVAR})
    unset(TMP_LIST)
    unset(TMPVAR)
    # This package uses FetchContent internally 
    # so we need to download and extract a corresponding tar file
    string(CONCAT MUMPS_FILENAME "MUMPS_" ${TMP_VERSION} ".tar.gz")
    string(CONCAT MUMPS_SRC_URL "http://graal.ens-lyon.fr/MUMPS/" ${MUMPS_FILENAME})
    unset(TMP_VERSION)
    file(DOWNLOAD ${MUMPS_SRC_URL} ${CMAKE_BINARY_DIR}/MUMPS/build/_deps/mumps-subbuild/mumps-populate-prefix/src/${MUMPS_FILENAME})
  endif()

  # Build MUMPS
  build_cmake_subproject(
    NAME MUMPS
    VERSION ${BUILD_MUMPS_VERSION}
    URL ${BUILD_MUMPS_URL}
    MD5 ${BUILD_MUMPS_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D metis=true
      -D METIS_LIBRARY=${METIS_LIB}
      -D METIS_INCLUDE_DIR=${ParMETIS_INCLUDES}
      -D PARMETIS_LIBRARY=${ParMETIS_LIB}
      -D CMAKE_Fortran_COMPILER=mpif90
      -D CMAKE_C_COMPILER=${CMAKE_MPI_C_COMPILER}
      -D CMAKE_CXX_COMPILER=${CMAKE_MPI_CXX_COMPILER}
      -D CMAKE_C_FLAGS:STRING=${BUILD_MUMPS_C_FLAGS}
      -D CMAKE_Fortran_FLAGS:STRING=${BUILD_MUMPS_F_FLAGS}
      -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
      -D BUILD_SHARED_LIBS:BOOL=ON
      -D CMAKE_POLICY_DEFAULT_CMP0135:STRING=NEW
      ${MUMPS_CONFOPTS}
      DEPENDS_ON ${MUMPS_DEPENDENCIES} ParMETIS
  )

  # Configure Trilinos to use MUMPS
  list(APPEND TRILINOS_DEPENDENCIES "MUMPS")
  list(APPEND TRILINOS_CONFOPTS "-D TPL_ENABLE_MUMPS:BOOL=ON")
  list(APPEND TRILINOS_CONFOPTS "-D MUMPS_LIBRARY_DIRS:PATH=${MUMPS_DIR}/lib")
  list(APPEND TRILINOS_CONFOPTS "-D MUMPS_INCLUDE_DIRS:PATH=${MUMPS_DIR}/include")
endmacro()
