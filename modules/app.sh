#!/bin/bash

# Copyright 2026 FluffyContainers
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

__resolved_source_path(){
    local src="${BASH_SOURCE[0]}" dir=""
    while [[ -h "${src}" ]]; do
        dir="$(cd -P -- "$(dirname -- "${src}")" 1>/dev/null 2>&1 && pwd)"
        src="$(readlink -- "${src}")"
        [[ ${src} != /* ]] && src="${dir}/${src}"
    done
    echo -n "$(cd -P -- "$(dirname -- "${src}")" 1>/dev/null 2>&1 && pwd)/$(basename -- "${src}")"
}

__dir(){ # usage: APP_DIR="$(__dir)" -> /abs/dir
    echo -n "$(dirname -- "$(__resolved_source_path)")"
}

__script_name(){ # usage: APP_NAME="$(__script_name)" -> script.sh
    echo -n "$(basename -- "$(__resolved_source_path)")"
}

__symlink_name(){ # usage: APP_SYMLINK_NAME="$(__symlink_name)" -> link.sh or empty
    local src="${BASH_SOURCE[0]}"
    [[ -h "${src}" ]] && echo -n "$(basename -- "${src}")" || echo -n ""
}


APP_DIR="$(__dir)"
APP_NAME="$(__script_name)"
APP_SYMLINK_NAME="$(__symlink_name)"
# [end]