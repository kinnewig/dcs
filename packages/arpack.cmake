macro(build_arpack)
  set(oneValueArgs VERSION MD5 MIRROR_NAME)
  cmake_parse_arguments(BUILD_ARPACK "" "${oneValueArgs}" "" ${ARGN})
  
  # Assamble the Download URL
  set(TMP_NAME "${BUILD_ARPACK_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/opencollab/arpack-ng/archive/refs/tags/")
  set(BUILD_ARPACK_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()
    
    if (DEFINED BUILD_ARPACK_MIRROR_NAME)
      set(TMP_NAME ${BUILD_ARPACK_MIRROR_NAME})
    endif()

    set(BUILD_ARPACK_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_ARPACK_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  build_cmake_subproject(
    NAME arpack
    VERSION ${BUILD_ARPACK_VERSION}
    URL ${BUILD_ARPACK_URL}
    MD5 ${BUILD_ARPACK_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D EXAMPLES:BOOL=OFF 
      -D MPI:BOOL=ON 
      -D BUILD_SHARED_LIBS:BOOL=ON
  )

  list(APPEND DEALII_DEPENDENCIES "arpack")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_ARPACK:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_ARPACK_WITH_PARPACK:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D ARPACK_DIR=${arpack_DIR}")
endmacro()
