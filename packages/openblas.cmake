macro(build_openblas)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_OPENBLAS "" "${oneValueArgs}" "" ${ARGN})
  
  # Assamble the Download URL
  set(TMP_NAME "OpenBLAS-${BUILD_OPENBLAS_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/xianyi/OpenBLAS/releases/download/v${BUILD_OPENBLAS_VERSION}/")
  set(BUILD_OPENBLAS_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING TMP_PACKING)
    else 
      set(TMP_MIRROR_PACKING MIRROR_PACKING)
    endif()

    set(BUILD_OPENBLAS_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_OPENBLAS_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()
   
  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Build OpenBLAS
  build_cmake_subproject(
    NAME OpenBLAS
    VERSION ${BUILD_OPENBLAS_VERSION}
    URL ${BUILD_OPENBLAS_URL}
    MD5 ${BUILD_OPENBLAS_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D BUILD_SHARED_LIBS:BOOL=ON
      -D CMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
  )

  set(BLAS_LIBS ${OpenBLAS_DIR}/lib64/libopenblas${CMAKE_SHARED_LIBRARY_SUFFIX})
  set(LAPACK_LIBS ${BLAS_LIBS})
  set(BLAS_DIR ${OpenBLAS_DIR})
  set(BLAS_PROJECT_NAME OpenBLAS)

  list(APPEND DEALII_DEPENDENCIES "OpenBLAS")
  list(APPEND DEALII_CONFOPTS "-D LAPACK_LIBRARIES=${LAPACK_LIBS}")
      
endmacro()
