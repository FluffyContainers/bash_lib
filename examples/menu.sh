#!/bin/bash

# [template] !!! DO NOT MODIFY CODE INSIDE, ON NEXT UPDATE CODE WOULD BE REPLACED !!!
# include: menu
# opts: binary

# [module: colors] (dependency) (binary)
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
eval "$(base64 -d <<'B64' | gunzip
H4sIAAAAAAAAA31SW2/aMBR+z6+wYA9FGlqAsnZDPEQ0nRAVmQLTNHVoMs4hsUgcZCdt0cR/37GNw2XaIpSEfJdz8ed5baIyyHOWAduShCu6zmG8mPR7w+F7
fPi9oYecX5PoKYrxJVCqZJxW/AUIlZLuCStFRbngIiXBfDHF/3kp8Z6AIht8q0AWXNCclHW1qyvt8UJ5ruscuVvYq8/4Ha/p/DEi9uoStqfiSNFGXOC9wNKl
ditAKZqCsrowjqPY6SQkZzKQEu+X9O9BPG/KlJKKFM4Ur1SacS410YyQRpNKgPPeVM0Ysq8kX+Lgx5nELKtRAC4uoXKPC3qrLD8OH04l1pKnWXUaxlIegnj2
dTqfGQrKt2THxfbDrpY7t09LXIRP4WRpDNErp3i6uhApBXnNeAVkjZ9SWdYiITcbsyFRY1c5ML3hjnX5Nm98uiQ3DZk5jJWR1cJqsE3jgNaF6rh5FuHydCoK
KlKVJIENrfPqFAzTNa4MRQta4BzHNADLStIF0nr32+bvWcdjdVhmXBH9w0A0kKm1OrT+oTQBWR1CE4aSsVriYv8WJ8ByKoF0g2Pkxzeebt9WHrd++oPB8+B+
5A9Hg09Fy2LW+wLsfew5VGftCry7d2A0u4RufYfo7Fxi/duhAzEo1/UaoUvIFaF/hwTDaJNHd9wSRAISs26l7qwbqT+6RZmW/D9BVn4KizPwRwOtb19Hx3Nj
6LUfudhex/P+AEt7NyKRBAAA
B64
)"
# [module: tput] (dependency) (binary)
# moveCursor column row
# Move cursor to specific position on the screen
# column - horizontal position (1-based)
# row    - vertical position (1-based)
# 
# getCurrentPos
# Get current cursor position
# Results: Echoes current cursor position as "column row"
# 
# readKey
# Read a single key press and return its ASCII code
# Results: Prints the ASCII decimal code of the pressed key
eval "$(base64 -d <<'B64' | gunzip
H4sIAAAAAAAAA3VSXWvbQBB8168YzgqSWgSVA3mIyUMxaTGlJcSPDgRFt4qOyHfi9pQmDf7v3ZNtnEIjhD525mZn5y5JZti6Z1qOnp1H4/pxa+Hdb6n/lDqa
PRAceKDGtKbB4NgE4yzkDh2BG09kZcFhdYnOefPH2VD3J3JelQ81ky6EKPqQq8Qz+WCa/9NOtvICb0lcQE3nUFqCuvtyfr5J8zydf66KYpFWrQJmiE6HMYjr
ASqdK3lUKtkl0vORgqh5suHGsfx/p0ibCschjyYEvSUe+8CXuJaWxB8xUTPUKTSV/NMlL/a2exdHvBfe4vgdE47QDNxR3zcdNU/QhuuHnq7Wy3l1MZ/w1bf1
VbbI4KnWKFnfohyQZnfXmwubTTKT7ikdlb7Fwg7yFnT2abM7BBAlftDrNJyI1WBjH3vCE71i8MSM2mphhdFbmMD4ul6uVrKpmt4HcuONFTBu/J6g5VhsZaZI
hGsnZNIjHbWTQ99jGPtJPP9ChfuIx+IQRVucaahMjEt5p6Z0zl7QSt4dvcQh/gLztd5HrgIAAA==
B64
)"
# [module: menu] (binary)
# include: colors,tput
# 
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
eval "$(base64 -d <<'B64' | gunzip
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
AAA=
B64
)"
# [template:end] !!! DO NOT REMOVE ANYTHING INSIDE, INCLUDING CURRENT LINE !!!


# Usage example: call menu with comma-separated items and read the selected index
main(){
    local items="Start service,Stop service,Show status,Quit"
    IFS="," read -ra menu_list <<< "${items}"

    menu "${items}" "Services" "arrow"
    local choice=$?

    if [[ ${choice} -eq 255 ]]; then
        echo "Menu cancelled"
        return 1
    fi

    echo "Selected [${choice}]: ${menu_list[${choice}]}"
}

main "$@"