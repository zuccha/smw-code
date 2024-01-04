################################################################################
#                                RELEASE SCRIPT                                #
################################################################################

# Usage: ./_utils/release [flags] <type> <name> <version>
#
#   Go through all the steps to publish a release of a resource on GitHub:
#     - Merge: Merge a branch named as the resource tag into main. This branch
#       is supposed to contain the changes from the new version of the resource.
#     - Tag: Tag the commit of the release. By default, the commit with the
#       resource tag, but a custom commit can be given.
#     - Archive: Generate the archive to include in the published release. You
#       can customize the type of the documentation to include.
#     - Publish: Publish a new release on GitHub.
#     - Notify: Post a message on Discord.
#     - Summary: Update the main README of the repository.
#
#   By default, all phases are enabled, but when one is specified via flag, then
#   they all become opt-in. By default, only text documentation is included in
#   the release, but it can be controlled either by defining a ".release" file
#   in the resource that overrides the defaults, or via flags; flags have the
#   highest priority; upper case flags are negatives (i.e., "don't"s).
#
#   Args:
#     <type>      Resource type, one of: "block", "patch", "port", "sprite", "tool", "uberasm"
#     <name>      Name of the resource
#     <version>   Version, following semver convention
#
#   Git:
#     -c <hash>   Commit to tag
#
#   Phases:
#     -e          Merge branch
#     -g          Create tag
#     -a          Generate archive
#     -r          Publish release
#     -d          Notify Discord
#     -s          Update summary
#
#   Documentation:
#     -h, -H      Generate HTML documentation
#     -t, -T      Generate text documentation
#     -m, -M      Include markdown documentation
#     -i, -I      Include images and preserve image tags in HTML and markdown


#-------------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------------

# Make script exit if any command fails
set -e

# Load env
source .env


#-------------------------------------------------------------------------------
# Parse Flags and Arguments
#-------------------------------------------------------------------------------

# Parse flags
while getopts "eEgGaArRdDsShHtTmMiIc:" flag; do
  case $flag in
    e) FLAG_PHASE_MERGE_TEMP=1    ;;
    g) FLAG_PHASE_TAG_TEMP=1      ;;
    a) FLAG_PHASE_ARCHIVE_TEMP=1  ;;
    r) FLAG_PHASE_RELEASE_TEMP=1  ;;
    d) FLAG_PHASE_DISCORD_TEMP=1  ;;
    s) FLAG_PHASE_SUMMARY_TEMP=1  ;;
    m) FLAG_DOC_MARKDOWN_TEMP=1   ;;
    h) FLAG_DOC_HTML_TEMP=1       ;;
    H) FLAG_DOC_HTML_TEMP=0       ;;
    t) FLAG_DOC_TEXT_TEMP=1       ;;
    T) FLAG_DOC_TEXT_TEMP=0       ;;
    i) FLAG_DOC_IMAGES_TEMP=1     ;;
    I) FLAG_DOC_IMAGES_TEMP=0     ;;
    c) GIT_HASH=$OPTARG           ;;
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
# Flags
#-------------------------------------------------------------------------------

# Documentation defaults
FLAG_DOC_MARKDOWN=0
FLAG_DOC_HTML=0
FLAG_DOC_TEXT=1
FLAG_DOC_IMAGES=0

# Resource flags
if [[ -f "./$TYPE_DIR/$NAME/.release" ]]; then
  source "./$TYPE_DIR/$NAME/.release"
fi

# All phases are enabled by default, but they become opt-in if any flag is set
if [[ -n $FLAG_PHASE_MERGE_TEMP ]]   || \
   [[ -n $FLAG_PHASE_TAG_TEMP ]]     || \
   [[ -n $FLAG_PHASE_ARCHIVE_TEMP ]] || \
   [[ -n $FLAG_PHASE_RELEASE_TEMP ]] || \
   [[ -n $FLAG_PHASE_DISCORD_TEMP ]] || \
   [[ -n $FLAG_PHASE_SUMMARY_TEMP ]]; then
  FLAG_PHASE_DEFAULT=0
else
  FLAG_PHASE_DEFAULT=1
fi

# Phase defaults
FLAG_PHASE_MERGE=$FLAG_PHASE_DEFAULT
FLAG_PHASE_TAG=$FLAG_PHASE_DEFAULT
FLAG_PHASE_ARCHIVE=$FLAG_PHASE_DEFAULT
FLAG_PHASE_RELEASE=$FLAG_PHASE_DEFAULT
FLAG_PHASE_DISCORD=$FLAG_PHASE_DEFAULT
FLAG_PHASE_SUMMARY=$FLAG_PHASE_DEFAULT

# Override phase flags
if [[ -n $FLAG_PHASE_MERGE_TEMP ]];   then FLAG_PHASE_MERGE=$FLAG_PHASE_MERGE_TEMP;     fi
if [[ -n $FLAG_PHASE_TAG_TEMP ]];     then FLAG_PHASE_TAG=$FLAG_PHASE_TAG_TEMP;         fi
if [[ -n $FLAG_PHASE_ARCHIVE_TEMP ]]; then FLAG_PHASE_ARCHIVE=$FLAG_PHASE_ARCHIVE_TEMP; fi
if [[ -n $FLAG_PHASE_RELEASE_TEMP ]]; then FLAG_PHASE_RELEASE=$FLAG_PHASE_RELEASE_TEMP; fi
if [[ -n $FLAG_PHASE_DISCORD_TEMP ]]; then FLAG_PHASE_DISCORD=$FLAG_PHASE_DISCORD_TEMP; fi
if [[ -n $FLAG_PHASE_SUMMARY_TEMP ]]; then FLAG_PHASE_SUMMARY=$FLAG_PHASE_SUMMARY_TEMP; fi

# Override documentation flags
if [[ -n $FLAG_DOC_MARKDOWN_TEMP ]]; then FLAG_DOC_MARKDOWN=$FLAG_DOC_MARKDOWN_TEMP; fi
if [[ -n $FLAG_DOC_HTML_TEMP ]];     then FLAG_DOC_HTML=$FLAG_DOC_HTML_TEMP;         fi
if [[ -n $FLAG_DOC_TEXT_TEMP ]];     then FLAG_DOC_TEXT=$FLAG_DOC_TEXT_TEMP;         fi
if [[ -n $FLAG_DOC_IMAGES_TEMP ]];   then FLAG_DOC_IMAGES=$FLAG_DOC_IMAGES_TEMP;     fi


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
C_GOOD='\033[0;32m'
C_INFO='\033[0;34m'
C_WARN='\033[0;33m'
C_FAIL='\033[0;31m'
C_NONE='\033[0m'


#-------------------------------------------------------------------------------
# Resource Validation
#-------------------------------------------------------------------------------

# Check if resource exists
if [[ ! -d "$SRC_PATH" ]]; then
  echo ${C_FAIL}Resource $SRC_PATH doesn\'t exist${C_NONE}
  exit 1
fi

# Check if readme exists
if [[ ! -f "$README_PATH" ]]; then
  echo ${C_FAIL}Resource $SRC_PATH doesn\'t have a README${C_NONE}
  exit 1
fi

# Check if changelog exists
if [[ ! -f "$CHANGELOG_PATH" ]]; then
  echo ${C_FAIL}Resource $SRC_PATH doesn\'t have a CHANGELOG${C_NONE}
  exit 1
fi

# Setup Git commit
if [[ -z $GIT_HASH ]]; then
  GIT_HASH=$(git log --all --grep="$GIT_TAG" | grep commit | cut -d\  -f2)
fi


#-------------------------------------------------------------------------------
# Git Merge
#-------------------------------------------------------------------------------

if [[ $FLAG_PHASE_MERGE != 1 ]]; then
  echo ${C_WARN}Skip merge: archive only mode${C_NONE}
elif [[ -n $GIT_HASH ]]; then
  echo ${C_WARN}Skip merge: already merged${C_NONE}
elif [[ ! $(git branch --list $GIT_BRANCH) ]]; then
  echo ${C_WARN}Skip merge: branch $GIT_BRANCH doesn\'t exist${C_NONE}
else
  git merge --squash $GIT_BRANCH > /dev/null
  git commit -m $GIT_TAG > /dev/null
  git push > /dev/null
  GIT_HASH=$(git log --all --grep='$GIT_TAG' | grep commit | cut -d\  -f2)
  echo ${C_INFO}Merge $GIT_BRANCH${C_NONE}
fi


#-------------------------------------------------------------------------------
# Git Tag
#-------------------------------------------------------------------------------

if [[ $FLAG_PHASE_TAG != 1 ]]; then
  echo ${C_WARN}Skip tag: disabled${C_NONE}
elif [[ -z $GIT_HASH ]]; then
  echo ${C_WARN}Skip tag: no commit found for $GIT_TAG${C_NONE}
elif [[ $(git tag --list $GIT_TAG) ]]; then
  echo ${C_WARN}Skip tag: tag $GIT_TAG already exists${C_NONE}
else
  git tag -a $GIT_TAG $GIT_HASH -m $GIT_TAG > /dev/null
  git push origin $GIT_TAG > /dev/null
  echo ${C_INFO}Tag $GIT_TAG${C_NONE}
fi


#-------------------------------------------------------------------------------
# Generate Archive
#-------------------------------------------------------------------------------

if [[ $FLAG_PHASE_ARCHIVE != 1 ]]; then
  echo ${C_WARN}Skip archive: disabled${C_NONE}
else
  # Copy output directory
  mkdir -p $OUT_DIR
  rm -rf $OUT_PATH $ZIP_PATH
  cp -r $SRC_PATH $OUT_PATH

  # Remove images
  if [[ $FLAG_DOC_IMAGES != 1 ]]; then
    rm -rf $OUT_PATH/docs/assets/images/
    if [[ -d "$OUT_PATH/docs/markdown" ]];
    then sed -i "" -e 's/<img[^>]*>//g' $OUT_PATH/*.md $OUT_PATH/docs/markdown/*.md
    else sed -i "" -e 's/<img[^>]*>//g' $OUT_PATH/*.md
    fi
  fi

  # Generate HTML documentation
  if [[ $FLAG_DOC_HTML == 1 ]]; then
    deno run --allow-read --allow-write $MD2HTML $TYPE $OUT_NAME
  fi

  # Generate text documentation (README and CHANGELOG only)
  if [[ $FLAG_DOC_TEXT == 1 ]]; then
    deno run --allow-read --allow-write $MD2TEXT $TYPE $OUT_NAME
  fi

  # Remove markdown documentation
  if [[ $FLAG_DOC_MARKDOWN != 1 ]]; then
    rm $OUT_PATH/*.md
    rm -rf $OUT_PATH/docs/markdown/
  fi

  # Remove all documentation
  if [[ $FLAG_DOC_HTML != 1 && $FLAG_DOC_MARKDOWN != 1 && $FLAG_DOC_TEXT != 1 ]]; then
    rm -rf $OUT_PATH/docs/
  fi

  # Remove config file
  if [[ -f "$OUT_PATH/.release" ]]; then rm $OUT_PATH/.release; fi

  # Create archive
  cd $OUT_DIR
  zip -qr $ZIP_NAME $OUT_NAME -x "*.DS_Store"
  cd - > /dev/null

  # Verify that archive has been created
  if [[ ! -f $ZIP_PATH ]];
  then echo ${C_FAIL}Failed to create archive${C_NONE}; exit 1
  else echo ${C_INFO}Create archive $ZIP_PATH${C_NONE}
  fi
fi


#-------------------------------------------------------------------------------
# Create Release
#-------------------------------------------------------------------------------

if [[ $FLAG_PHASE_RELEASE != 1 ]]; then
  echo ${C_WARN}Skip release: disabled${C_NONE}
elif [[ $(gh release list | grep $GIT_TAG) ]]; then
  echo ${C_WARN}Skip release: already released${C_NONE}
elif [[ ! $(git tag --list $GIT_TAG) ]]; then
  echo ${C_WARN}Skip release: tag $GIT_TAG found${C_NONE}
else
  # Get notes and title
  GH_NOTES=$(deno run --allow-read $GH_GET_NOTES $TYPE $NAME)
  GH_TITLE="$(deno run --allow-read $GH_GET_TITLE $TYPE $NAME) $VERSION"

  # Generate release
  GH_URL=$(gh release create $GIT_TAG $ZIP_PATH --latest --notes "$GH_NOTES" --title "$GH_TITLE" --verify-tag)
  echo ${C_INFO}Publish release $GH_URL${C_NONE}
fi


#-------------------------------------------------------------------------------
# Notify Discord
#-------------------------------------------------------------------------------

if [[ $FLAG_PHASE_DISCORD != 1 ]]; then
  echo ${C_WARN}Skip Discord: disabled${C_NONE}
elif [[ -z $GH_URL ]]; then
  echo ${C_WARN}Skip Discord: no release${C_NONE}
elif [[ -z $DISCORD_WEBHOOK ]]; then
  echo ${C_WARN}Skip Discord: no webhook${C_NONE}
else
  GM_EMBED="{\"title\":\"$GH_TITLE\",\"url\":\"$GH_URL\",\"color\":15258703}"
  curl -H "Content-Type: application/json" -d "{\"username\":\"Release\",\"content\":\"\",\"embeds\":[{\"title\":\"$GH_TITLE\",\"url\":\"$GH_URL\"}]}" $DISCORD_WEBHOOK
  echo ${C_INFO}Notify Discord${C_NONE}
fi


#-------------------------------------------------------------------------------
# Update Main README
#-------------------------------------------------------------------------------

if [[ $FLAG_PHASE_SUMMARY != 1 ]]; then
  echo ${C_WARN}Skip summary: disabled${C_NONE}
elif [[ -z $(gh release list | grep $GIT_TAG) ]]; then
  echo ${C_WARN}Skip summary: no release for $GIT_TAG${C_NONE}
elif [[ $(jq ".$TYPE_DIR.$NAME.version" $SUMMARY_JSON) == "\"$VERSION\"" ]]; then
  echo ${C_WARN}Skip summary: already up to date${C_NONE}
else
  # Update JSON
  GH_TITLE="$(deno run --allow-read $GH_GET_TITLE $TYPE $NAME)"
  jq ".$TYPE_DIR.$NAME += {\"name\":\"$GH_TITLE\",\"version\":\"$VERSION\"}" $SUMMARY_JSON > $SUMMARY_JSON.temp
  rm $SUMMARY_JSON
  mv $SUMMARY_JSON.temp $SUMMARY_JSON

  # Generate README
  deno run --allow-read --allow-write $SUMMARY_UPDATE $SUMMARY_PATH $SUMMARY_JSON

  # Commit update
  git add $SUMMARY_PATH $SUMMARY_JSON > /dev/null
  git commit -m "Update README" > /dev/null
  git push > /dev/null

  # Notify
  echo ${C_INFO}Update summary${C_NONE}
fi


#-------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------

# If all went well, print a message
echo ${C_GOOD}Release complete!${C_NONE}
