#!/bin/bash

# Minimal color palette used by __download output
declare -A _COLOR=(
  [OK]="\033[38;05;40m"
  [ERROR]="\033[38;05;161m"
  [RESET]="\033[m"
)

__echo(){
    echo -e "$@"
}

# [template] !!! DO NOT MODIFY CODE INSIDE, ON NEXT UPDATE CODE WOULD BE REPLACED !!!
# include: tools

# [module: tools]


# shellcheck disable=SC2155,SC2015

# __vercomp version1 version2
# Compare two version strings in dot-separated format
#
#    version1 - first version string (e.g., "1.2.3")
#    version2 - second version string (e.g., "1.3.0")
#
# Results: Returns 0 if equal, 1 if version1 > version2, 2 if version1 < version2
# shellcheck disable=SC2206
__vercomp () {
    [[ "$1" == "$2" ]] && return 0 ; local IFS=. ; local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++));  do ver1[i]=0;  done
    for ((i=0; i<${#ver1[@]}; i++)); do
        [[ -z ${ver2[i]} ]] && ver2[i]=0
        ((10#${ver1[i]} > 10#${ver2[i]})) &&  return 1
        ((10#${ver1[i]} < 10#${ver2[i]})) &&  return 2
    done
    return 0
}

# __urldecode url_string
# Decode URL-encoded string
#
#    url_string - URL-encoded string (e.g., "hello%20world")
#
# Results: Outputs decoded string to stdout (e.g., "hello world")
__urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# __clear_progress
# Clear current line and move cursor up one line
#
# Results: Clears terminal line using ANSI escape codes
__clear_progress(){ printf '\033[A\033[0K\r'; }

# __download [-L] url [destination]
# Download file from URL with progress bar
#
#    -L          - follow redirects (optional)
#    url         - URL to download
#    destination - destination path (default: ./), if ends with / appends filename from URL (optional)
#
# Results: Returns 0 on success, non-zero on failure (curl/aria2c exit code)
#
# Samples:
#   __download "https://example.com/file.zip"
#   __download -L "https://example.com/file.zip" "/tmp/"
#   __download "https://example.com/file.zip" "/tmp/myfile.zip"
__download() {
  [[ "${1^^}" == "-L" ]] && { local _follow_link="-L"; shift; } || local _follow_link=""
  local _url="$1"
  local _file=$(__urldecode "${_url##*/}")
  [[ -z $2 ]] && local _destination="./" || local _destination="$2"
  [[ "${_destination}" == */ ]] && local _dest_path="${_destination}${_file}" || local _dest_path="${_destination}"

  __echo "Downloading file ${_file}: "
  
  # Use curl for special files like /dev/null since aria2c can't handle them
  if command -v aria2c &>/dev/null && [[ ! -c "${_dest_path}" ]]; then
    # shellcheck disable=SC2086
    aria2c --console-log-level=error --summary-interval=0 ${_follow_link:+--max-redirs=5} \
      -d "$(dirname "${_dest_path}")" -o "$(basename "${_dest_path}")" "${_url}" 2>&1
    local _ret=$?
  else
    # shellcheck disable=SC2086
    curl -f ${_follow_link} --progress-bar "${_url}" -o "${_dest_path}" 2>&1
    local _ret=$?
  fi

  [[ ${_ret} -eq 0 ]] && {
    __clear_progress; __clear_progress
    __echo "Downloading file ${_file}: [${_COLOR[OK]}ok${_COLOR[RESET]}]"
  } || {
    __clear_progress; __clear_progress; __clear_progress
    __echo "Downloading file ${_file}: [${_COLOR[ERROR]}fail ${_ret}${_COLOR[RESET]}]"
  }
  return ${_ret} 
}


# [template:end] !!! DO NOT REMOVE ANYTHING INSIDE, INCLUDING CURRENT LINE !!!


main(){
    local v1="1.2.3" v2="1.3"
    __vercomp "${v1}" "${v2}"
    case $? in
        0) echo "Versions are equal: ${v1} == ${v2}";;
        1) echo "${v1} is newer than ${v2}";;
        2) echo "${v1} is older than ${v2}";;
    esac

    echo "Decoded: $( __urldecode "https%3A%2F%2Fexample.com%2Ffile.txt" )"

    __download "https://sin-speed.hetzner.com/1GB.bin" "/dev/null"
}

main "$@"