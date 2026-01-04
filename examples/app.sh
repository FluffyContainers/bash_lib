#!/bin/bash



# [template] !!! DO NOT MODIFY CODE INSIDE, ON NEXT UPDATE CODE WOULD BE REPLACED !!!
# include: app

# [module: app]


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

# APP_DIR
# Absolute path to the directory containing the script
# Resolves symlinks to get the actual script location
APP_DIR="$(__dir)"

# APP_NAME
# Name of the actual script file (after resolving symlinks)
APP_NAME="$(__script_name)"

# APP_SYMLINK_NAME
# Name of the symlink if script was called via symlink, empty string otherwise
APP_SYMLINK_NAME="$(__symlink_name)"

# [template:end] !!! DO NOT REMOVE ANYTHING INSIDE, INCLUDING CURRENT LINE !!!



echo "APP_DIR is set to: ${APP_DIR}"
echo "APP_NAME is set to: ${APP_NAME}"

if [[ -n "${APP_SYMLINK_NAME}" ]]; then
    echo "Script was executed via symlink: ${APP_SYMLINK_NAME}"
else
    echo "Script was executed directly (no symlink)"
fi