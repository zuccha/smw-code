################################################################################
#                                INSTALL SCRIPT                                #
################################################################################

# Usage: ./install.sh [flags] <type> <name> [<project_name>]
#
#   Install a resource in a project. If the project doesn't exist, it will
#   create a new one.
#
#   Args:
#     <type>          Resource type, one of: "block", "patch", "port", "sprite", "uberasm"
#     <name>          Name of the resource
#     <project_name>  Name of project where to install the resource, defaults to the resource name
#
#   Flags:
#     -o              Override an existing project with a new one
#     -s              Soft override only the given resource
#     -v              Verbose, log all copy operations


#-------------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------------

# Make script exit if any command fails
set -e

# Variables used in child scripts
export ROOT=$(pwd)
export TAG="$TYPE/$NAME/$VERSION"
SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"

# Load env and utilities
source .env
source $SCRIPT_PATH/../log.sh


#-------------------------------------------------------------------------------
# Parse Flags and Arguments
#-------------------------------------------------------------------------------

# Parse flags
while getopts "osv" flag; do
  case $flag in
    o) OVERRIDE=1      ;;
    s) SOFT_OVERRIDE=1 ;;
    v) VERBOSE=1       ;;
  esac
done

# Parse arguments
TYPE="${@:$OPTIND:1}"
NAME="${@:$OPTIND+1:1}"
PROJECT_NAME="${@:$OPTIND+2:1}"
if [[ -z "$PROJECT_NAME" ]]; then PROJECT_NAME="$NAME"; fi

# Determine type directory name
case $TYPE in
  block)   TYPE_DIR=blocks  ;;
  patch)   TYPE_DIR=patches ;;
  port)    TYPE_DIR=ports   ;;
  sprite)  TYPE_DIR=sprites ;;
  tool)    TYPE_DIR=tools   ;;
  uberasm) TYPE_DIR=uberasm ;;
esac

# Args validation
if [[ -z "$TYPE" ]];         then log_fail "Type is empty";           exit 1; fi
if [[ -z "$TYPE_DIR" ]];     then log_fail "Type $TYPE is not valid"; exit 1; fi
if [[ -z "$NAME" ]];         then log_fail "Name is empty";           exit 1; fi
if [[ -z "$PROJECT_NAME" ]]; then log_fail "Project is empty";        exit 1; fi


#-------------------------------------------------------------------------------
# Defines
#-------------------------------------------------------------------------------

# Source path
SRC_PATH="./$TYPE_DIR/$NAME"

# Source blocks
SRC_BLOCKS="$SRC_PATH/GPS"
SRC_BLOCKS_LIST="$SRC_BLOCKS/list.txt"
SRC_BLOCKS_ROUTINES="$SRC_BLOCKS/routines"

# Source patches
SRC_PATCHES="$SRC_PATH/Patches"

# Source sprites
SRC_SPRITES="$SRC_PATH/PIXI"
SRC_SPRITES_LIST="$SRC_SPRITES/list.txt"
SRC_SPRITES_CLUSTER="$SRC_SPRITES/cluster"
SRC_SPRITES_EXTENDED="$SRC_SPRITES/extended"
SRC_SPRITES_GENERATORS="$SRC_SPRITES/generators"
SRC_SPRITES_SHOOTERS="$SRC_SPRITES/shooters"
SRC_SPRITES_SPRITES="$SRC_SPRITES/sprites"
SRC_SPRITES_MISC_BOUNCE="$SRC_SPRITES/misc_sprites/bounce"
SRC_SPRITES_MISC_MINOREXTENDED="$SRC_SPRITES/misc_sprites/minorextended"
SRC_SPRITES_MISC_SCORE="$SRC_SPRITES/misc_sprites/score"
SRC_SPRITES_MISC_SMOKE="$SRC_SPRITES/misc_sprites/smoke"
SRC_SPRITES_MISC_SPINNINGCOIN="$SRC_SPRITES/misc_sprites/spinningcoin"
SRC_SPRITES_ROUTINES="$SRC_SPRITES/routines"

# Source UberASM
SRC_UBERASM="$SRC_PATH/UberASMTool"
SRC_UBERASM_LIST="$SRC_UBERASM/list.txt"
SRC_UBERASM_GAMEMODE="$SRC_UBERASM/gamemode"
SRC_UBERASM_LEVEL="$SRC_UBERASM/level"
SRC_UBERASM_LIBRARY="$SRC_UBERASM/library"
SRC_UBERASM_OTHER="$SRC_UBERASM/other"
SRC_UBERASM_OVERWORLD="$SRC_UBERASM/overworld"

# Source Graphics
SRC_GFXS="$SRC_PATH/Graphics"
SRC_EXGFXS="$SRC_PATH/ExGraphics"
SRC_PALETTES="$SRC_PATH/Palettes"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Project path
PROJECT_PATH="$PROJECTS_PATH/$PROJECT_NAME"

# Project blocks
PROJECT_BLOCKS="$PROJECT_PATH/Blocks"
PROJECT_BLOCKS_LIST="$PROJECT_BLOCKS/list.txt"
PROJECT_BLOCKS_ROUTINES="$PROJECT_BLOCKS/routines"

# Project patches
PROJECT_PATCHES="$PROJECT_PATH/Patches"

# Project sprites
PROJECT_SPRITES="$PROJECT_PATH/Sprites"
PROJECT_SPRITES_LIST="$PROJECT_SPRITES/list.txt"

PROJECT_SPRITES_CLUSTER="$PROJECT_SPRITES/cluster"
PROJECT_SPRITES_EXTENDED="$PROJECT_SPRITES/extended"
PROJECT_SPRITES_GENERATORS="$PROJECT_SPRITES/generators"
PROJECT_SPRITES_SHOOTERS="$PROJECT_SPRITES/shooters"
PROJECT_SPRITES_SPRITES="$PROJECT_SPRITES/sprites"

PROJECT_SPRITES_MISC_BOUNCE="$PROJECT_SPRITES/misc_sprites/bounce"
PROJECT_SPRITES_MISC_MINOREXTENDED="$PROJECT_SPRITES/misc_sprites/minorextended"
PROJECT_SPRITES_MISC_SCORE="$PROJECT_SPRITES/misc_sprites/score"
PROJECT_SPRITES_MISC_SMOKE="$PROJECT_SPRITES/misc_sprites/smoke"
PROJECT_SPRITES_MISC_SPINNINGCOIN="$PROJECT_SPRITES/misc_sprites/spinningcoin"

PROJECT_SPRITES_ROUTINES="$PROJECT_SPRITES/routines"
PROJECT_SPRITES_ROUTINES_BOUNCE="$PROJECT_SPRITES_ROUTINES/Bounce"
PROJECT_SPRITES_ROUTINES_EXTENDED="$PROJECT_SPRITES_ROUTINES/Extended"
PROJECT_SPRITES_ROUTINES_MINOREXTENDED="$PROJECT_SPRITES_ROUTINES/MinorExtended"
PROJECT_SPRITES_ROUTINES_SCORE="$PROJECT_SPRITES_ROUTINES/Score"
PROJECT_SPRITES_ROUTINES_SMOKE="$PROJECT_SPRITES_ROUTINES/Smoke"
PROJECT_SPRITES_ROUTINES_SPAWN="$PROJECT_SPRITES_ROUTINES/Spawn"
PROJECT_SPRITES_ROUTINES_SPINNINGCOIN="$PROJECT_SPRITES_ROUTINES/SpinningCoin"

# Project UberASM
PROJECT_UBERASM="$PROJECT_PATH/UberASM"
PROJECT_UBERASM_LIST="$PROJECT_UBERASM/list.txt"
PROJECT_UBERASM_GAMEMODE="$PROJECT_UBERASM/gamemode"
PROJECT_UBERASM_LEVEL="$PROJECT_UBERASM/level"
PROJECT_UBERASM_LIBRARY="$PROJECT_UBERASM/library"
PROJECT_UBERASM_OTHER="$PROJECT_UBERASM/other"
PROJECT_UBERASM_OVERWORLD="$PROJECT_UBERASM/overworld"

# Project Graphics
PROJECT_GFXS="$PROJECT_PATH/Graphics"
PROJECT_EXGFXS="$PROJECT_PATH/ExGraphics"
PROJECT_PALETTES="$PROJECT_PATH/Palettes"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Custom scripts
CLI_INSTALL="$SRC_PATH/.smw/install.sh"

# Templates
RESOURCES="$PROJECTS_PATH/.resources"
TEMPLATES="$PROJECTS_PATH/.templates"
TEMPLATE_VANILLA="$TEMPLATES/vanilla"
TOOL_VERSIONS="$TEMPLATE_VANILLA/config_versions.bat"

# Tool versions
while IFS= read -r line; do
  if [[ $line == set* ]]; then
    var_name=$(echo "$line" | cut -d' ' -f2 | cut -d'=' -f1 | tr -d '"')
    var_value=$(echo "$line" | cut -d'=' -f2- | tr -d '"' | tr -d '"' | tr -d '\r')
    export "$var_name=$var_value"
  fi
done < "$TOOL_VERSIONS"


#-------------------------------------------------------------------------------
# Utilities
#-------------------------------------------------------------------------------

format_category() {
  if [[ $1 == *_* ]];
  then category="${1#*_}"
  else category=""
  fi

  echo "$category" | tr '[:upper:]' '[:lower:]'
}

copy_file_if() {
  local condition="$1"
  local src_file="SRC_$2"
  local project_file="PROJECT_$2"

  if [[ "$condition" == 1 && -f "${!src_file}" ]]; then
    cp "${!src_file}" "${!project_file}"
    if [[ -n "$VERBOSE" ]]; then
      log_info "\t...$(format_category $2)";
    fi
  fi
}

copy_files() {
  local src_dir="SRC_$1"
  local project_dir="PROJECT_$1"
  local extension="${2:-asm}"

  if [[ -d "${!src_dir}" ]]; then
      cp "${!src_dir}/"*".$extension" "${!project_dir}"
  fi

  if [[ -n "$VERBOSE" ]]; then
    count=$(find "${!src_dir}" -maxdepth 1 -type f -name "*.$extension" 2> /dev/null | awk 'END{print NR}')
    if [[ "$count" -gt 0 ]]; then log_info "\t...$(format_category $1)/*.$extension ($count)"; fi
  fi
}

create_project_from_template() {
  cp -r "$TEMPLATE_VANILLA" "$1"
  cp -r "$RESOURCES/PIXI_$pixi_version/"* "$1/Sprites"
  rm -rf "$1/Sprites/asm"
  cp -r "$RESOURCES/UberASMTool_$uberasmtool_version/"* "$1/UberASM"
  cp -r "$RESOURCES/GPS_$gps_version/routines/"* "$1/Blocks/routines"
  cp -r "$RESOURCES/AddmusicK_$amk_version/"* "$1/Music"
}


#-------------------------------------------------------------------------------
# Project Validation
#-------------------------------------------------------------------------------

# Validate projects folder
if [[ -z "$PROJECTS_PATH" ]]; then log_fail "Projects folder is not defined"; exit 1; fi
if [[ ! -d "$PROJECTS_PATH" ]]; then log_fail "Projects folder $PROJECTS_PATH doesn't exist"; exit 1; fi

# Check if resource exists
if [[ ! -d "$SRC_PATH" ]]; then log_fail "Resource $SRC_PATH doesn't exist"; exit 1; fi


#-------------------------------------------------------------------------------
# Create Project
#-------------------------------------------------------------------------------

if [[ -d "$PROJECT_PATH" ]]; then
  if [[ $OVERRIDE == 1 ]]; then
    log_info "Create project (override)"
    rm -rf "$PROJECT_PATH"
    create_project_from_template "$PROJECT_PATH"
    IS_NEW=1
  elif [[ $SOFT_OVERRIDE == 1 ]]; then
    log_warn "Skip create project: project already exists"
  else
    log_fail "Project $PROJECT_NAME already exist"
    exit 1
  fi
else
  log_info "Create project"
  create_project_from_template "$PROJECT_PATH"
  IS_NEW=1
fi


#-------------------------------------------------------------------------------
# Copy Blocks
#-------------------------------------------------------------------------------

if [[ -d "$SRC_BLOCKS" ]]; then
  log_info "Copy blocks"

  copy_file_if "$IS_NEW" BLOCKS_LIST

  copy_files BLOCKS
  copy_files BLOCKS_ROUTINES
fi


#-------------------------------------------------------------------------------
# Copy Patches
#-------------------------------------------------------------------------------

if [[ -d "$SRC_PATCHES" ]]; then
  log_info "Copy patches"

  copy_files PATCHES
fi


#-------------------------------------------------------------------------------
# Copy Ports
#-------------------------------------------------------------------------------

# TODO


#-------------------------------------------------------------------------------
# Copy Sprites
#-------------------------------------------------------------------------------

if [[ -d "$SRC_SPRITES" ]]; then
  log_info "Copy sprites"

  copy_file_if "$IS_NEW" SPRITES_LIST

  copy_files SPRITES_SPRITES
  copy_files SPRITES_SPRITES json

  copy_files SPRITES_SHOOTERS
  copy_files SPRITES_SHOOTERS json

  copy_files SPRITES_GENERATORS
  copy_files SPRITES_GENERATORS json

  copy_files SPRITES_CLUSTER
  copy_files SPRITES_EXTENDED

  copy_files SPRITES_MISC_BOUNCE
  copy_files SPRITES_MISC_MINOREXTENDED
  copy_files SPRITES_MISC_SCORE
  copy_files SPRITES_MISC_SMOKE
  copy_files SPRITES_MISC_SPINNINGCOIN

  copy_files SPRITES_ROUTINES
  copy_files SPRITES_ROUTINES_BOUNCE
  copy_files SPRITES_ROUTINES_EXTENDED
  copy_files SPRITES_ROUTINES_MINOREXTENDED
  copy_files SPRITES_ROUTINES_SCORE
  copy_files SPRITES_ROUTINES_SMOKE
  copy_files SPRITES_ROUTINES_SPAWN
  copy_files SPRITES_ROUTINES_SPINNINGCOIN
fi


#-------------------------------------------------------------------------------
# Copy UberASM
#-------------------------------------------------------------------------------

if [[ -d "$SRC_UBERASM" ]]; then
  log_info "Copy UberASM"

  copy_file_if "$IS_NEW" UBERASM_LIST

  copy_files UBERASM_GAMEMODE
  copy_files UBERASM_LEVEL
  copy_files UBERASM_LIBRARY
  copy_files UBERASM_OTHER
  copy_files UBERASM_OVERWORLD
fi


#-------------------------------------------------------------------------------
# Copy Graphics
#-------------------------------------------------------------------------------

if [[ -d "$SRC_GFXS" ]]; then
  log_info "Copy Graphics"

  copy_files GFXS bin
fi

if [[ -d "$SRC_EXGFXS" ]]; then
  log_info "Copy ExGraphics"

  copy_files EXGFXS bin
fi

if [[ -d "$SRC_PALETTES" ]]; then
  log_info "Copy palettes"

  copy_files PALETTES pal
  copy_files PALETTES palmask
fi


#-------------------------------------------------------------------------------
# Custom Scripts
#-------------------------------------------------------------------------------

if [[ -f "$CLI_INSTALL" ]]; then
  log_info "Run custom install"

  source "$CLI_INSTALL"
fi
