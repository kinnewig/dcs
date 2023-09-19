macro(build_libflame)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_LIBFLAME "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  set(TMP_NAME "${BUILD_LIBFLAME_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/flame/libflame/archive/refs/tags/")
  set(BUILD_LIBFLAME_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)
  print(BUILD_LIBFLAME_URL)
  print(BUILD_LIBFLAME_MD5)
  build_autotools_subproject(
    NAME LIBFLAME
    VERSION ${BUILD_LIBFLAME_VERSION}
    URL ${BUILD_LIBFLAME_URL}
    MD5SUM ${BUILD_LIBFLAME_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    CONFIGURE_FLAGS --enable-lapack2flame --enable-external-lapack-interfaces --enable-dynamic-build --enable-max-arg-list-hack --enable-f2c-dotc
  )
  ExternalProject_Add_Step(
    LIBFLAME libflame_symlink
    COMMAND ln -s libflame.a flame.a
    WORKING_DIRECTORY ${LIBFLAME_DIR}/lib
    DEPENDEES install
  )
  # Configure AOCL ScaLAPACK to use AOCL LIBFLAME
  list(APPEND SCALAPACK_DEPENDENCIES "LIBFLAME")
  # TODO automatically select suffix
  list(APPEND SCALAPACK_CONFOPTS "-D USER_PROVIDED_LIBFLAME_DIR=${LIBFLAME_DIR}")
  list(APPEND SCALAPACK_CONFOPTS "-D LAPACK_LIBRARY=${LIBFLAME_DIR}/lib/libflame.a")
  # Configure Trilinos to use AOCL LIBFLAME
  list(APPEND TRILINOS_DEPENDENCIES "LIBFLAME")
  list(APPEND TRILINOS_CONFOPTS "-D TPL_ENABLE_LAPACK:BOOL=ON")
  # TODO automatically select suffix
  list(APPEND TRILINOS_CONFOPTS "-D LAPACK_LIBRARY_DIRS:STRING=${LIBFLAME_DIR}/lib/libflame.a")
  
  # Configure deal.II to use AOCL LIBFLAME
  list(APPEND DEALII_DEPENDENCIES "LIBFLAME")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_LAPACK:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D LAPACK_DIR=${LIBFLAME_DIR}")
endmacro()
