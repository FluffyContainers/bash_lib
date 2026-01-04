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
# - create file ".replace" in folder, content of which would be processed
# - add content below to the file:
#   # [template]
#   # include: core
# - execute update_includes.sh file
# ...
# - after first execution, files would be automaticaly updated with any update execution

# Local modules could be defined in a same way as preocessing dir:
# - put file marker to the folder with name ".module"
# - basically it's all, now these files could be used in includes by their names without extension 


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


declare -A __CONST=(
  [START_INCLUDE]="[template] !!! DO NOT MODIFY CODE INSIDE, ON NEXT UPDATE CODE WOULD BE REPLACED !!!"
  [INCLUDE]="include:"
  [END_INCLUDE]="[template:end] !!! DO NOT REMOVE ANYTHING INSIDE, INCLUDING CURRENT LINE !!!"

  [START_BLOCK]="[start]"
  [END_BLOCK]="[end]"

  [TEMPLATE_PLACEHOLDER]="[template]"
)

# key format -> [module_name] = module_content
declare -A _TEMPLATES=()
# key format -> [module_name] = comma-separated list of dependencies
declare -A _MODULE_DEPS=()


module_exists(){
  local _query="$1"
  for a in "${!_TEMPLATES[@]}"; do
    IFS="," read -r -a arr <<< "${a}"
    [[ "${arr[0]}" == "${_query}" ]] && return 0 || true
  done
  return 1
}

# Read modules to the BASH KeyValue Map by it base name
proccess_module(){
    local f="${1}"
    local _can_copy=0
    local _opts_len=${#__MODULE_OPTIONS}
    
    local _module_name=$(basename "${f}")
    local _module_name=${_module_name%.*}
    local _module_content=""
    local _module_deps=""
    # options
    local _optional=0

    while IFS= read -rs line; do
      # Check for include directive to track dependencies
      if [[ "${line}" =~ ^#\ ${__CONST[INCLUDE]}\ (.*)$ ]]; then
        _module_deps="${BASH_REMATCH[1]}"
      fi

      [[ "${line}" == "# ${__CONST[START_BLOCK]}" ]] && {
        local _can_copy=1
        local _scan_options=1
        continue
      }


      [[ "${line}" == "# ${__CONST[END_BLOCK]}" ]] && local _can_copy=0
      [[ ${_can_copy} -eq 0 ]] && continue

      local _module_content="${_module_content}
${line}"
    done < "${f}"

    _TEMPLATES["${_module_name}"]="${_module_content}
"
    [[ -n "${_module_deps}" ]] && _MODULE_DEPS["${_module_name}"]="${_module_deps}"
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
  __echo "Resolve local modules path..."
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


# helper function
# $1: comma-separated list of modules
# $2: name of associative array to fill (as a nameref)
build_include_set() {
  local _include_modules="$1"
  local -n _set_ref="$2"
  IFS=',' read -ra _mods <<< "$_include_modules"
  for mod in "${_mods[@]}"; do
    mod="$(echo "$mod" | xargs)" # trim whitespace
    [[ -n "$mod" ]] && _set_ref["$mod"]=1
  done
}

# Recursively resolve dependencies
# $1: module name
# $2: name of associative array for visited modules (nameref)
# $3: name of array for ordered result (nameref)
resolve_deps_recursive() {
  local _mod="$1"
  local -n _visited_ref="$2"
  local -n _result_ref="$3"

  # Already visited - avoid circular deps
  [[ -n "${_visited_ref[$_mod]}" ]] && return
  _visited_ref["$_mod"]=1

  # If module has dependencies, resolve them first
  if [[ -n "${_MODULE_DEPS[$_mod]}" ]]; then
    IFS=',' read -ra _deps <<< "${_MODULE_DEPS[$_mod]}"
    for dep in "${_deps[@]}"; do
      dep="$(echo "$dep" | xargs)"
      [[ -n "$dep" ]] && resolve_deps_recursive "$dep" "$2" "$3"
    done
  fi

  # Add this module after its dependencies
  _result_ref+=("$_mod")
}

# $1: coma-separated list string list of modules to generate content of
generate_template(){
  # parse include modules list "mod1,mod2 to an Map"
  local _include_modules="$1"
  IFS=',' read -ra _mods <<< "$_include_modules"

  # Track explicitly requested modules
  declare -A _explicit=()
  for mod in "${_mods[@]}"; do
    mod="$(echo "$mod" | xargs)"
    [[ -n "$mod" ]] && _explicit["$mod"]=1
  done

  # Build ordered list with dependencies
  declare -A _visited=()
  declare -a _ordered_mods=()
  
  for mod in "${_mods[@]}"; do
    mod="$(echo "$mod" | xargs)"
    [[ -n "$mod" ]] && resolve_deps_recursive "$mod" _visited _ordered_mods
  done

  echo "# ${__CONST[START_INCLUDE]}"
  echo "# ${__CONST[INCLUDE]} ${_include_modules}"
  echo ""

  # shellcheck disable=SC2094
  for mod in "${_ordered_mods[@]}"; do
    if [[ -n "${_TEMPLATES[${mod}]}" ]]; then
      if [[ -n "${_explicit[$mod]}" ]]; then
        echo "# [module: ${mod}]"
      else
        echo "# [module: ${mod}] (dependency)"
      fi
      echo "${_TEMPLATES[${mod}]}"
    else 
      echo "# [module: ${mod}] NOT FOUND or not loaded. Check that the include are in a search path"
    fi
  done

  echo "# ${__CONST[END_INCLUDE]}"
}

generate_template_empty(){
    echo "# ${__CONST[START_INCLUDE]}"
    echo "# !! No include modules found, please use '# ${__CONST[INCLUDE]} mod1,mod2,etc' directive on the next line after ${__CONST[TEMPLATE_PLACEHOLDER]}"
    echo "# !! List of discovered modules to include:"
    for mod in "${!_TEMPLATES[@]}"; do
      echo "# !! - ${mod}"
    done
    echo "# ${__CONST[END_INCLUDE]}"
}

# Exit codes:
# - 0 Update file
# - 1 Init new files
# - 2 Not modified
update_file(){
  local _file="${1}"
  local _can_copy=1
  local _exit_code=2
  local _template=""
  local _include_modules=""

  mapfile -t _content <<< "$(<"${_file}")"

  for ((i=0; i<${#_content[@]}; i++)); do
    line="${_content[$i]}"


    if [[ "${line}" == "# ${__CONST[TEMPLATE_PLACEHOLDER]}" ]]; then
      next_line="${_content[$((i+1))]}"
      if [[ "${next_line}" =~ ^#\ ${__CONST[INCLUDE]}\ (.*)$ ]]; then
        i=$((i + 1))
        _include_modules="${BASH_REMATCH[1]}"
        _template=$(generate_template "${_include_modules}")
      else 
        _template=$(generate_template_empty)
      fi
      echo "${_template}"
       
      _exit_code=1
      continue
    fi

    if [[ "${line}" == "# ${__CONST[START_INCLUDE]}" ]]; then 
      local _can_copy=0
      next_line="${_content[$((i+1))]}"
      if [[ "${next_line}" =~ ^#\ ${__CONST[INCLUDE]}\ (.*)$ ]]; then
        i=$((i + 1))
        _include_modules="${BASH_REMATCH[1]}"
      fi
      continue
    fi

    if [[ "${line}" == "# ${__CONST[END_INCLUDE]}" ]]; then
      local _can_copy=1
      if [[ -n ${_include_modules} ]]; then
        _template=$(generate_template "${_include_modules}")
      fi

      echo "${_template}"
      _exit_code=1
      continue
    fi

    [[ ${_can_copy} -eq 1 ]] && echo "${line}"
  done
  return ${_exit_code}
}


update_files(){
  local _target_dir="$1"

  for f in "${_target_dir}/"{.*,*}; do
    [[ -d "${f}" ]] && continue
    local _file_name="$(basename "${f}")"

    [[ "${_file_name}" == "${REPLACE_MARKER}" ]] && continue 

    local update_content; update_content="$(update_file "${f}")"
    local _ret=$?

    case "${_ret}" in 
      0) echo " - ${_file_name} updated.";;
      1) echo " - ${_file_name} initialized.";;
      # 2) echo " - ${_file_name} not modified";;
    esac    
    echo -n "${update_content}" > "${f}"
  done
}

resolve_paths_and_replace(){
  declare -a replace_array
  __echo "Resolving replace paths..."
  while IFS= read -r -d '' file; do
    local _path=$(dirname "${file}")
    replace_array+=("${_path}")
    echo " - ${_path}"
  done < <(find "${LINK_DIR}" -type f -name "${REPLACE_MARKER}" -print0 )

  if [[ ${#replace_array[@]} -eq 0 ]]; then
    __echo "warn" "No replace targets found. Please make sure, that the target folders have ${REPLACE_MARKER} file created in directories included to processing."
    return 
  fi

  for _path in "${replace_array[@]}"; do
      __echo "Updating ${_path} ..."
      update_files "${_path}"
  done
}

# shellcheck disable=SC1091
. "${DIR}/modules/core.sh"

# ========== [MAIN SCRIPT] ===============

main() {
  __echo "Scaning for modules ..."
  read_modules
  __echo "Loaded ${#_TEMPLATES[@]} modules in total" 

  resolve_paths_and_replace
}

main