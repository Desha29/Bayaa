# Distributed under the OSI-approved MIT License.  See accompanying
# file LICENSE or https://github.com/Crascit/DownloadProject for details.

cmake_minimum_required(VERSION 3.10)

project(pdfium-download NONE)

include(ExternalProject)

if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24")
  cmake_policy(SET CMP0135 NEW)
endif()

ExternalProject_Add(pdfium-download
                    URL;https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/5200/pdfium-win-x64.tgz
                    SOURCE_DIR          "D:/Work/crazy_phone_pos/windows/build/pdfium-src"
                    BINARY_DIR          "D:/Work/crazy_phone_pos/windows/build/pdfium-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
)
