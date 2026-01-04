#!/bin/bash

# Copyright 2022 FluffyContainers
# GitHub: https://github.com/FluffyContainers

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [start]

# shellcheck disable=SC2155,SC2015

# _COLOR
# Associative array containing ANSI color codes for terminal output
# Available color keys:
#    INFO       - cyan color for informational messages
#    ERROR      - red color for error messages
#    WARN       - orange color for warning messages
#    OK         - green color for success messages
#    GRAY       - gray color for secondary text
#    RED        - bright red color
#    DARKPINK   - dark pink/purple color
#    SELECTED   - black text on white background (for menu selection)
#    UNSELECTED - light gray text (for unselected menu items)
#    RESET      - reset to default terminal colors
#
# Samples:
#   echo -e "${_COLOR[INFO]}This is info${_COLOR[RESET]}"
#   echo -e "${_COLOR[ERROR]}Error occurred${_COLOR[RESET]}"
declare -A _COLOR=(
    [INFO]="\033[38;05;39m"
    [ERROR]="\033[38;05;161m"
    [WARN]="\033[38;05;178m"
    [OK]="\033[38;05;40m"
    [GRAY]="\033[38;05;245m"
    [RED]="\033[38;05;160m"
    [DARKPINK]="\033[38;05;127m"

    # For menu rendering
    [SELECTED]="\033[30;47m"  # black text on white background
    [UNSELECTED]="\033[0;37m" # light gray text

    [RESET]="\033[m"
)

# [end]