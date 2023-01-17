macro(build_packages)
  ## go through all bools and build wanted packages
  ## This list sorted by types 
  ## Package A needed for package B should have it's build call first
  
  if(${INSTALL_hdf5})
    build_hdf5(
      VERSION ${HDF5_VERSION} 
      MD5     ${HDF5_MD5}
    )
  endif()
  ##############################################################################
  ##   GEOMETRY/CAD PACKAGES                                                  ##
  ##############################################################################
  if(${INSTALL_opencascade})
    build_opencascade(
      VERSION ${OPENCASCADE_VERSION} 
      MD5     ${OPENCASCADE_MD5}
    )
  endif()
  
  if(${INSTALL_assimp})
    build_assimp(
      VERSION ${ASSIMP_VERSION} 
      MD5     ${ASSIMP_MD5}
    )
  endif()
    
  if(${INSTALL_gmsh})
    build_gmsh(
      VERSION ${GMSH_VERSION} 
      MD5     ${GMSH_MD5}
    )
  endif()

  ##############################################################################
  ##   PARALLEL TOOLS                                                         ##
  ##############################################################################
  if(${INSTALL_parmetis})
    build_parmetis(
      VERSION ${PARMETIS_VERSION} 
      MD5     ${PARMETIS_MD5}
    )
  endif()
  
  if(${INSTALL_p4est})
    build_p4est(
      VERSION ${P4EST_VERSION} 
      MD5     ${P4EST_MD5}
    )
  endif()

  ##############################################################################
  ## BLAS/LAPACK/SCALAPACK STACK                                              ##
  ##############################################################################
  if(${INSTALL_openblas})
    build_openblas(
      VERSION ${OPENBLAS_VERSION}
      MD5     ${OPENBLAS_MD5}
    )
  endif()

  if(${INSTALL_scalapack})
    build_scalapack(
      VERSION ${SCALAPACK_VERSION}
      MD5     ${SCALAPACK_MD5}
    )
  endif()
  
  ##############################################################################
  ##   SOLVERS AND PARALLEL LA                                                ##
  ##############################################################################
  if(${INSTALL_superlu_dist})
    build_superlu_dist(
      VERSION ${SUPERLU_DIST_VERSION}
      MD5     ${SUPERLU_DIST_MD5}
    )
  endif()

  if(${INSTALL_mumps})
    build_mumps(
      VERSION ${MUMPS_VERSION}
      MD5     ${MUMPS_MD5}
    )
  endif()

  if(${INSTALL_ginkgo})
    build_ginkgo(
      VERSION ${GINKO_VERSION}
      MD5     ${GINKO_MD5}
    )
  endif()  

  if(${INSTALL_trilinos})
    build_trilinos(
      VERSION ${TRILINOS_VERSION}
      MD5     ${TRILINOS_MD5}
    )
  endif()
    
  ##############################################################################
  ##   ADVANCED MATHS PACKAGES                                                ##
  ##############################################################################
  if(${INSTALL_adolc})
    build_adolc(
      VERSION ${ADOLC_VERSION}
      MD5     ${ADOLC_MD5}
    )
  endif()

  if(${INSTALL_arpack})
    build_arpack(
      VERSION ${ARPACK_VERSION}
      MD5     ${ARPACK_MD5}
    )
  endif()

  if(${INSTALL_symengine})
    build_symengine(
      VERSION ${SYMENGINE_VERSION}
      MD5     ${SYMENGINE_MD5}
    )
  endif()

  if(${INSTALL_sundials})
    build_sundials(
      VERSION ${SUNDIALS_VERSION}
      MD5     ${SUNDIALS_MD5}
    )
  endif()
endmacro()
