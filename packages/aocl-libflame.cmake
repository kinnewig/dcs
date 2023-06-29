macro(build_aocl_libflame)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_AOCL_LIBFLAME "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  set(TMP_NAME "${BUILD_ADOLC_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/amd/libflame/archive/refs/tags/")
  set(BUILD_AOCL_LIBFLAME_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    set(BUILD_AOCL_LIBFLAME_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_AOCL_LIBFLAME_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Set Blis flags
  set(AOCL_LIBFLAME_CONFOPTS "--enable-lapack2flame --enable-external-lapack-interfaces --enable-dynamic-build --enable-max-arg-list-hack --enable-f2c-dotc")

  build_autotools_subproject(
    NAME LIBFLAME
    VERSION ${BUILD_AOCL_LIBFLAME_VERSION}
    URL ${BUILD_AOCL_LIBFLAME_URL}
    MD5SUM ${BUILD_AOCL_LIBFLAME__MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    CONFIGURE_FLAGS ${AOCL_LIBFLAME_CONFOPTS}
  )
  
  # Configure AOCL ScaLAPACK to use AOCL LIBFLAME
  list(APPEND AOCL_SCALAPACK_DEPENDENCIES "LIBFLAME")
  # TODO automatically select suffix
  list(APPEND "-D LAPACK_LIBRARIES=${LIBFLAME_DIR}/lib/libflame.a")
  
  # Configure Trilinos to use AOCL LIBFLAME
  list(APPEND TRILINOS_DEPENDENCIES "LIBFLAME")
  list(APPEND TRILINOS_CONFOPTS "-D TPL_ENABLE_LAPACK:BOOL=ON")
  # TODO automatically select suffix
  list(APPEND TRILINOS_CONFOPTS "-D LAPACK_LIBRARY_DIRS:STRING=${LIBFLAME_DIR}/lib/libflame.a"")
  
  # Configure deal.II to use AOCL LIBFLAME
  list(APPEND DEALII_DEPENDENCIES "LIBFLAME")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_LAPACK:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D LAPACK_DIR=${LIBFLAME_DIR}")
endmacro()
