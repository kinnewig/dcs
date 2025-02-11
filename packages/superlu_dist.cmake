macro(build_superlu_dist)
  set(oneValueArgs VERSION MD5 MIRROR_NAME)
  cmake_parse_arguments(BUILD_SUPERLU "" "${oneValueArgs}" "" ${ARGN})
  
  # Assamble the Download URL
  set(TMP_NAME "v${BUILD_SUPERLU_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/xiaoyeli/superlu_dist/archive/refs/tags/")
  set(BUILD_SUPERLU_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()
    
    if (DEFINED BUILD_SUPERLU_MIRROR_NAME)
      set(TMP_NAME ${BUILD_SUPERLU_MIRROR_NAME})
    endif()

    set(BUILD_SUPERLU_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_SUPERLU_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  # Build SuperLU-dist
  build_cmake_subproject(
    NAME SuperLU_DIST
    VERSION ${BUILD_SUPERLU_VERSION}
    URL ${BUILD_SUPERLU_URL}
    MD5 ${BUILD_SUPERLU_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D TPL_PARMETIS_INCLUDE_DIRS:PATH=${ParMETIS_DIR}/include
      -D TPL_PARMETIS_LIBRARIES:PATH=${ParMETIS_LIB}
      -D TPL_BLAS_LIBRARIES=${BLAS_LIBS}
      -D TPL_ENABLE_LAPACKLIB=ON
      -D CMAKE_C_COMPILER=${CMAKE_MPI_C_COMPILER}
      -D CMAKE_CXX_COMPILER=${CMAKE_MPI_CXX_COMPILER}
      -D CMAKE_C_FLAGS:STRING=-fPIC      
      -D CMAKE_Fortran_FLAGS:STRING=-fPIC ${BLAS_Fortran_FLAGS}
      -D BUILD_SHARED_LIBS:BOOL=ON
    DEPENDS_ON ${BLAS_PROJECT_NAME} ParMETIS
  )
  
  list(APPEND TRILINOS_DEPENDENCIES "SuperLU_DIST")
  list(APPEND TRILINOS_CONFOPTS "-D TPL_ENABLE_SuperLUDist:BOOL=ON")
  list(APPEND TRILINOS_CONFOPTS "-D TPL_SuperLUDist_LIBRARIES:FILEPATH=${SuperLU_DIST_DIR}/lib/libsuperlu_dist${CMAKE_SHARED_LIBRARY_SUFFIX}")
  list(APPEND TRILINOS_CONFOPTS "-D SuperLUDist_INCLUDE_DIRS:PATH=${SuperLU_DIST_DIR}/include")
  list(APPEND TRILINOS_CONFOPTS "-D HAVE_SUPERLUDIST_LUSTRUCTINIT_2ARG:BOOL=ON")
  list(APPEND TRILINOS_CONFOPTS "-D HAVE_SUPERLUDIST_ENUM_NAMESPACE:BOOL=ON")
endmacro()
