macro(build_gmsh)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_GMSH "" "${oneValueArgs}" "" ${ARGN})
  
  # Assamble the Download URL
  set(TMP_NAME "gmsh-${GMSH_VERSION}-source")
  set(TMP_PACKING ".tgz")
  set(TMP_URL "http://gmsh.info/src/")
  set(BUILD_GMSH_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING TMP_PACKING)
    else 
      set(TMP_MIRROR_PACKING MIRROR_PACKING)
    endif()

    set(BUILD_GMSH_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_GMSH_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  
  build_cmake_subproject(
    NAME gmsh
    VERSION ${BUILD_GMSH_VERSION}
    URL ${BUILD_GMSH_URL}
    MD5 ${BUILD_GMSH_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D ENABLE_MPI:BOOL=OFF
      -D CMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON
      -D ENABLE_PETSC:BOOL=OFF
  )
  

  list(APPEND DEALII_DEPENDENCIES "gmsh")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_GMSH:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D GMSH_DIR=${gmsh_DIR}")
endmacro()
