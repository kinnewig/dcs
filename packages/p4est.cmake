macro(build_p4est)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_P4EST "" "${oneValueArgs}" "" ${ARGN})
  
  # Assamble the Download URL
  set(TMP_NAME "p4est-${BUILD_P4EST_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://p4est.github.io/release/")
  set(BUILD_P4EST_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    set(BUILD_P4EST_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_P4EST_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Set Install path
  set(P4EST_INSTALL_PATH ${CMAKE_INSTALL_PREFIX}/p4est-${BUILD_P4EST_VERSION})

  # Unfortunatly p4est does not support CMake or Autotools, therefore we need a special building chain
  set(p4est_fast_flags --prefix=${P4EST_INSTALL_PATH}/FAST CFLAGS=-O2)
  set(p4est_debug_flags --prefix=${P4EST_INSTALL_PATH}/DEBUG CFLAGS=-O0)
  set(p4est_enable_flags --enable-shared --disable-vtk-binary --without-blas --enable-mpi)
  set(p4est_compile_flags F77=mpifort )

  if(DOWNLOAD_ONLY)
    ExternalProject_Add(
      p4est
      URL ${BUILD_P4EST_URL}
      URL_MD5 ${BUILD_P4EST_MD5}
      UPDATE_DISCONNECTED true  # need this to avoid constant rebuild
      DOWNLOAD_EXTRACT_TIMESTAMP TRUE
      CONFIGURE_COMMAND true
      BUILD_COMMAND true
      INSTALL_COMMAND true
    )
  else()
    find_program(MAKE_EXECUTABLE NAMES gmake make mingw32-make REQUIRED)
    ExternalProject_Add(
      p4est
      URL ${BUILD_P4EST_URL}
      URL_MD5 ${BUILD_P4EST_MD5}
      UPDATE_DISCONNECTED true  # need this to avoid constant rebuild
      DOWNLOAD_EXTRACT_TIMESTAMP TRUE
      CONFIGURE_COMMAND ${CMAKE_BINARY_DIR}/p4est-prefix/src/p4est/configure ${p4est_enable_flags} ${p4est_fast_flags} ${p4est_compile_flags}
      BUILD_COMMAND ${MAKE_EXECUTABLE} -C sc 
      COMMAND make 
      INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )

    ExternalProject_Get_Property(p4est SOURCE_DIR)
    
    ExternalProject_Add_Step(
      p4est p4est_add_debug_build_path
      COMMAND mkdir -p DEBUG
      WORKING_DIRECTORY ${SOURCE_DIR}
      DEPENDEES install
    )

    ExternalProject_Add_Step(
      p4est p4est_config_debug
      COMMAND ${CMAKE_BINARY_DIR}/p4est-prefix/src/p4est/configure --enable-debug ${p4est_enable_flags} ${p4est_debug_flags} ${p4est_compile_flags}
      WORKING_DIRECTORY ${SOURCE_DIR}/DEBUG
      DEPENDEES p4est_add_debug_build_path
    )

    ExternalProject_Add_Step(
      p4est p4est_makesc_debug
      COMMAND make -C sc
      WORKING_DIRECTORY ${SOURCE_DIR}/DEBUG
      DEPENDEES p4est_config_debug
    )
    ExternalProject_Add_Step(
      p4est p4est_make_debug
      COMMAND make 
      WORKING_DIRECTORY ${SOURCE_DIR}/DEBUG
      DEPENDEES p4est_makesc_debug
    )
    ExternalProject_Add_Step(
      p4est p4est_install_debug
      COMMAND make 
      WORKING_DIRECTORY ${SOURCE_DIR}/DEBUG
      DEPENDEES p4est_make_debug
    )
  endif()

  list(APPEND DEALII_DEPENDENCIES "p4est")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_P4EST:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D P4EST_DIR=${P4EST_INSTALL_PATH}")
endmacro()
