################################################################################
#                                RELEASE SCRIPT                                #
################################################################################

# Usage: ./.utils/release [-htmi] <type> <name> <version>
#   -h          Generate HTML documentation
#   -t          Generate text documentation
#   -m          Include markdown documentation
#   -i          Include images and preserve image tags in HTML and markdown
#   <type>      Resource type, one of: "block", "patch", "port", "sprite", "tool", "uberasm"
#   <name>      Name of the resource
#   <version>   Version, following semver convention


#-------------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------------

# Make script exit if any command fails
set -e


#-------------------------------------------------------------------------------
# Parse Flags and Arguments
#-------------------------------------------------------------------------------

# Parse flags
while getopts "hmti" flag; do
  case $flag in
    h) DOCS_HTML=1     ;;
    m) DOCS_MARKDOWN=1 ;;
    t) DOCS_TEXT=1     ;;
    i) KEEP_IMAGES=1   ;;
  esac
done

# Parse arguments
TYPE=${@:$OPTIND:1}
NAME=${@:$OPTIND+1:1}
VERSION=${@:$OPTIND+2:1}

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
if [[ -z "$TYPE" ]];     then echo Type $TYPE is empty;     exit 1; fi
if [[ -z "$TYPE_DIR" ]]; then echo Type $TYPE is not valid; exit 1; fi
if [[ -z "$NAME" ]];     then echo Type $NAME is empty;     exit 1; fi
if [[ -z "$VERSION" ]];  then echo Type $VERSION is empty;  exit 1; fi


#-------------------------------------------------------------------------------
# Defines
#-------------------------------------------------------------------------------

# Tools
MD2HTML="./.utils/md2/md2html.ts"
MD2TEXT="./.utils/md2/md2text.ts"

# Git
GIT_TAG="$TYPE/$NAME/$VERSION"
GIT_BRANCH="feat/$GIT_TAG"

# Source directory and files
SRC_PATH="./$TYPE_DIR/$NAME"
README_NAME="README.md"
README_PATH="$SRC_PATH/$README_NAME"
CHANGELOG_NAME="CHANGELOG.md"
CHANGELOG_PATH="$SRC_PATH/$CHANGELOG_NAME"

# Output directory and files
OUT_DIR="./_dist/$TYPE_DIR"
OUT_NAME="$NAME-$VERSION"
OUT_PATH="$OUT_DIR/$OUT_NAME"
ZIP_NAME="$OUT_NAME.zip"
ZIP_PATH="$OUT_DIR/$ZIP_NAME_NAME"


#-------------------------------------------------------------------------------
# Resource Validation
#-------------------------------------------------------------------------------

# Check if resource exists
if [[ ! -d "$SRC_PATH" ]]; then
  echo Resource $SRC_PATH doesn\'t exist
  exit 1
fi

# Check if readme exists
if [[ ! -f "$README_PATH" ]]; then
  echo Resource $SRC_PATH doesn\'t have a README
  exit 1
fi

# Check if changelog exists
if [[ ! -f "$CHANGELOG_PATH" ]]; then
  echo Resource $SRC_PATH doesn\'t have a CHANGELOG
  exit 1
fi


#-------------------------------------------------------------------------------
# Git
#-------------------------------------------------------------------------------

# Merge branch only if it exists
if [[ ! $(git branch --list $GIT_BRANCH) ]]; then
  echo Branch $GIT_BRANCH doesn\'t exist
else
  git merge --squash $GIT_BRANCH
  git commit -m $GIT_TAG
  git push
fi

# Get Git commit for the release
GIT_HASH=$(git log --all --grep='$GIT_TAG' | grep commit | cut -d\  -f2)

# Tag only if tag doesn't exists
if [[ -z $GIT_HASH ]]; then
  echo No commit found for $GIT_TAG
elif [[ $(git tag --list $GIT_TAG) ]]; then
  echo Tag $GIT_TAG already exists
else
  git tag -a $GIT_TAG $GIT_HASH -m $GIT_TAG
  git push origin $GIT_TAG
fi


#-------------------------------------------------------------------------------
# Generate Archive
#-------------------------------------------------------------------------------

# Remove old stuff
if [[ -d $OUT_PATH ]]; then rm -rf $OUT_PATH; fi
if [[ -f $ZIP_PATH ]]; then rm $ZIP_PATH; fi

# Copy output directory
mkdir -p $OUT_DIR
cp -r $SRC_PATH $OUT_PATH

# Remove images
if [[ "$KEEP_IMAGES" != 1 ]]; then
  rm -rf $OUT_PATH/docs/assets/images/
  if [[ -d "$OUT_PATH/docs/markdown" ]];
  then sed -i "" -e 's/<img[^>]*>//g' $OUT_PATH/*.md $OUT_PATH/docs/markdown/*.md
  else sed -i "" -e 's/<img[^>]*>//g' $OUT_PATH/*.md
  fi
fi

# Generate HTML documentation
if [[ "$DOCS_HTML" == 1 ]]; then
  deno run --allow-read --allow-write $MD2HTML $TYPE $OUT_NAME
fi

# Generate text documentation (README and CHANGELOG only)
if [[ "$DOCS_TEXT" == 1 ]]; then
  deno run --allow-read --allow-write $MD2TEXT $TYPE $OUT_NAME
fi

# Remove markdown documentation
if [[ "$DOCS_MARKDOWN" != 1 ]]; then
  rm $OUT_PATH/*.md
  rm -rf $OUT_PATH/docs/markdown/
fi

# Remove all documentation
if [[ "$DOCS_HTML" != 1 && "$DOCS_MARKDOWN" != 1 && "$DOCS_TEXT" != 1 ]]; then
  rm -rf $OUT_PATH/docs/
fi

# Create archive
cd $OUT_DIR
zip -qr $ZIP_NAME $OUT_NAME -x "*.DS_Store"
