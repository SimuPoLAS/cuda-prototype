### CMakeLists.txt for CUDA

cmake_minimum_required(VERSION 2.8)
find_package(CUDA QUIET REQUIRED)

# Pass options to NVCC
set(
    CUDA_NVCC_FLAGS
    ${CUDA_NVCC_FLAGS};
    -O3 -ccbin /usr/bin/g++-6 -std=c++11
)

# Specify include directories
include_directories(
    cudasrc
    src
    
)

# Specify library paths
# link_directories()

# For compilation ...
# Specify target & source files to compile it from
cuda_add_executable(
    add
    cudasrc/add.cu
)

# For linking ...
# Specify target & libraries to link it with
# target_link_libraries()
