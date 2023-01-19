macro(build_hdf5)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_HDF5 "" "${oneValueArgs}" "" ${ARGN})

  string(REPLACE "." "_" TMP_VERSION ${BUILD_HDF5_VERSION})

  # Assamble the Download URL
  set(TMP_NAME "hdf5-${TMP_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/HDFGroup/hdf5/archive/refs/tags/")
  set(BUILD_HDF5_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    set(BUILD_HDF5_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_HDF5_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()
   
  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)
  unset(TMP_VERSION)
  
  # Build HDF5
  build_autotools_subproject(
    NAME hdf5
    VERSION ${BUILD_HDF5_VERSION}
    URL ${BUILD_HDF5_URL}
    MD5 ${BUILD_HDF5_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    CONFIGURE_FLAGS --enable-shared --enable-parallel
  )
  
  list(APPEND DEALII_DEPENDENCIES "hdf5")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_HDF5:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D HDF5_DIR=${hdf5_DIR}")
endmacro()
