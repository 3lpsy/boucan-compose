#!/bin/bash
get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"
     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     $( cd -P "$( dirname "$SOURCE" )" )
     pwd
}
# first see if they passed in an argument as directory
_BOUCAN_DIR="";

_DEFAULT_COMPOSE_DIR="$(get_script_dir)"
_COMPOSE_DIR=${COMPOSE_DIR:-$_DEFAULT_COMPOSE_DIR}

if [ -f "${_COMPOSE_DIR}/setup.env" ]; then
    echo "Sourcing: ${_COMPOSE_DIR}/setup.env";
    source ${_COMPOSE_DIR}/setup.env;
fi

if [ ${#1} -gt 0 ]; then
    _BOUCAN_DIR="$1";
elif [ ${#BOUCAN_DIR} -lt 0 ]; then 
    _BOUCAN_DIR="$BOUCAN_DIR";
else
    _BOUCAN_DIR="$(dirname ${_COMPOSE_DIR})"
fi

echo "Boucan Directory: $_BOUCAN_DIR";

if [ ! -d "$_BOUCAN_DIR" ]; then 
    echo "Making $_BOUCAN_DIR";
    mkdir -p $_BOUCAN_DIR;
fi

function setup_repo () {
    repo="$1";
    echo "Setting Up Repo: $repo";
    _repo_owner=${REPO_OWNER:-$_default_repo_owner}
    _repo_prefix="${REPO_PREFIX}";
    _repo_branch="${REPO_BRANCH:-master}";
    _repo_base_url="${REPO_BASE_URL:-git@github.com:${_repo_owner}}";

    repo_source="${_repo_base_url}/${_repo_prefix}${repo}";
    repo_dest="${_BOUCAN_DIR}/$repo";

    echo "Repo Source: $repo_source"
    echo "Repo Destination: $repo_dest";
    echo "Repo Branch: ${_repo_branch}";
    if [ ! -d "${repo_dest}/.git" ]; then 
        echo "Cloning Repo...";
        git clone -b "$_repo_branch" "$repo_source" "$repo_dest";
    else
        echo "Destination already exists. Skipping..";
    fi
}

echo "";
echo "Setting Up Repos...";
echo "";
for repo in boucanpy boucan-burpex boucan-deploy boucan-web; do
    setup_repo ${repo}
    echo "";
done

echo "Repo cloning complete..."
echo ""

echo "Creating source target at: ${_COMPOSE_DIR}/compose.env";
echo "export BOUCAN_DIR=\"${_BOUCAN_DIR}\"" > "${_COMPOSE_DIR}/compose.env";
echo "export COMPOSE_DIR=\"${_COMPOSE_DIR}\"" >> "${_COMPOSE_DIR}/compose.env";

echo "You can now run docker composer with: compose.sh [env] [compose options]";
