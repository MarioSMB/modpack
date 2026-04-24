#!/usr/bin/env bash

TARGET_ALL=0
CLEAN_BUILD=0
MAKE_TARGETS=("qc")

if [[ "$CI" == "true" ]]; then
  INIT_SUBMODULES=0
else
  INIT_SUBMODULES=1
fi

usage() {
  echo "build.sh [-c|--clean] [-a|-all]"
  echo
  echo " -c | --clean    Remove the build artifacts and rebuild."
  echo " -a | --all      Build both qc and pk3 targets."
  echo " -h | --help     Show this message."
  echo " --no-init       Don't bother initializing submodules. (For CI Only)"
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
  --no-init)
    INIT_SUBMODULES=0
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

if [[ ! -f "gmqcc/.git" ]]; then
  if ((INIT_SUBMODULES == 1)); then
    echo "=> Submodule gmqcc not initialized..."
    echo "=> Creating partial clone... (with --filter=blob:none)"
    if ! git submodule update --init --filter=blob:none gmqcc; then
      echo " -> Failed to initialize gmqcc submodule... aborting"
      exit 1
    fi
  else
    echo "=> Skipping gmqcc initialization... (running in CI)"
  fi
else
  echo "=> Submodule gmqcc already initialized."
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

if [[ ! -f "xonotic/.git" ]]; then
  if ((INIT_SUBMODULES == 1)); then
    echo "=> Submodule xonotic not initialized..."
    echo "=> Creating partial clone... (with --filter=blob:none)"
    if ! git submodule update --init --filter=blob:none xonotic; then
      echo " -> Failed to initialize xonotic submodule... aborting"
      exit 1
    fi
  else
    echo "=> Skipping xonotic submodule initialization... (running in CI)"
  fi
else
  echo "=> Submodule xonotic already initialized."
fi

export XONOTIC=0
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
