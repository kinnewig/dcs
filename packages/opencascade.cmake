macro(build_opencascade)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_OCE "" "${oneValueArgs}" "" ${ARGN})
  
  # Assamble the Download URL
  set(TMP_NAME "opencascade-${BUILD_OCE_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/tpaviot/oce/releases/download/official-upstream-packages/")
  set(BUILD_OCE_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING TMP_PACKING)
    else 
      set(TMP_MIRROR_PACKING MIRROR_PACKING)
    endif()

    set(BUILD_OCE_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_OCE_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)
  
  # Build OCE
  build_cmake_subproject(
      NAME OCE
      VERSION ${BUILD_OCE_VERSION}
      URL ${BUILD_OCE_URL}
      MD5 ${BUILD_OCE_MD5}
      DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
      BUILD_ARGS
        -D CMAKE_BUILD_TYPE=Release
        -D OCE_VISUALISATION:BOOL=OFF 
        -D OCE_DISABLE_TKSERVICE_FONT:BOOL=ON
        -D OCE_DATAEXCHANGE:BOOL=ON
        -D OCE_OCAF:BOOL=OFF
        -D OCE_DISABLE_X11:BOOL=ON
        -D OCE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/OCE-${BUILD_OCE_VERSION}
  )
  list(APPEND DEALII_DEPENDENCIES "OCE")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_OPENCASCADE:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D OPENCASCADE_DIR=${OCE_DIR}")
endmacro()
