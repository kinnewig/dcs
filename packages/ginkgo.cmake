macro(build_ginkgo)
  set(oneValueArgs VERSION MD5)
  cmake_parse_arguments(BUILD_GINKO "" "${oneValueArgs}" "" ${ARGN})

  # Assamble the Download URL
  set(TMP_NAME "v${BUILD_GINKO_VERSION}")
  set(TMP_PACKING ".tar.gz")
  set(TMP_URL "https://github.com/ginkgo-project/ginkgo/archive/refs/tags/")
  set(BUILD_GINKO_URL "${TMP_URL}${TMP_NAME}${TMP_PACKING}")

  # Assamble the Mirror (if provided)
  if(DEFINED MIRROR) 
    # overwrite the default packing, in case that the mirror uses a different format
    if (NOT DEFINED MIRROR_PACKING)
      set(TMP_MIRROR_PACKING ${TMP_PACKING})
    else()
      set(TMP_MIRROR_PACKING ${MIRROR_PACKING})
    endif()

    set(BUILD_GINKO_URL "${MIRROR}${TMP_NAME}${TMP_MIRROR_PACKING} ${BUILD_GINKO_URL}")
    unset(TMP_MIRROR_PACKING)
  endif()

  # Unset temporal variables
  unset(TMP_NAME)
  unset(TMP_PACKING)
  unset(TMP_URL)

  build_cmake_subproject(
    NAME ginkgo
    VERSION ${BUILD_GINKGO_VERSION}
    URL ${BUILD_GINKGO_URL}
    MD5 ${BUILD_GINKGO_MD5}
    DOWNLOAD_ONLY ${DOWNLOAD_ONLY}
    BUILD_ARGS
      -D BUILD_SHARED_LIBS:BOOL=ON 
      -D GINKGO_BUILD_TESTS:BOOL=OFF 
      -D GINKGO_FAST_TESTS:BOOL=OFF 
      -D GINKGO_BUILD_EXAMPLES:BOOL=OFF 
      -D GINKGO_BUILD_BENCHMARKS:BOOL=OFF 
      -D GINKGO_BENCHMARK_ENABLE_TUNING:BOOL=OFF 
      -D GINKGO_BUILD_DOC:BOOL=OFF 
      -D GINKGO_VERBOSE_LEVEL=1 
      -D GINKGO_DEVEL_TOOLS:BOOL=OFF 
      -D GINKGO_WITH_CLANG_TIDY:BOOL=OFF 
      -D GINKGO_WITH_IWYU:BOOL=OFF 
      -D GINKGO_CHECK_CIRCULAR_DEPS:BOOL=OFF 
      -D GINKGO_WITH_CCACHE:BOOL=OFF 
      -D GINKGO_BUILD_HWLOC:BOOL=OFF
  )

  list(APPEND DEALII_DEPENDENCIES "ginkgo")
  list(APPEND DEALII_CONFOPTS "-D DEAL_II_WITH_GINKGO:BOOL=ON")
  list(APPEND DEALII_CONFOPTS "-D GINKGO_DIR=${ginkgo_DIR}")
endmacro()
