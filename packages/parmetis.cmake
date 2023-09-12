macro(build_parmetis)
  set(oneValueArgs VERSION MD5 MIRROR_NAME)
  cmake_parse_arguments(BUILD_PARMETIS "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  set(TMP_NAME "parmetis-${BUILD_PARMETIS_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/")
  set(BUILD_PARMETIS_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()
    
    if (DEFINED BUILD_PARMETIS_MIRROR_NAME)
      set(TMP_NAME ${BUILD_PARMETIS_MIRROR_NAME})
    endif()

    set(BUILD_PARMETIS_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_PARMETIS_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  
  setup_subproject_path_vars(ParMetis)    
    
  set(SUBPROJECT_INSTALL_PATH ${CMAKE_INSTALL_PREFIX}/ParMETIS-${BUILD_PARMETIS_VERSION})
  if(DOWNLOAD_ONLY)
    ExternalProject_Add(ParMETIS
      URL ${BUILD_PARMETIS_URL}
      URL_MD5 ${BUILD_PARMETIS_MD5}
      UPDATE_DISCONNECTED true
      DOWNLOAD_EXTRACT_TIMESTAMP TRUE
      CONFIGURE_HANDLED_BY_BUILD true
      CONFIGURE_COMMAND true
      BUILD_COMMAND true
      INSTALL_COMMAND true
      STAMP_DIR ${SUBPROJECT_STAMP_PATH}
      SOURCE_DIR ${SUBPROJECT_SOURCE_PATH}
      BINARY_DIR ${SUBPROJECT_SOURCE_PATH}
      INSTALL_DIR ${SUBPROJECT_INSTALL_PATH}  
    )
  else()
    SET(METIS_CONFOPTS 
          -D CMAKE_VERBOSE_MAKEFILE=1
          -D GKLIB_PATH=GKlib
          -D CMAKE_INSTALL_PREFIX=${SUBPROJECT_INSTALL_PATH}
          -D SHARED=1
          -D CMAKE_C_COMPILER=${CMAKE_MPI_C_COMPILER}
          -D CMAKE_C_FLAGS=-fpic
    )
    
    SET(PARMETIS_CONFOPTS 
          -D CMAKE_VERBOSE_MAKEFILE=1
          -D GKLIB_PATH=metis/GKlib
          -D METIS_PATH=metis
          -D CMAKE_INSTALL_PREFIX=${SUBPROJECT_INSTALL_PATH}
          -D SHARED=1
          -D CMAKE_C_COMPILER=${CMAKE_MPI_C_COMPILER}
          -D CMAKE_C_FLAGS=-fpic
    )
    #Does not work as cmake_subproject as the metis and GKlib paths have to be specified in a weird way
    
    ExternalProject_Add(ParMETIS
      URL ${BUILD_PARMETIS_URL}
      URL_MD5 ${BUILD_PARMETIS_MD5}
      UPDATE_DISCONNECTED true
      DOWNLOAD_EXTRACT_TIMESTAMP TRUE
      CONFIGURE_HANDLED_BY_BUILD true
      CONFIGURE_COMMAND cmake -S . -B build ${PARMETIS_CONFOPTS}
      BUILD_COMMAND cmake --build build --parallel ${THREAD_COUNT}
      INSTALL_COMMAND cmake --install build
      STAMP_DIR ${SUBPROJECT_STAMP_PATH}
      SOURCE_DIR ${SUBPROJECT_SOURCE_PATH}
      BINARY_DIR ${SUBPROJECT_SOURCE_PATH}
      INSTALL_DIR ${SUBPROJECT_INSTALL_PATH}  
    )
    #We need to add the following steps to also build metis 
    ExternalProject_Add_Step(
      ParMETIS configure_metis
      WORKING_DIRECTORY ${SUBPROJECT_SOURCE_PATH}/metis
      COMMAND cmake -S. -Bbuild ${METIS_CONFOPTS}
      DEPENDEES patch
    )
    
    ExternalProject_Add_Step(
      ParMETIS build_metis
      WORKING_DIRECTORY ${SUBPROJECT_SOURCE_PATH}/metis
      COMMAND cmake --build build
      DEPENDEES configure_metis
    )
    
    ExternalProject_Add_Step(
      ParMETIS install_metis
      WORKING_DIRECTORY ${SUBPROJECT_SOURCE_PATH}/metis
      COMMAND cmake --install build
      DEPENDEES build_metis
      DEPENDERS configure
    )
  
  endif()
  
  set(ParMETIS_DIR ${SUBPROJECT_INSTALL_PATH})
  set(ParMETIS_LIB ${ParMETIS_DIR}/lib/libparmetis${CMAKE_SHARED_LIBRARY_SUFFIX})
  set(METIS_LIB ${ParMETIS_DIR}/lib/libmetis${CMAKE_SHARED_LIBRARY_SUFFIX})
  set(ParMETIS_INCLUDES ${ParMETIS_DIR}/include)

  # Configure deal.II to use ParMETIS
  list(APPEND DEALII_DEPENDENCIES "ParMETIS")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_METIS:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D METIS_DIR=${ParMETIS_DIR}")
  
  # Configure MUMPS to use ParMETIS
  list(APPEND MUMPS_DEPENDENCIES "ParMETIS")
  list(APPEND MUMPS_CONFOPTS "-D metis=true")
  list(APPEND MUMPS_CONFOPTS "-D USER_PROVIDED_PARMETIS_DIR=${ParMETIS_DIR}")
endmacro()

