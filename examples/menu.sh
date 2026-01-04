#!/bin/bash

# Minimal color palette for menu rendering
declare -A _COLOR=(
    [SELECTED]="\033[30;47m"   # black text on white background
    [UNSELECTED]="\033[0;37m" # light gray text
    [RESET]="\033[0m"
)

# [template] !!! DO NOT MODIFY CODE INSIDE, ON NEXT UPDATE CODE WOULD BE REPLACED !!!
# include: menu

# [module: menu]



moveCursor() {
    echo -ne "\033[$(($2+1));$1f"  # or tput cup "$2" "$1"
}


getCurrentPos(){
    local _col; local _row
    # shellcheck disable=SC2162
    IFS=';' read -sdR -p $'\E[6n' _row _col
    echo "${_col} ${_row#*[}"
}

readKey(){
    read -rsN 1 _key
    printf %d "'${_key}"   # %x for hex
}

redrawMenuItems() { 
    local -n _menuItems=$1
    local startPos=$2; local pos=$3; local oldPos=$4
    local menuLen=$((${#_menuItems[@]} + 2))
    local menuOldPosY=$((startPos - (menuLen - oldPos)))
    local menuNewPosY=$((startPos - (menuLen - pos)))
    
    moveCursor "0" "${menuOldPosY}"
    echo -ne "\t${_COLOR[UNSELECTED]}${oldPos}. ${_menuItems[${oldPos}]}${_COLOR[RESET]}" 

    moveCursor "0" "${menuNewPosY}"
    echo -ne "\t${_COLOR[SELECTED]}${pos}. ${_menuItems[${pos}]}${_COLOR[RESET]}"

    moveCursor "0" "${startPos}"
}

drawMenu() {
    local -n _menuItems=$1
    local menuPosition=$2
    local menuTitle="$3"
    local lastIdx=$((${#_menuItems[@]} - 1))

    local __line=$(printf '%*s' "${#menuTitle}" | tr ' ' "=")
    echo -ne "
\t${_COLOR[UNSELECTED]}${__line}${_COLOR[RESET]}
\t${_COLOR[UNSELECTED]} $menuTitle ${_COLOR[RESET]}
\t${_COLOR[UNSELECTED]}${__line}${_COLOR[RESET]}
    "
    echo
    for ((i=0; i<=lastIdx; i++)); do
        [[ $i -ne ${menuPosition} ]] && local __color="UNSELECTED" || local __color="SELECTED"
        [[ -n "${_menuItems[${i}]}" ]] &&  echo -e "\t${_COLOR[${__color}]}$i. ${_menuItems[${i}]}${_COLOR[RESET]}" 
    done
    echo 
}


menu(){
    IFS="," read -ra menuItems <<< "$1"
    local menuTitle="$2"

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

    drawMenu "menuItems" "${pos}" "${menuTitle}"

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

        redrawMenuItems "menuItems" "${startPos}" "${pos}" "${oldPos}"  

    done

    return "${pos}"
}

# [template:end] !!! DO NOT REMOVE ANYTHING INSIDE, INCLUDING CURRENT LINE !!!


# Usage example: call menu with comma-separated items and read the selected index
main(){
    local items="Start service,Stop service,Show status,Quit"
    IFS="," read -ra menu_list <<< "${items}"

    menu "${items}" "Service menu"
    local choice=$?

    if [[ ${choice} -eq 255 ]]; then
        echo "Menu cancelled"
        return 1
    fi

    echo "Selected [${choice}]: ${menu_list[${choice}]}"
}

main "$@"