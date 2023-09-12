macro(build_assimp)
  set(oneValueArgs VERSION MD5 MIRROR_NAME)
  cmake_parse_arguments(BUILD_ASSIMP "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  set(TMP_NAME "v${BUILD_ASSIMP_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/assimp/assimp/archive/")
  set(BUILD_ASSIMP_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()
    
    if (DEFINED BUILD_ASSIMP_MIRROR_NAME)
      set(TMP_NAME ${BUILD_ASSIMP_MIRROR_NAME})
    endif()

    set(BUILD_ASSIMP_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_ASSIMP_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  
  build_cmake_subproject(
    NAME assimp
    VERSION ${BUILD_ASSIMP_VERSION}
    URL ${BUILD_ASSIMP_URL}
    MD5 ${BUILD_ASSIMP_MD5}
    DOWNLOAD_ONLY 
    BUILD_ARGS 
      -D BUILD_SHARED_LIBS:BOOL=ON
  )

  list(APPEND DEALII_DEPENDENCIES "assimp")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_ASSIMP:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D ASSIMP_DIR=${assimp_DIR}")
endmacro()
