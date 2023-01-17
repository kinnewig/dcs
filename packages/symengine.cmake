macro(build_symengine)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_SYMENGINE "" "${oneValueArgs}" "" ${ARGN})
  
  # Assamble the Download URL
  set(TMP_NAME "symengine-${BUILD_SYMENGINE_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/symengine/symengine/releases/download/v${BUILD_SYMENGINE_VERSION}/")
  set(BUILD_SYMENGINE_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING TMP_PACKING)
    else 
      set(TMP_MIRROR_PACKING MIRROR_PACKING)
    endif()

    set(BUILD_SYMENGINE_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_SYMENGINE_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Build symengine
  build_cmake_subproject(
    NAME symengine
    VERSION ${BUILD_SYMENGINE_VERSION}
    URL ${BUILD_SYMENGINE_URL}
    MD5 ${BUILD_SYMENGINE_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D BUILD_SHARED_LIBS:BOOL=ON
      -D BUILD_TEST:BOOL=OFF
      -D BUILD_BENCHMARKS:BOOL=OFF
  )

  list(APPEND DEALII_DEPENDENCIES "symengine")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_SYMENGINE:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D SYMENGINE_DIR=${symengine_DIR}")
endmacro()
