#***********************************************************************
# This file is part of OpenMolcas.                                     *
#                                                                      *
# OpenMolcas is free software; you can redistribute it and/or modify   *
# it under the terms of the GNU Lesser General Public License, v. 2.1. *
# OpenMolcas is distributed in the hope that it will be useful, but it *
# is provided "as is" and without any express or implied warranties.   *
# For more details see the full text of the license in the file        *
# LICENSE or in <http://www.gnu.org/licenses/>.                        *
#                                                                      *
# Copyright (C) 2015,2016, Ignacio Fdez. Galván                        *
#***********************************************************************
if (NOT DEFINED BASE_DIR)
        set (BASE_DIR ${PROJECT_SOURCE_DIR})
endif ()
file (RELATIVE_PATH tooldir ${BASE_DIR} ${CMAKE_CURRENT_LIST_DIR})
set (EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/${tooldir})

foreach (prog IN ITEMS grid2cube)
        add_executable(${prog}.exe ${prog}.F90)
        file (COPY ${CMAKE_CURRENT_LIST_DIR}/${prog}.py
              DESTINATION ${EXECUTABLE_OUTPUT_PATH}
        )
endforeach (prog)
