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

# shellcheck disable=SC2155,SC2015


# How to use first time: 
# - create file in "src" folder
# - add line with content "# [template]"
# - execute update_includes.sh file
# ...
# - after first execution, files would be automaticaly updated with any new script execution

__dir(){
  local __source="${BASH_SOURCE[0]}"
  while [[ -h "${__source}" ]]; do
    local __dir=$(cd -P "$( dirname "${__source}" )" 1>/dev/null 2>&1 && pwd)
    local __source="$(readlink "${__source}")"
    [[ ${__source} != /* ]] && local __source="${__dir}/${__source}"
  done
  echo -n "$(cd -P "$( dirname "${__source}" )" 1>/dev/null 2>&1 && pwd)"
}

DIR=$(__dir)
LINK_DIR=$(cd -P "$( dirname "${BASH_SOURCE[0]}" )" 1>/dev/null 2>&1 && pwd)


TPL_DIR="${DIR}/modules"
TPL_LINK_MARKER=".module"
REPLACE_MARKER=".replace"

__START_INCLUDE="[template] !!! DO NOT MODIFY CODE INSIDE. INSTEAD USE apply-teplate.sh script to update template !!!"
__END_INCLUDE="[template] [end] !!! DO NOT REMOVE ANYTHING INSIDE, INCLUDING CURRENT LINE !!!"

__START_BLOCK="[start]"
__END_BLOCK="[end]"
__TEMPLATE_PLACEHOLDER="[template]"
__MODULE_OPTIONS="options:"

# key format -> [module_name,is_optional] = module_content
declare -A _TEMPLATES=()


module_exists(){
  local _query="$1"
  for a in "${!_TEMPLATES[@]}"; do
    IFS="," read -r -a arr <<< "${a}"
    [[ "${arr[0]}" == "${_query}" ]] && return 0 || true
  done
  return 1
}

proccess_module(){
    local f="${1}"
    local _can_copy=0
    local _scan_options=0
    local _opts_len=${#__MODULE_OPTIONS}
    
    local _module_name=$(basename "${f}")
    local _module_content=""
    # options
    local _optional=0

    while IFS= read -rs line; do
      [[ "${line}" == "# ${__START_BLOCK}" ]] && {
        local _can_copy=1
        local _scan_options=1
        continue
      }

      
      [[ _scan_options -eq 1 ]] && {
        [[ "${line:2:${_opts_len}}" == "${__MODULE_OPTIONS}" ]] && {
                # local _options=(${line:$((_opts_len + 2))})
                IFS=" " read -r -a _options <<< "${line:$((_opts_len + 2))}"
                for opt in "${_options[@]}"; do 
                  [[ "${opt}" == "optional" ]] && local _optional=1
                done
                continue
        } || local _scan_options=0
      } 

      [[ "${line}" == "# ${__END_BLOCK}" ]] && local _can_copy=0
      [[ ${_can_copy} -eq 0 ]] && continue

      local _module_content="${_module_content}
${line}"
    done < "${f}"

    _TEMPLATES["${_module_name},${_optional}"]="${_module_content}
"
}

read_modules(){
  # shellcheck disable=SC2094
  echo "Reading global modules at \"${TPL_DIR}\" ..."
  for f in "${TPL_DIR}/"*; do
    local _module="$(basename "$f")"
    echo -n " - ${_module}"
    proccess_module "${f}"
    echo
  done


  declare -a module_array
  __echo "Resolve local modulse path..."
  while IFS= read -r -d '' file; do
    local _path=$(dirname "${file}")
    module_array+=("${_path}")
    echo " - ${_path}"
  done < <(find "${LINK_DIR}" -type f -name "${TPL_LINK_MARKER}" -print0 )

  if [[ ${#module_array[@]} -eq 0 ]]; then
    __echo "warn" "No local modules found. Please make sure, that the target folder contains empty ${TPL_LINK_MARKER} file."
    return 
  fi

  for _path in "${module_array[@]}"; do
    echo "Reading private modules at \"${_path}\" ..."
    for f in "${_path}/"*; do
      local _module="$(basename "$f")"
      echo -n " - ${_module}"
      if module_exists "${_module}"; then
        echo "  // already loaded, skipping !!"
        continue
      fi
      proccess_module "${f}"
      echo
    done
  done
}

generate_template(){
  echo "# ${__START_INCLUDE}"

  # shellcheck disable=SC2094
  for tpl in "${!_TEMPLATES[@]}"; do 
    IFS=',' read -r -a _options <<< "${tpl}"

    [[ ${_options[1]} -eq 1 ]] && continue
    echo "# [module: ${_options[0]}]"
    echo "${_TEMPLATES[${tpl}]}"
  done

  echo "# ${__END_INCLUDE}"
}


number_of_lines(){
  mapfile -t array <<< "$1"
  echo -n ${#array[@]}
}

# Exit codes:
# - 0 Update file
# - 1 Init new files
update_file(){
  local _file="${1}"
  local _template="$2"
  local _can_copy=1
  local _exit_code=0
  mapfile -t _content <<< "$(<"${_file}")"

  for line in "${_content[@]}"; do
    if [[ "${line}" == "# ${__TEMPLATE_PLACEHOLDER}" ]]; then
      echo "${_template}"
      _exit_code=1
      continue
    fi

    [[ "${line}" == "# ${__START_INCLUDE}" ]] && local _can_copy=0
    [[ "${line}" == "# ${__END_INCLUDE}" ]] && {
      local _can_copy=1
      echo "${_template}"
      continue
    }
    [[ ${_can_copy} -eq 1 ]] && echo "${line}"
  done
  return ${_exit_code}
}


update_files(){
  local _target_dir="$1"
  local _template="$2"

  for f in "${_target_dir}/"{.*,*}; do
    [[ -d "${f}" ]] && continue
    local _file_name="$(basename "${f}")"

    [[ "${_file_name}" == "${REPLACE_MARKER}" ]] && continue 

    local update_content; update_content="$(update_file "${f}" "${_template}")"
    local _ret=$?

    if [[ $_ret -eq 0 ]]; then 
      echo " - Updating file: ${_file_name}"
    elif [[ $_ret -eq 1 ]]; then
      echo " - Initial. file: ${_file_name}"
    fi
    
    echo -n "${update_content}" > "${f}"
  done
}

resolve_paths_and_replace(){
  local _template="$1"
  declare -a replace_array
  __echo "Resolve processing paths..."
  while IFS= read -r -d '' file; do
    local _path=$(dirname "${file}")
    replace_array+=("${_path}")
    echo " - ${_path}"
  done < <(find "${LINK_DIR}" -type f -name "${REPLACE_MARKER}" -print0 )

  if [[ ${#replace_array[@]} -eq 0 ]]; then
    __echo "warn" "No processing targets found. Please make sure, that the target folders have ${REPLACE_MARKER} file created in them."
    return 
  fi

  for _path in "${replace_array[@]}"; do
      __echo "Updating ${_path} ..."
      update_files "${_path}" "${_template}"
  done
}

# shellcheck disable=SC1091
. "${DIR}/modules/core.sh"

# ========== [MAIN SCRIPT] ===============

main() {
  __echo "Scaning for modules ..."
  read_modules
  __echo "Loaded ${#_TEMPLATES[@]} modules in total" 

  __echo -n "Generate template ... "
  IFS= TEMPLATE=$(generate_template)
  IFS= __lines=$(number_of_lines "${TEMPLATE}")
  echo "${__lines} lines"

  resolve_paths_and_replace "${TEMPLATE}"
}

main