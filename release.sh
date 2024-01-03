################################################################################
#                                RELEASE SCRIPT                                #
################################################################################

# Usage: ./_utils/release [-htmi] <type> <name> <version>
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
MD2HTML="./_utils/md2/md2html.ts"
MD2TEXT="./_utils/md2/md2text.ts"
GH_GET_TITLE="./_utils/gh/gh_get_title.ts"
GH_GET_NOTES="./_utils/gh/gh_get_notes.ts"
SUMMARY_UPDATE="./_utils/summary/update_summary.ts"

# Git
GIT_TAG="$TYPE/$NAME/$VERSION"
GIT_BRANCH="feat/$GIT_TAG"

# Summary
SUMMARY_PATH="./README.md"
SUMMARY_JSON="./releases.json"

# Source directory and files
SRC_PATH="./$TYPE_DIR/$NAME"
README_NAME="README.md"
README_PATH="$SRC_PATH/$README_NAME"
CHANGELOG_NAME="CHANGELOG.md"
CHANGELOG_PATH="$SRC_PATH/$CHANGELOG_NAME"

# Output directory and files
OUT_DIR="./.dist/$TYPE_DIR"
OUT_NAME="$NAME-$VERSION"
OUT_PATH="$OUT_DIR/$OUT_NAME"
ZIP_NAME="$OUT_NAME.zip"
ZIP_PATH="$OUT_DIR/$ZIP_NAME"

# Colors for logging
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'


#-------------------------------------------------------------------------------
# Resource Validation
#-------------------------------------------------------------------------------

# Check if resource exists
if [[ ! -d "$SRC_PATH" ]]; then
  echo ${RED}Resource $SRC_PATH doesn\'t exist${NC}
  exit 1
fi

# Check if readme exists
if [[ ! -f "$README_PATH" ]]; then
  echo ${RED}Resource $SRC_PATH doesn\'t have a README${NC}
  exit 1
fi

# Check if changelog exists
if [[ ! -f "$CHANGELOG_PATH" ]]; then
  echo ${RED}Resource $SRC_PATH doesn\'t have a CHANGELOG${NC}
  exit 1
fi


#-------------------------------------------------------------------------------
# Git
#-------------------------------------------------------------------------------

# Get Git commit for the release
GIT_HASH=$(git log --all --grep="$GIT_TAG" | grep commit | cut -d\  -f2)

# Merge branch only if it exists
if [[ -n $GIT_HASH ]]; then
  echo ${BLUE}Skip merge: already merged${NC}
elif [[ ! $(git branch --list $GIT_BRANCH) ]]; then
  echo ${BLUE}Skip merge: branch $GIT_BRANCH doesn\'t exist${NC}
else
  git merge --squash $GIT_BRANCH
  git commit -m $GIT_TAG
  git push
  GIT_HASH=$(git log --all --grep='$GIT_TAG' | grep commit | cut -d\  -f2)
fi

# Tag only if tag doesn't exists
if [[ -z $GIT_HASH ]]; then
  echo ${BLUE}Skip tag: no commit found for $GIT_TAG${NC}
elif [[ $(git tag --list $GIT_TAG) ]]; then
  echo ${BLUE}Skip tag: tag $GIT_TAG already exists${NC}
else
  git tag -a $GIT_TAG $GIT_HASH -m $GIT_TAG
  git push origin $GIT_TAG
fi


#-------------------------------------------------------------------------------
# Generate Archive
#-------------------------------------------------------------------------------

# Copy output directory
mkdir -p $OUT_DIR
rm -rf $OUT_PATH $ZIP_PATH
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
cd - > /dev/null

# Verify that archive has been created
if [[ ! -f $ZIP_PATH ]]; then
  echo ${RED}Failed to create archive${NC}
  exit 1
fi


#-------------------------------------------------------------------------------
# Create Release
#-------------------------------------------------------------------------------

# Tag is necessary for release
if [[ $(gh release list | grep $GIT_TAG) ]]; then
  echo ${BLUE}Skip release: already released${NC}
elif [[ ! $(git tag --list $GIT_TAG) ]]; then
  echo ${BLUE}Skip release: tag $GIT_TAG found${NC}
else
  # Get notes and title
  GH_NOTES=$(deno run --allow-read $GH_GET_NOTES $TYPE $NAME)
  GH_TITLE="$(deno run --allow-read $GH_GET_TITLE $TYPE $NAME) $VERSION"

  # Generate release
  gh release create $GIT_TAG $ZIP_PATH --latest --notes "$GH_NOTES" --title "$GH_TITLE" --verify-tag
fi


#-------------------------------------------------------------------------------
# Update Main README
#-------------------------------------------------------------------------------

# Update main README
if [[ -z $(gh release list | grep $GIT_TAG) ]]; then
  echo ${BLUE}Skip summary: no release for $GIT_TAG${NC}
elif [[ $(jq ".$TYPE_DIR.$NAME.version" $SUMMARY_JSON) == "\"$VERSION\"" ]]; then
  echo ${BLUE}Skip summary: already up to date${NC}
else
  # Update JSON
  GH_TITLE="$(deno run --allow-read $GH_GET_TITLE $TYPE $NAME)"
  jq ".$TYPE_DIR.$NAME += {\"name\":\"$GH_TITLE\",\"version\":\"$VERSION\"}" $SUMMARY_JSON > $SUMMARY_JSON.temp
  rm $SUMMARY_JSON
  mv $SUMMARY_JSON.temp $SUMMARY_JSON

  # Generate README
  deno run --allow-read --allow-write $SUMMARY_UPDATE $SUMMARY_PATH $SUMMARY_JSON
fi
