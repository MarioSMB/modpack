#!/usr/bin/env bash

TARGET_ALL=0
CLEAN_BUILD=0
MAKE_TARGETS=("qc")
FILTER_FLAGS="--filter=blob:none"

if [[ "$CI" == "true" ]]; then
  INIT_SUBMODULES=0
else
  INIT_SUBMODULES=1
fi

usage() {
  echo "build.sh [-c|--clean] [-a|-all] [-nf|--no-filter] [-ni|--no-init] [-h|--help]"
  echo
  echo " -c  | --clean          Remove compiled .dat and .pk3 file before rebuilding."
  echo " -a  | --all            Build both qc and pk3 targets."
  echo " -h  | --help           Show this message."
  echo " -nf | --no-filter      Don't use --filter flag when initializing submodules."
  echo " -ni | --no-init        Skip initializing submodules, manual initialization."
  echo
  echo "NOTE: Default target is 'qc' only."
}

# Filter repeating arguments.
# Who would pass same arguments multiple times tho?!
if [[ $# -gt 0 ]]; then
  readarray -t arguments < <(printf '%s\n' "$@" | sort -u)
else
  # No arguments were provided
  arguments=()
fi

# Parse CLI arguments
for i in "${arguments[@]}"; do
  case $i in
  -a | --all)
    TARGET_ALL=1
    MAKE_TARGETS+=("pk3")
    ;;
  -c | --clean)
    CLEAN_BUILD=1
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  -ni | --no-init)
    INIT_SUBMODULES=0
    ;;
  -nf | --no-filter)
    FILTER_FLAGS=""
    ;;
  *)
    echo "Unknown flag: '$i' ... aborting"
    exit 1
    ;;
  esac
done

if ! CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"; then
  echo "=> Failed to parse git branch name... aborting"
  exit 1
else
  echo "=> Current Branch is ${CURRENT_BRANCH}"
fi

submodule_gmqcc_status=$(git submodule status gmqcc | awk '{ print $1 }')
if ((INIT_SUBMODULES == 1)); then
  if [[ "${submodule_gmqcc_status:0:1}" == "+" || "${submodule_gmqcc_status:0:1}" == "-" ]]; then
    echo "=> Submodule gmqcc not initialized... (commit: ${submodule_gmqcc_status})"
    if ! git submodule update --init $FILTER_FLAGS gmqcc; then
      echo " -> Failed to initialize gmqcc submodule... aborting"
      exit 1
    fi
  else
    echo "=> Submodule gmqcc already initialized. (commit: ${submodule_gmqcc_status})"
  fi
else
  echo "=> Skipping gmqcc initialization... (commit: ${submodule_gmqcc_status})"
fi

if [[ ! -f "gmqcc/gmqcc" ]]; then
  echo "=> Building gmqcc..."
  if ! make -C gmqcc -j"$(nproc)"; then
    echo " -> Failed to build gmqcc... aborting"
    exit 1
  fi
else
  echo "=> Using existing gmqcc binary (VERSION: $(gmqcc/gmqcc --version))"
fi

if [[ ! -d "build/${CURRENT_BRANCH}" ]]; then
  echo "=> Creating build directory... (build/${CURRENT_BRANCH})"
  if ! mkdir -p "build/${CURRENT_BRANCH}"; then
    echo " -> Could not create build directory... aborting"
    exit 1
  fi
fi

submodule_xonotic_status=$(git submodule status xonotic | awk '{ print $1 }')
if ((INIT_SUBMODULES == 1)); then
  if [[ "${submodule_xonotic_status:0:1}" == "+" || "${submodule_xonotic_status:0:1}" == "-" ]]; then
    echo "=> Submodule xonotic not initialized... (commit: ${submodule_xonotic_status})"
    if ! git submodule update --init $FILTER_FLAGS xonotic; then
      echo " -> Failed to initialize xonotic submodule... aborting"
      exit 1
    fi
  else
    echo "=> Submodule xonotic already initialized. (commit: ${submodule_xonotic_status})"
  fi
else
  echo "=> Skipping xonotic submodule initialization... (commit: ${submodule_xonotic_status})"
fi

export XONOTIC=${XONOTIC:-1}
export QCC=${QCC:-"$(pwd)/gmqcc/gmqcc"}

if ! WATERMARK="$(git describe --tags --dirty='~' --always)"; then
  echo "-> Error: Failed to generate QCCFLAGS_WATERMARK... aborting"
  exit 1
else
  echo "=> Version tag is: ${WATERMARK}"
fi
export QCCFLAGS_WATERMARK="${WATERMARK}"
export PROGS_OUT=${PROGS_OUT:-"$(pwd)/build/${CURRENT_BRANCH}"}

if ! TMP_MOD="$(realpath --relative-to=xonotic/qcsrc "$(pwd)")"; then
  echo "-> Error: could not calculate BUILD_MOD... aborting"
  exit 1
fi

if [[ -z "$TMP_MOD" ]]; then
  echo "TMP_MOD is empty! ... aborting"
  exit 1
fi

export BUILD_MOD="${TMP_MOD}"

if ((CLEAN_BUILD == 1)); then
  echo "=> Cleaning old build artifacts in build/${CURRENT_BRANCH}"
  make -C xonotic clean
  rm -f "${PROGS_OUT}/"csprogs-*.pk3
fi

echo "=> Starting Compilation..."
if ! make -C xonotic "${MAKE_TARGETS[@]}"; then
  echo " -> Modpack compilation failed... aborting"
  exit 1
else
  if ((TARGET_ALL == 1)); then
    cp xonotic/qcsrc/csprogs-*.pk3 "${PROGS_OUT}"
  fi
  exit 0
fi
