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

# [end]