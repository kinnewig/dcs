macro(build_blis)
  set(oneValueArgs VERSION MD5 MIRROR_NAME)
  cmake_parse_arguments(BUILD_BLIS "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  set(TMP_NAME "${BUILD_BLIS_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/flame/blis/archive/refs/tags/")
  set(BUILD_BLIS_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    if (DEFINED BUILD_BLIS_MIRROR_NAME)
      set(TMP_NAME ${BUILD_AOCL_BLIS_MIRROR_NAME})
    endif()    

    set(BUILD_BLIS_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_BLIS_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Set BLIS architecture if not defined yet
  if (NOT DEFINED BLIS_ARCHITECTURE)
    set(BLIS_ARCHITECTURE auto)
  endif()

  # Set BLIS flags
  set(BLIS_CONFOPTS --enable-cblas CFLAGS="-DAOCL_F2C -fPIC" CXXFLAGS="-DAOCL_F2C -fPIC" ${BLIS_ARCHITECTURE})

  build_autotools_subproject(
    NAME BLIS
    VERSION ${BUILD_BLIS_VERSION}
    URL ${BUILD_BLIS_URL}
    MD5SUM ${BUILD_BLIS_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    CONFIGURE_FLAGS ${BLIS_CONFOPTS}
  )

  # Configure ScaLAPACK to use BLIS
  list(APPEND SCALAPACK_DEPENDENCIES "BLIS")
  list(APPEND SCALAPACK_CONFOPTS "-D BLAS_LIBRARIES:PATH=${BLIS_DIR}/lib/libblis${CMAKE_SHARED_LIBRARY_SUFFIX}")
  
  # Configure Trilinos to use BLIS
  list(APPEND TRILINOS_DEPENDENCIES "BLIS")
  list(APPEND TRILINOS_CONFOPTS "-D TPL_ENABLE_BLAS:BOOL=ON")
  list(APPEND TRILINOS_CONFOPTS "-D BLAS_LIBRARY_DIRS:STRING=${BLIS_DIR}/lib")
  
  # Configure deal.II to use BLIS
  list(APPEND DEALII_DEPENDENCIES "BLIS")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_BLAS:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D BLAS_DIR=${BLIS_DIR}")
endmacro()
