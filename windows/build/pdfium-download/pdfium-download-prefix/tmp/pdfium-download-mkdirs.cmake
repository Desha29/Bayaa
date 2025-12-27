# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "D:/Work/crazy_phone_pos/windows/build/pdfium-src")
  file(MAKE_DIRECTORY "D:/Work/crazy_phone_pos/windows/build/pdfium-src")
endif()
file(MAKE_DIRECTORY
  "D:/Work/crazy_phone_pos/windows/build/pdfium-build"
  "D:/Work/crazy_phone_pos/windows/build/pdfium-download/pdfium-download-prefix"
  "D:/Work/crazy_phone_pos/windows/build/pdfium-download/pdfium-download-prefix/tmp"
  "D:/Work/crazy_phone_pos/windows/build/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp"
  "D:/Work/crazy_phone_pos/windows/build/pdfium-download/pdfium-download-prefix/src"
  "D:/Work/crazy_phone_pos/windows/build/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp"
)

set(configSubDirs Debug;Release;MinSizeRel;RelWithDebInfo)
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "D:/Work/crazy_phone_pos/windows/build/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "D:/Work/crazy_phone_pos/windows/build/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp${cfgdir}") # cfgdir has leading slash
endif()
