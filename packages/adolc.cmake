macro(build_adolc)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_ADOLC "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  set(TMP_NAME "${BUILD_ADOLC_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/coin-or/ADOL-C/archive/releases/")
  set(BUILD_ADOLC_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    set(BUILD_ADOLC_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_ADOLC_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)


  build_autotools_subproject(
    NAME adolc
    VERSION ${BUILD_ADOLC_VERSION}
    URL ${BUILD_ADOLC_URL}
    MD5SUM ${BUILD_ADOLC_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    CONFIGURE_FLAGS --with-boost=no
  )
  
  list(APPEND DEALII_DEPENDENCIES "adolc")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_ADOLC:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D ADOLC_DIR=${adolc_DIR}")
endmacro()
