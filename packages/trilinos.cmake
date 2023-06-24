macro(build_trilinos)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_TRILINOS "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  string(REPLACE "." "-" TMP_VERSION ${TRILINOS_VERSION})
  set(TMP_NAME "trilinos-release-${TMP_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/trilinos/Trilinos/archive/")
  set(BUILD_TRILINOS_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    set(BUILD_TRILINOS_URL "${MIRROR}${TMP_NAME}${TMP_PACKING} ${BUILD_TRILINOS_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # ParMETIS
  list(APPEND TRILINOS_CONFOPTS "-D TPL_ENABLE_ParMETIS:BOOL=ON")
  list(APPEND TRILINOS_CONFOPTS "-D TPL_ParMETIS_LIBRARIES:FILEPATH=${ParMETIS_LIB};${METIS_LIB}")
  list(APPEND TRILINOS_CONFOPTS "-D TPL_ParMETIS_INCLUDE_DIRS:PATH=${ParMETIS_INCLUDES}")

  # Unset temporal variables
  unset(TMP_VERSION)
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Trilinos specific flags  
  set(BUILD_TRILINOS_C_FLAGS "-g -fPIC -O3")
  set(BUILD_TRILINOS_CXX_FLAGS "-g -fPIC -O3")
  set(BUILD_TRILINOS_F_FLAGS "-g -O3 -fallow-argument-mismatch")
  
  build_cmake_subproject(
    NAME Trilinos
    VERSION ${BUILD_TRILINOS_VERSION}
    URL ${BUILD_TRILINOS_URL}
    URL_MD5 ${BUILD_TRILINOS_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D TPL_ENABLE_MPI:BOOL=ON 
      -D Trilinos_ENABLE_OpenMP:BOOL=OFF 
      -D TPL_ENABLE_TBB:BOOL=OFF 
      -D Trilinos_VERBOSE_CONFIGURE:BOOL=OFF 
      -D Trilinos_ENABLE_EXPLICIT_INSTANTIATION=ON 
      -D Trilinos_ENABLE_Amesos:BOOL=ON 
      -D Trilinos_ENABLE_Epetra:BOOL=ON
      -D Trilinos_ENABLE_EpetraExt:BOOL=ON 
      -D Trilinos_ENABLE_Ifpack:BOOL=ON 
      -D Trilinos_ENABLE_Ifpack2:BOOL=OFF 
      -D Trilinos_ENABLE_Tpetra:BOOL=ON 
      -D   Tpetra_INST_INT_LONG_LONG:BOOL=ON 
      -D Trilinos_ENABLE_AztecOO:BOOL=ON 
      -D Trilinos_ENABLE_Sacado:BOOL=ON 
      -D Trilinos_ENABLE_Teuchos:BOOL=ON 
      -D   Teuchos_ENABLE_FLOAT:BOOL=ON 
      -D Trilinos_ENABLE_MueLu:BOOL=OFF #<- Is not compatible with deal.II and Trilinos >= 13.0.0
      -D Trilinos_ENABLE_ML:BOOL=ON 
      -D Trilinos_ENABLE_ROL:BOOL=ON 
      -D Trilinos_ENABLE_Zoltan:BOOL=ON 
      -D Trilinos_ENABLE_Stratimikos:BOOL=OFF #<- Produces a Linking Error, for what is that even used?
      -D TPL_ENABLE_Boost:BOOL=OFF 
      -D Trilinos_ENABLE_Belos:BOOL=ON 
      -D Trilinos_ENABLE_Amesos2:BOOL=ON 
      -D TPL_ENABLE_Matio=OFF 
      -D CMAKE_BUILD_TYPE:STRING=RELEASE 
      -D BUILD_SHARED_LIBS:BOOL=ON 
      -D CMAKE_Fortran_COMPILER=${CMAKE_MPI_Fortran_COMPILER}
      -D CMAKE_C_COMPILER=${CMAKE_MPI_C_COMPILER}
      -D CMAKE_CXX_COMPILER=${CMAKE_MPI_CXX_COMPILER}
      -D CMAKE_C_FLAGS:STRING=${BUILD_TRILINOS_C_FLAGS}
      -D CMAKE_CXX_FLAGS:STRING=${BUILD_TRILINOS_C_FLAGS}
      -D CMAKE_Fortran_FLAGS:STRING=${BUILD_TRILINOS_F_FLAGS}
      -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
      ${TRILINOS_CONFOPTS}
    DEPENDS_ON ${TRILINOS_DEPENDENCIES} ParMETIS
  )

  list(APPEND CMAKE_PREFIX_PATH "${Trilinos_DIR}")
  
  # Configure deal.II to use Trilinos
  list(APPEND DEALII_DEPENDENCIES "Trilinos")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_TRILINOS:BOOL=ON ")
  list(APPEND DEALII_CONFOPTS "-D TRILINOS_DIR=${Trilinos_DIR}")
endmacro()
