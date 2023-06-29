macro(build_dealii)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_DEALII "" "${oneValueArgs}" "" ${ARGN})

  string(REPLACE "." ";" TMPLIST ${BUILD_DEALII_VERSION})
  list(GET TMPLIST 0 BUILD_DEALII_MAJOR_VERSION)
  list(GET TMPLIST 1 BUILD_DEALII_MINOR_VERSION)
  
  #Sundials only works with newer deal.II version (>=9.1.0)
  if(DEFINED BUILD_SUNDIALS_VERSION)
    if(BUILD_DEALII_MAJOR_VERSION STRGREATER_EQUAL "9" AND BUILD_DEALII_MINOR_VERSION STRGREATER_EQUAL "1")
      list(APPEND DEALII_DEPENDENCIES "sundials")
      list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_SUNDIALS:BOOL=ON")
      list(APPEND DEALII_CONFOPTS "-D SUNDIALS_DIR=${sundials_DIR}")
    else()
      list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_SUNDIALS:BOOL=OFF")
    endif()
  endif()
  
  if(DEFINED BOOST_DIR)
    list(APPEND DEALII_CONFOPTS "-D BOOST_DIR=${BOOST_DIR}")
    else()
  endif()

  # Assamble the Download URL
  set(TMP_NAME "v${BUILD_DEALII_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/dealii/dealii/releases/download/${BUILD_DEALII_VERSION}/")
  set(BUILD_DEALII_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    set(BUILD_DEALII_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_DEALII_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()
 
  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  build_cmake_subproject(
    NAME dealii
    VERSION ${BUILD_DEALII_VERSION}
    URL ${BUILD_DEALII_URL}
    MD5 ${BUILD_DEALII_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D CMAKE_BUILD_TYPE=DebugRelease
      -D BUILD_SHARED_LIBS:BOOL=ON
      -D DEAL_II_WITH_MPI:BOOL=ON 
      -D DEAL_II_COMPONENT_DOCUMENTATION:BOOL=OFF 
      -D DEAL_II_WITH_LAPACK:BOOL=ON
      -D DEAL_II_WITH_UMFPACK:BOOL=ON
      -D DEAL_II_FORCE_BUNDLED_UMFPACK:BOOL=OFF 
      -D DEAL_II_WITH_BOOST:BOOL=ON 
      -D DEAL_II_FORCE_BUNDLED_BOOST:BOOL=OFF 
      -D DEAL_II_WITH_ZLIB:BOOL=ON
      -D DEAL_II_COMPONENT_EXAMPLES:BOOL=ON
      -D CMAKE_CXX_COMPILER="-Wchanges-meaning"
      -D CMAKE_POLICY_DEFAULT_CMP0057:STRING=NEW 
      -D CMAKE_POLICY_DEFAULT_CMP0074:STRING=NEW
      ${DEALII_CONFOPTS}
      DEPENDS_ON ${DEALII_DEPENDENCIES}
  )
  if(BUILD_DEALII_MAIN)
    set(MAIN_DEAL_II dealii-${BUILD_DEALII_VERSION})
    set(MAIN_DEAL_II_DIR ${${MAIN_DEAL_II}_DIR})
    list(APPEND DEALII_VERSIONS "${BUILD_DEALII_VERSION}*")
  else()
    list(APPEND DEALII_VERSIONS ${BUILD_DEALII_VERSION})
  endif()
  
endmacro()
