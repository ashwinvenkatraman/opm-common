# Look for the cjson library; will probably newer be found.
# If found, it sets these variables:
#
#       CJSON_INCLUDE_DIRS      Header file directories
#       CJSON_LIBRARRY          Archive/shared objects

if (CJSON_ROOT)
  set (_no_default_path "NO_DEFAULT_PATH")
else (CJSON_ROOT)
  set (_no_default_path "")
endif (CJSON_ROOT)


find_path (CJSON_INCLUDE_DIR
  NAMES "cjson/cJSON.h"
  HINTS "${CJSON_ROOT}"
  PATHS "../opm-parser"
  PATH_SUFFIXES "include" "opm/json"
  DOC "Path to cjson library header files"
  ${_no_default_path} )


find_library (CJSON_LIBRARY
  NAMES "cjson"
  HINTS "${CJSON_ROOT}"
  PATHS "${PROJECT_BINARY_DIR}/../opm-parser"
        "${PROJECT_BINARY_DIR}/../opm-parser-build"
        "${PROJECT_BINARY_DIR}/../../opm-parser/build"
        "${PROJECT_BINARY_DIR}/../../opm-parser/cmake-build"
  PATH_SUFFIXES "lib" "lib${_BITS}" "lib/${CMAKE_LIBRARY_ARCHITECTURE}"
                "opm/json"
  DOC "Path to cjson library archive/shared object files"
  ${_no_default_path} )

# setup list of all required libraries to link with cjson
set (CJSON_LIBRARIES ${CJSON_LIBRARY})

# math library (should exist on all unices; automatically linked on Windows)
if (UNIX)
  find_library (MATH_LIBRARY NAMES "m")
  list (APPEND CJSON_LIBRARIES ${MATH_LIBRARY})
endif (UNIX)

# see if we can compile a minimum example
# CMake logical test doesn't handle lists (sic)
if (NOT (CJSON_INCLUDE_DIR MATCHES "-NOTFOUND" OR CJSON_LIBRARIES MATCHES "-NOTFOUND"))
  include (CMakePushCheckState)
  include (CheckCSourceCompiles)
  cmake_push_check_state ()
  set (CMAKE_REQUIRED_INCLUDES ${CJSON_INCLUDE_DIR})
  set (CMAKE_REQUIRED_LIBRARIES ${CJSON_LIBRARIES})

  check_c_source_compiles (
"#include <stdlib.h>
#include <cjson/cJSON.h>
int main (void) {
    cJSON root;
  return 0;
}"  HAVE_CJSON)
  cmake_pop_check_state ()
else ()
  # clear the cache so the find probe is attempted again if files becomes
  # available (only upon a unsuccessful *compile* should we disable further
  # probing)
  set (HAVE_CJSON)
  unset (HAVE_CJSON CACHE)
endif ()

# if the test program didn't compile, but was required to do so, bail
# out now and display an error; otherwise limp on
find_package_handle_standard_args (cjson
  DEFAULT_MSG
  CJSON_INCLUDE_DIR CJSON_LIBRARIES HAVE_CJSON
  )
