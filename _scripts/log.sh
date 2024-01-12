# Colors for logging
LOG_COLOR_GOOD='\033[0;32m'
LOG_COLOR_INFO='\033[0;34m'
LOG_COLOR_WARN='\033[0;33m'
LOG_COLOR_FAIL='\033[0;31m'
LOG_COLOR_NONE='\033[0m'

# Logging functions
log_good() { printf "${LOG_COLOR_GOOD}$1${LOG_COLOR_NONE}\n"; }
log_info() { printf "${LOG_COLOR_INFO}$1${LOG_COLOR_NONE}\n"; }
log_warn() { printf "${LOG_COLOR_WARN}$1${LOG_COLOR_NONE}\n"; }
log_fail() { printf "${LOG_COLOR_FAIL}$1${LOG_COLOR_NONE}\n"; }
