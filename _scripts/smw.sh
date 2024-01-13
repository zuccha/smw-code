SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"

if [ -z "$1" ]; then
    echo "Usage: $0 <command> [args...]"
    exit 1
fi

COMMAND="$1"
shift # Remove the COMMAND from the argument list

case "$COMMAND" in
    "create")  $SCRIPT_PATH/create/create.sh "$@"   ;;
    "install") $SCRIPT_PATH/install/install.sh "$@" ;;
    "release") $SCRIPT_PATH/release/release.sh "$@" ;;
    *) echo "Unknown command: $COMMAND"; exit 1 ;;
esac
