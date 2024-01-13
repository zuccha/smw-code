################################################################################
#                                    CREATE                                    #
################################################################################

# Usage: ./create.sh <project_name>
#
#   Create a new project.
#
#   Args:
#     <project_name>  Name of project to create


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
# Arguments
#-------------------------------------------------------------------------------

# Parse arguments
PROJECT_NAME="$1"

# Args validation
if [[ -z "$PROJECT_NAME" ]]; then log_fail "Project is empty"; exit 1; fi


#-------------------------------------------------------------------------------
# Defines
#-------------------------------------------------------------------------------

# Project path
PROJECT_PATH="$PROJECTS_PATH/$PROJECT_NAME"

# Templates
TEMPLATES="$PROJECTS_PATH/.templates"
TEMPLATE_CHOCOLATE="$TEMPLATES/chocolate"
TEMPLATE_VANILLA="$TEMPLATES/vanilla"


#-------------------------------------------------------------------------------
# Create Project
#-------------------------------------------------------------------------------

if [[ -d "$PROJECT_PATH" ]]; then
  log_fail "Project $PROJECT_NAME already exist"
  exit 1
else
  log_info "Create project"
  cp -r "$TEMPLATE_VANILLA" "$PROJECT_PATH"
fi
