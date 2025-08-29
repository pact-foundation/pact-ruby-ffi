#!/bin/bash -eu
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)" # Figure out where the script is running
. "${LIB_DIR}/robust-bash.sh"
. "${LIB_DIR}/download-file.sh"

require_binary curl
require_binary unzip
require_env_var STANDALONE_VERSION

BASEURL=https://github.com/pact-foundation/pact-standalone/releases/download
STANDALONE_DIR="${LIB_DIR}/../../pact/standalone"

function download_standalone {
  if [ -z "${1:-}" ]; then
    error "${FUNCNAME[0]} requires the filename to download from"
    exit 1
  fi

  if [ -z "${2:-}" ]; then
    error "${FUNCNAME[0]} requires the filename to save the download in"
    exit 1
  fi
  STANDALONE_FILENAME="$2"

  URL="${BASEURL}/v${STANDALONE_VERSION}/${1}"
  DOWNLOAD_LOCATION="$STANDALONE_DIR/${STANDALONE_FILENAME}"


  log "Downloading standalone version $STANDALONE_VERSION to $DOWNLOAD_LOCATION"
  download_to "$URL" "$DOWNLOAD_LOCATION"
  if [ "${STANDALONE_FILENAME%zip}" != "${STANDALONE_FILENAME}" ]; then
    unzip -qo "$DOWNLOAD_LOCATION" -d "${STANDALONE_DIR}"
    rm "${DOWNLOAD_LOCATION}"
  else
    mkdir -p "${STANDALONE_DIR}"
    tar -xf "$DOWNLOAD_LOCATION" -C "${STANDALONE_DIR}"
    rm "${DOWNLOAD_LOCATION}"
  fi
}

log "Downloading Ruby standalone ${STANDALONE_VERSION}"

if [[ $(find "${STANDALONE_DIR}" -name "*${STANDALONE_VERSION}") ]]; then
  log "Skipping download of Ruby standalone, as it exists"
  exit 0
fi

mkdir -p "${STANDALONE_DIR}"

detected_os=$(uname -sm)
echo detected_os = $detected_os
case ${detected_os} in
'Linux aarch64')
    echo 'using linux-x86_64'
    download_standalone "pact-${STANDALONE_VERSION}-linux-arm64.tar.gz"  "linux-arm64-${STANDALONE_VERSION}.tar.gz"
    ;;
'Linux x86_64' | "Linux"*)
    echo 'using linux-x86_64'
  download_standalone "pact-${STANDALONE_VERSION}-linux-x86_64.tar.gz"  "linux-x64-${STANDALONE_VERSION}.tar.gz"
    ;;
'Darwin arm64')
    echo 'using osx'
  download_standalone "pact-${STANDALONE_VERSION}-osx-arm64.tar.gz"           "darwin-arm64-${STANDALONE_VERSION}.tar.gz"
    ;;
'Darwin x86' | 'Darwin x86_64' | "Darwin"*)
    echo 'using osx'
  download_standalone "pact-${STANDALONE_VERSION}-osx-x86_64.tar.gz"           "darwin-x64-${STANDALONE_VERSION}.tar.gz"
    ;;
"Windows"* | "MINGW64"*)
    echo 'using win32'
    download_standalone "pact-${STANDALONE_VERSION}-windows-x86_64.zip"            "windows-x64-${STANDALONE_VERSION}.zip"
    ;;
  *)
  echo "Sorry, you'll need to install the pact-standalone manually."
  echo "or add your os to the list"
  exit 1
    ;;
esac

# Write readme in the ffi folder
cat << EOF > "$STANDALONE_DIR/README.md"
# Standalone binaries

This folder is automatically populated during build by /script/download-standalone.sh
EOF
