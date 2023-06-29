macro(build_aocl_blis)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_AOCL_BLIS "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  set(TMP_NAME "${BUILD_ADOLC_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/coin-or/ADOL-C/archive/releases/")
  set(BUILD_AOCL_BLIS_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    set(BUILD_AOCL_BLIS_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_AOCL_BLIS_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Set Blis flags
  set(AOCL_BLIS_CONFOPTS "--enable-cblas CFLAGS='-DAOCL_F2C -fPIC' CXXFLAGS='-DAOCL_F2C -fPIC'")

  build_autotools_subproject(
    NAME BLIS
    VERSION ${BUILD_AOCL_BLIS_VERSION}
    URL ${BUILD_AOCL_BLIS_URL}
    MD5SUM ${BUILD_AOCL_BLIS__MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    CONFIGURE_FLAGS ${AOCL_BLIS_CONFOPTS}
  )
  
  # Configure AOCL ScaLAPACK to use AOCL BLIS
  list(APPEND AOCL_SCALAPACK_DEPENDENCIES "BLIS")
  # TODO automatically select suffix
  list(APPEND "-D BLAS_LIBRARIES:PATH=${BLIS_DIR}/lib/libblis.so")
  
  # Configure Trilinos to use AOCL BLIS
  list(APPEND TRILINOS_DEPENDENCIES "BLIS")
  list(APPEND TRILINOS_CONFOPTS "-D TPL_ENABLE_BLAS:BOOL=ON")
  list(APPEND TRILINOS_CONFOPTS "-D BLAS_LIBRARY_DIRS:STRING=${BLIS_DIR}/lib")
  
  # Configure deal.II to use AOCL BLIS
  list(APPEND DEALII_DEPENDENCIES "BLIS")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_BLAS:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D BLAS_DIR=${BLIS_DIR}")
endmacro()
