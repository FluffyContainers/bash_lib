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
# include: colors,tput


redrawMenuItems() { 
    local -n _menuItems=$1
    local startPos=$2; local pos=$3; local oldPos=$4; local style=$5
    local menuLen=$((${#_menuItems[@]} + 2))
    local menuOldPosY=$((startPos - (menuLen - oldPos)))
    local menuNewPosY=$((startPos - (menuLen - pos)))
    
    moveCursor "0" "${menuOldPosY}"
    local _old_prefix="  "
    local _old_color="UNSELECTED"
    [[ "${style}" == "number" ]] && _old_prefix="${oldPos}. "
    echo -ne "  ${_COLOR[${_old_color}]}${_old_prefix}${_menuItems[${oldPos}]}${_COLOR[RESET]}" 

    moveCursor "0" "${menuNewPosY}"
    local _new_prefix="> "
    local _new_color="SELECTED"
    if [[ "${style}" == "number" ]]; then
        _new_prefix="${pos}. "
    else
        _new_prefix="${_COLOR[RED]}> ${_COLOR[UNSELECTED]}"
        _new_color="UNSELECTED"
    fi
    echo -ne "  ${_COLOR[${_new_color}]}${_new_prefix}${_menuItems[${pos}]}${_COLOR[RESET]}"

    moveCursor "0" "${startPos}"
}

drawMenu() {
    local -n _menuItems=$1
    local menuPosition=$2
    local menuTitle="$3"
    local style="$4"
    local lastIdx=$((${#_menuItems[@]} - 1))
    local _indent="  "

    if [[ -n "${menuTitle}" ]]; then
        # Derive box width from padded items and prefix style
        local _prefix_width=2
        [[ "${style}" == "number" ]] && _prefix_width=$(( ${#lastIdx} + 2 ))
        local _row_width=$((_prefix_width + ${#_menuItems[0]}))

        local _box_width=$((_row_width + 2))
        local __line=$(printf '─%.0s' $(seq 1 ${_box_width}))
        printf "\n%s${_COLOR[UNSELECTED]}┌%s┐${_COLOR[RESET]}\n" "${_indent}" "${__line}"
        printf "%s${_COLOR[UNSELECTED]}│ %-*s │${_COLOR[RESET]}\n" "${_indent}" "${_row_width}" "${menuTitle}"
        printf "%s${_COLOR[UNSELECTED]}└%s┘${_COLOR[RESET]}\n" "${_indent}" "${__line}"
    else
        echo
    fi
    for ((i=0; i<=lastIdx; i++)); do
        local __color="UNSELECTED"
        local __prefix="  "
        if [[ "${style}" == "number" ]]; then
            [[ $i -eq ${menuPosition} ]] && __color="SELECTED"
            __prefix="$i. "
        else
            [[ $i -eq ${menuPosition} ]] && __prefix="${_COLOR[RED]}> ${_COLOR[UNSELECTED]}"
        fi
        [[ -n "${_menuItems[${i}]}" ]] &&  echo -e "  ${_COLOR[${__color}]}${__prefix}${_menuItems[${i}]}${_COLOR[RESET]}" 
    done
    echo 
}

# menu items_csv menu_title
# Display interactive menu and return selected index
#
#    items_csv  - comma-separated list of menu items (e.g., "Item 1,Item 2,Item 3")
#    menu_title - title displayed at the top of the menu
#    style      - optional, "number" (default) or "arrow" to show " >" only on the current selection without changing colors
#
# Results: Returns selected item index (0-based) via return code, 255 if cancelled (ESC pressed twice or Ctrl+C)
#
# Samples:
#   menu "Option A,Option B,Option C" "Select an option"
#   selected=$?
#   [[ $selected -eq 255 ]] && echo "Cancelled" || echo "Selected: $selected"
menu(){
    IFS="," read -ra menuItems <<< "$1"
    local menuTitle="$2"
    local menuStyle="${3:-number}"

    # Set up trap for Ctrl+C to exit gracefully with code 255
    trap 'return 255' INT

    # Pad all items to the max width so highlight spans full line
    local _max_len=0
    for item in "${menuItems[@]}"; do
        [[ ${#item} -gt ${_max_len} ]] && _max_len=${#item}
    done
    for i in "${!menuItems[@]}"; do
        printf -v "menuItems[$i]" "%-${_max_len}s" "${menuItems[$i]}"
    done

    local keyCode=(0)
    local pos=0
    local oldPos=0
    local lastIdx=$((${#menuItems[@]} - 1))

    drawMenu "menuItems" "${pos}" "${menuTitle}" "${menuStyle}"

    local startPosStr=$(getCurrentPos);
    local startPos="${startPosStr#* }"

    while [[ ${keyCode[0]} -ne 10 ]]; do
        local keyCode=("$(readKey)") # byte 1
        if [[ ${keyCode[0]} -eq 27 ]]; then # escape character 
            local keyCode+=("$(readKey)") # byte 2
            if [[ ${keyCode[-1]} -ne 27 ]]; then # checking if user pressed actual
                local keyCode+=("$(readKey)")  # byte 3
                
                if [[ "51 50 48 52 53 54" =~ (^|[[:space:]])"${keyCode[2]}"($|[[:space:]]) ]]; then
                    while [[ ${keyCode[-1]} -ne 126 ]]; do
                        local keyCode+=("$(readKey)")    
                    done
                fi
                if [[ "49" =~ (^|[[:space:]])"${keyCode[2]}"($|[[:space:]]) ]]; then
                    local keyCode+=("$(readKey)")  # byte 4
                    [[ ${keyCode[-1]} -ne 126 ]] && local keyCode+=("$(readKey)") # byte 5
                    [[ ${keyCode[-1]} -eq 59 ]] && local keyCode+=("$(readKey)") # byte 5 check
                    [[ ${keyCode[-1]} -ne 126 ]] && local keyCode+=("$(readKey)")
                fi
            fi
        fi 

        local oldPos=${pos}
        case "${keyCode[*]}" in 
            "27 91 65")  local pos=$((pos - 1));;  # up
            "27 91 66")  local pos=$((pos + 1));;  # down
            "27 91 53 126") local pos=$((pos - 2));; # pgup
            "27 91 54 126") local pos=$((pos + 2));; # pgdn
            "27 91 72") local pos=0;; # home
            "27 91 70") local pos=${lastIdx};; # end
            "27 27") return 255; # 2 presses of ESC
        esac

        [[ ${pos} -lt 0 ]] && local pos=0
        [[ ${pos} -gt ${lastIdx} ]] && local pos=${lastIdx}

        redrawMenuItems "menuItems" "${startPos}" "${pos}" "${oldPos}" "${menuStyle}"  

    done

    # Restore default INT handler before returning
    trap - INT
    return "${pos}"
}
# [end]