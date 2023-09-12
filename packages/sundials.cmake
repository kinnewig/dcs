macro(build_sundials)
  set(oneValueArgs VERSION MD5 MIRROR_NAME)
  cmake_parse_arguments(BUILD_SUNDIALS "" "${oneValueArgs}" "" ${ARGN})
  
  # Assamble the Download URL
  set(TMP_NAME "sundials-${BUILD_SUNDIALS_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/LLNL/sundials/releases/download/v${BUILD_SUNDIALS_VERSION}/")
  set(BUILD_SUNDIALS_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()
    
    if (DEFINED BUILD_SUNDIALS_MIRROR_NAME)
      set(TMP_NAME ${BUILD_SUNDIALS_MIRROR_NAME})
    endif()

    set(BUILD_OCE_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_SUNDIALS_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Build sundials
  build_cmake_subproject(
    NAME sundials
    VERSION ${BUILD_SUNDIALS_VERSION}
    GIT_REPO ${BUILD_SUNDIALS_REPO}
    GIT_TAG ${BUILD_SUNDIALS_TAG}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D BUILD_SHARED_LIBS:BOOL=ON 
      -D ENABLE_MPI:BOOL=ON
  )

endmacro()
