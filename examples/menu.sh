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
H4sIAAAAAAAAA31SW2/aMBR+z6+wYA9FGlqAsnZDPEQ0nRAVmQLTNHVoMs4hsUgcZCdt0cR/37GNw2XaIpSEfJdz8ed5baIyyHOWAduShCu6zmG8mPR7w+F7fPi9oYecX5PoKYrxJVCqZJxW/AUIlZLuCStFRbngIiXBfDHF/3kp8Z6AIht8q0AWXNCclHW1qyvt8UJ5ruscuVvYq8/4Ha/p/DEi9uoStqfiSNFGXOC9wNKlditAKZqCsrowjqPY6SQkZzKQEu+X9O9BPG/KlJKKFM4Ur1SacS410YyQRpNKgPPeVM0Ysq8kX+Lgx5nELKtRAC4uoXKPC3qrLD8OH04l1pKnWXUaxlIegnj2dTqfGQrKt2THxfbDrpY7t09LXIRP4WRpDNErp3i6uhApBXnNeAVkjZ9SWdYiITcbsyFRY1c5ML3hjnX5Nm98uiQ3DZk5jJWR1cJqsE3jgNaF6rh5FuHydCoKKlKVJIENrfPqFAzTNa4MRQta4BzHNADLStIF0nr32+bvWcdjdVhmXBH9w0A0kKm1OrT+oTQBWR1CE4aSsVriYv8WJ8ByKoF0g2Pkxzeebt9WHrd++oPB8+B+5A9Hg09Fy2LW+wLsfew5VGftCry7d2A0u4RufYfo7Fxi/duhAzEo1/UaoUvIFaF/hwTDaJNHd9wSRAISs26l7qwbqT+6RZmW/D9BVn4KizPwRwOtb19Hx3Nj6LUfudhex/P+AEt7NyKRBAAA
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
H4sIAAAAAAAAA3VSXWvbQBB8168YzgqSWgSVA3mIyUMxaTGlJcSPDgRFt4qOyHfi9pQmDf7v3ZNtnEIjhD525mZn5y5JZti6Z1qOnp1H4/pxa+Hdb6n/lDqaPRAceKDGtKbB4NgE4yzkDh2BG09kZcFhdYnOefPH2VD3J3JelQ81ky6EKPqQq8Qz+WCa/9NOtvICb0lcQE3nUFqCuvtyfr5J8zydf66KYpFWrQJmiE6HMYjrASqdK3lUKtkl0vORgqh5suHGsfx/p0ibCschjyYEvSUe+8CXuJaWxB8xUTPUKTSV/NMlL/a2exdHvBfe4vgdE47QDNxR3zcdNU/QhuuHnq7Wy3l1MZ/w1bf1VbbI4KnWKFnfohyQZnfXmwubTTKT7ikdlb7Fwg7yFnT2abM7BBAlftDrNJyI1WBjH3vCE71i8MSM2mphhdFbmMD4ul6uVrKpmt4HcuONFTBu/J6g5VhsZaZIhGsnZNIjHbWTQ99jGPtJPP9ChfuIx+IQRVucaahMjEt5p6Z0zl7QSt4dvcQh/gLztd5HrgIAAA==
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
# 
# Results: Returns selected item index (0-based) via return code, 255 if cancelled (ESC pressed twice)
# 
# Samples:
#   menu "Option A,Option B,Option C" "Select an option"
#   selected=$?
#   [[ $selected -eq 255 ]] && echo "Cancelled" || echo "Selected: $selected"
eval "$(base64 -d <<'B64' | gunzip
H4sIAAAAAAAAA61XbW/iRhD+zq+YLr6LHSAyDiQ9COoLR6Wo6eUU0g8VpchnL7A6Y7v2EhIR+ts7u16/gUly0vl0wfbOM8/svK5rdWC+461d2gMn8IIobvJwzWu1WkTdyN78Qf31NaerWDdgCzXAywsc24OWD7NVujjQ2oWlmNsR/xzgW6uvXoXi6Tx9CjxXLncKIKHrhvoDTde1bT1XPfl5uoMGWIaxJ3wrlfwlACkhtEBXevA2YTEOgJ/o5mVgmKPkn1XwQIfrKA4iICYBom0L/DsiZaizDNAnFMjfXNvOhrc3t3eTPz+NRzej4f3o43SnbRN7dmeA6/n2svdCROHuRuPR/XRHoPYCv9rGS/xF9rCKOqzmPUabugsldrVamh4iM96WGOI1whlnAQba2lu5Z9yjA6Kdk8KCZ8f82n2sTosWtDFOBenZzGM+ReEwYj6fw8m70/hEWF7PCNCrz8AjOMF/ZECMPe/VjoYv0X3grGMA0DJKeCvmOIkwMg+0vJljXHSdDcw+sKuB8hPeNxqG0Qc3ERLXZAIak7tLEieNwA6mU3j/PnOdLP8ByQ1CTz3vr2ZrRfUYcrKXWWwn8jchUO4t56bYq9QpEpAdZCarrgdB6AY+zaMmMrEu8weYwM6c+EE+zrjwPa59ZHHo2U/Y5ziNbIezB5rI274LEeXryIeYetTh1EUhlz7W6gjDK1eIqeYEq5XdimloR7aQ9FjMIZgXqEGnZ4uzJhCxCWg35Y+V/JxjpkmduWmoM/l1EwNRp82BLynwIBSaxa0Ql+bc0Xjt8biHN8LiuGCy0C/tBt1sfbFj6hrwwOx0b07g0iZY3S6wOTi271DPQ5g+Gg8hjGiM8sA3zKGGJBrbq9CjcU+aKzdHbkORL/BLU938mt4MsS2MpR3oTAjkSyKBqXUD7Sf5LJIws7hF/5X2JOkhw0iGqWEy65J3YwXo5VhSW8mWk3Sc69/GA9IkuFMbtUY2ZCkEV1dXmJRtcqTJWKrJ1eEzQm3PUyHkQeJ2+xE2zOVLiANYssXSw/8c4tBGz8/XKC7qtNh5EDHzcH6ZWXGquKT9Omtb5KA6t3Uhi/1swWUdJKrS+sxUp3LlKpBUiueHF4hUS2w9ACkUGptiCN+1CqwxKVuMImrGSMrCnr/SpyHm1kA3iyNWjHqz8KyGvXm0qR/t6emAKRgsbRNTKzNSNfWiXemYGvMIKRaU4xSLqC9eGf2qc0phtCGmfgqpvs2SYX3KEKnNTkxhI/bStonhKTl4zylE00Va/k6fDGJgnn154ojKpLEWD/WKuriUejEJfQTR2LFDCs7SFp2LRpDhDxgbRyitEmSfttVW+ynzOkvqfGX+QsivY+RNGwVasba9ksrXLUlNOT/AHbxI7CPdNnRN6PwIXQu659DtEBj8B/o/z5NJD4vQob3p1CD5NizMUV0rrWbbOeA4EtnMFW3rYj+237jfio2JK6vZ4jVnx5zQ+fC9d/22MHUqsS/5Kj9GvJKM3beqxkrofvgmzUnOfn/TXwtY4XHO1Ik993X6qSObVrbm4JCGQiBPxeEGW3hJMcGS/NCGi64ITeEzStdD+cWCfbLfF0Fbh5W4i0pcI8e5wcavQmLBoW8QXUFqSXAdwkU1a7dzDNsoYN1K3kurhDOl8DJY0Uphs0yyVUNlJ1HUdw9A1iUi1JkITx9CzFJ9LRbHLTwPZRga204eSpk/IoDQ8jiYpazJx92epJzlqVEHkHwpp9n74t4fe/nXV2kIqs9HAir38imt9poK40n5f/nceAbuDwAA
B64
)"
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