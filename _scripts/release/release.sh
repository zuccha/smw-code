################################################################################
#                                RELEASE SCRIPT                                #
################################################################################

# Usage: ./release.sh [flags] <type> <name> <version>
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
#     - Publish: Publish the resource with a custom script.
#
#   Lowercase flags are positives, uppercase flags are negatives ("don't"s).
#
#   By default, all phases are enabled, but by specifying a positive phase flag,
#   all phases become opt-in. If no positive phase flag is specified, a negative
#   phase flag will disable that phase.
#
#   By default, only text documentation is included in the release, but it can
#   be controlled either by defining a ".smw/config_release.sh" file in the
#   resource that overrides the defaults, or via flags. Flags have the highest
#   priority. Using a positive documentation flag will produce that type of
#   documentation, while a negative flag will prohibit it (if enabled by default
#   or in ".smw/config_release.sh").
#
#   Args:
#     <type>      Resource type, one of: "block", "patch", "port", "sprite", "uberasm"
#     <name>      Name of the resource
#     <version>   Version, following semver convention
#
#   Git:
#     -c <hash>   Commit to tag
#
#   Phases:
#     -e, -E      Merge branch
#     -g, -G      Create tag
#     -a, -A      Generate archive
#     -r, -R      Release on GitHub
#     -d, -D      Notify Discord
#     -s, -S      Update summary
#     -p, -P      Publish
#
#   Documentation:
#     -h, -H      Generate HTML documentation
#     -t, -T      Generate text documentation
#     -m, -M      Include markdown documentation
#     -i, -I      Include images and preserve image tags in HTML and markdown
#
#   Other:
#     -o          Open distribution folder after release.
#     -f          First release, skip some checks for files not found


#-------------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------------

# Make script exit if any command fails
set -e

# Name of the script
SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"

# Load env and utilities
source .env
source $SCRIPT_PATH/../log.sh


#-------------------------------------------------------------------------------
# Parse Flags and Arguments
#-------------------------------------------------------------------------------

# Parse flags
while getopts "eEgGaArRdDsSpPhHtTmMiIc:of" flag; do
  case $flag in
    e) FLAG_PHASE_MERGE_TEMP=1    ;;
    E) FLAG_PHASE_MERGE_TEMP=0    ;;
    g) FLAG_PHASE_TAG_TEMP=1      ;;
    G) FLAG_PHASE_TAG_TEMP=0      ;;
    a) FLAG_PHASE_ARCHIVE_TEMP=1  ;;
    A) FLAG_PHASE_ARCHIVE_TEMP=0  ;;
    r) FLAG_PHASE_RELEASE_TEMP=1  ;;
    R) FLAG_PHASE_RELEASE_TEMP=0  ;;
    d) FLAG_PHASE_DISCORD_TEMP=1  ;;
    D) FLAG_PHASE_DISCORD_TEMP=0  ;;
    s) FLAG_PHASE_SUMMARY_TEMP=1  ;;
    S) FLAG_PHASE_SUMMARY_TEMP=0  ;;
    p) FLAG_PHASE_PUBLISH_TEMP=1  ;;
    P) FLAG_PHASE_PUBLISH_TEMP=0  ;;
    m) FLAG_DOC_MARKDOWN_TEMP=1   ;;
    h) FLAG_DOC_HTML_TEMP=1       ;;
    H) FLAG_DOC_HTML_TEMP=0       ;;
    t) FLAG_DOC_TEXT_TEMP=1       ;;
    T) FLAG_DOC_TEXT_TEMP=0       ;;
    i) FLAG_DOC_IMAGES_TEMP=1     ;;
    I) FLAG_DOC_IMAGES_TEMP=0     ;;
    c) GIT_HASH=$OPTARG           ;;
    o) OPEN_OUT_PATH=1            ;;
    f) FIRST_RELEASE=1            ;;
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
  uberasm) TYPE_DIR=uberasm ;;
esac

# Determine type label
case $TYPE in
  block)   TYPE_LABEL=Block   ;;
  patch)   TYPE_LABEL=Patch   ;;
  port)    TYPE_LABEL=Port    ;;
  sprite)  TYPE_LABEL=Sprite  ;;
  uberasm) TYPE_LABEL=UberASM ;;
esac

# Args validation
if [[ -z "$TYPE" ]];     then log_fail "Type is empty";           exit 1; fi
if [[ -z "$TYPE_DIR" ]]; then log_fail "Type $TYPE is not valid"; exit 1; fi
if [[ -z "$NAME" ]];     then log_fail "Name is empty";           exit 1; fi
if [[ -z "$VERSION" ]];  then log_fail "Version is empty";        exit 1; fi


#-------------------------------------------------------------------------------
# Defines
#-------------------------------------------------------------------------------

# Variables used in child scripts
export ROOT=$(pwd)
export TAG="$TYPE/$NAME/$VERSION"

# Tools
MD2HTML="$SCRIPT_PATH/md2/md2html.ts"
MD2TEXT="$SCRIPT_PATH/md2/md2text.ts"
GH_GET_TITLE="$SCRIPT_PATH/gh/gh_get_title.ts"
GH_GET_NOTES="$SCRIPT_PATH/gh/gh_get_notes.ts"
SUMMARY_UPDATE="$SCRIPT_PATH/summary/update_summary.ts"

# Git
GIT_TAG=$TAG
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

# Custom CLI scripts
CLI_DIR=".smw"
CLI_CONFIG_NAME="$CLI_DIR/release_config.sh"
CLI_CONFIG_PATH="$SRC_PATH/$CLI_CONFIG_NAME"
CLI_BUILD_NAME="$CLI_DIR/release_build.sh"
CLI_BUILD_PATH="$SRC_PATH/$CLI_BUILD_NAME"
CLI_PUBLISH_NAME="$CLI_DIR/release_publish.sh"
CLI_PUBLISH_PATH="$SRC_PATH/$CLI_PUBLISH_NAME"

# Output directory and files
DIST_DIR="./.dist"
OUT_DIR="$DIST_DIR/$TYPE_DIR"
OUT_NAME="$NAME-$VERSION"
OUT_PATH="$OUT_DIR/$OUT_NAME"
ZIP_NAME="$OUT_NAME.zip"
ZIP_PATH="$OUT_DIR/$ZIP_NAME"


#-------------------------------------------------------------------------------
# Flags
#-------------------------------------------------------------------------------

# Documentation defaults
FLAG_DOC_MARKDOWN=0
FLAG_DOC_HTML=0
FLAG_DOC_TEXT=1
FLAG_DOC_IMAGES=0

# Resource flags
if [[ -f "$CLI_CONFIG_PATH" ]]; then
  source "$CLI_CONFIG_PATH"
fi

# All phases are enabled by default, but they become opt-in if any flag is set
if [[ $FLAG_PHASE_MERGE_TEMP == 1 ]]   || \
   [[ $FLAG_PHASE_TAG_TEMP == 1 ]]     || \
   [[ $FLAG_PHASE_ARCHIVE_TEMP == 1 ]] || \
   [[ $FLAG_PHASE_RELEASE_TEMP == 1 ]] || \
   [[ $FLAG_PHASE_DISCORD_TEMP == 1 ]] || \
   [[ $FLAG_PHASE_SUMMARY_TEMP == 1 ]] || \
   [[ $FLAG_PHASE_PUBLISH_TEMP == 1 ]]; then
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
FLAG_PHASE_PUBLISH=$FLAG_PHASE_DEFAULT

# Override phase flags
if [[ -n $FLAG_PHASE_MERGE_TEMP ]];   then FLAG_PHASE_MERGE=$FLAG_PHASE_MERGE_TEMP;     fi
if [[ -n $FLAG_PHASE_TAG_TEMP ]];     then FLAG_PHASE_TAG=$FLAG_PHASE_TAG_TEMP;         fi
if [[ -n $FLAG_PHASE_ARCHIVE_TEMP ]]; then FLAG_PHASE_ARCHIVE=$FLAG_PHASE_ARCHIVE_TEMP; fi
if [[ -n $FLAG_PHASE_RELEASE_TEMP ]]; then FLAG_PHASE_RELEASE=$FLAG_PHASE_RELEASE_TEMP; fi
if [[ -n $FLAG_PHASE_DISCORD_TEMP ]]; then FLAG_PHASE_DISCORD=$FLAG_PHASE_DISCORD_TEMP; fi
if [[ -n $FLAG_PHASE_SUMMARY_TEMP ]]; then FLAG_PHASE_SUMMARY=$FLAG_PHASE_SUMMARY_TEMP; fi
if [[ -n $FLAG_PHASE_PUBLISH_TEMP ]]; then FLAG_PHASE_PUBLISH=$FLAG_PHASE_PUBLISH_TEMP; fi

# Override documentation flags
if [[ -n $FLAG_DOC_MARKDOWN_TEMP ]]; then FLAG_DOC_MARKDOWN=$FLAG_DOC_MARKDOWN_TEMP; fi
if [[ -n $FLAG_DOC_HTML_TEMP ]];     then FLAG_DOC_HTML=$FLAG_DOC_HTML_TEMP;         fi
if [[ -n $FLAG_DOC_TEXT_TEMP ]];     then FLAG_DOC_TEXT=$FLAG_DOC_TEXT_TEMP;         fi
if [[ -n $FLAG_DOC_IMAGES_TEMP ]];   then FLAG_DOC_IMAGES=$FLAG_DOC_IMAGES_TEMP;     fi


#-------------------------------------------------------------------------------
# Resource Validation
#-------------------------------------------------------------------------------

if [[ -z $FIRST_RELEASE ]]; then
  # Check if resource exists
  if [[ ! -d "$SRC_PATH" ]]; then
    log_fail "Resource $SRC_PATH doesn't exist"
    exit 1
  fi

  # Check if readme exists
  if [[ ! -f "$README_PATH" ]]; then
    log_fail "Resource $SRC_PATH doesn't have a README"
    exit 1
  fi

  # Check if changelog exists
  if [[ ! -f "$CHANGELOG_PATH" ]]; then
    log_fail "Resource $SRC_PATH doesn't have a CHANGELOG"
    exit 1
  fi
fi

# Setup Git commit
if [[ -z "$GIT_HASH" ]]; then
  GIT_HASH=$(git log --all --grep="$GIT_TAG" | grep commit | cut -d\  -f2)
fi


#-------------------------------------------------------------------------------
# Git Merge
#-------------------------------------------------------------------------------

if [[ "$FLAG_PHASE_MERGE" != 1 ]]; then
  log_warn "Skip merge: disabled"
elif [[ -n "$GIT_HASH" ]]; then
  log_warn "Skip merge: already merged"
elif [[ ! $(git branch --list "$GIT_BRANCH") ]]; then
  log_warn "Skip merge: branch $GIT_BRANCH doesn\'t exist"
else
  log_info "Merge $GIT_BRANCH"

  git merge --squash "$GIT_BRANCH" > /dev/null
  git commit -m "$GIT_TAG" > /dev/null
  git push > /dev/null
  GIT_HASH=$(git log --all --grep="$GIT_TAG" | grep commit | cut -d\  -f2)
fi


#-------------------------------------------------------------------------------
# Git Tag
#-------------------------------------------------------------------------------

if [[ "$FLAG_PHASE_TAG" != 1 ]]; then
  log_warn "Skip tag: disabled"
elif [[ -z "$GIT_HASH" ]]; then
  log_warn "Skip tag: no commit found for $GIT_TAG"
elif [[ $(git tag --list "$GIT_TAG") ]]; then
  log_warn "Skip tag: tag $GIT_TAG already exists"
else
  log_info "Tag $GIT_TAG"

  git tag -a "$GIT_TAG" "$GIT_HASH" -m "$GIT_TAG" > /dev/null
  git push origin "$GIT_TAG" > /dev/null
fi


#-------------------------------------------------------------------------------
# Generate Archive
#-------------------------------------------------------------------------------

if [[ "$FLAG_PHASE_ARCHIVE" != 1 ]]; then
  log_warn "Skip archive: disabled"
else
  log_info "Create archive $ZIP_PATH"

  # Copy output directory
  mkdir -p "$OUT_DIR"
  rm -rf "$OUT_PATH" "$ZIP_PATH"

  if [[ -f "$CLI_BUILD_PATH" ]]; then
    pushd "$SRC_PATH" > /dev/null
    BUILD_OUT_PATH=$("./$CLI_BUILD_NAME")
    popd > /dev/null

    mkdir -p "$OUT_DIR"
    cp -r "$SRC_PATH/$BUILD_OUT_PATH" "$OUT_PATH"
  else
    cp -r "$SRC_PATH" "$OUT_PATH"
  fi

  # Remove images
  if [[ "$FLAG_DOC_IMAGES" == 1 ]]; then
    log_info "\t...with images"
  else
    rm -rf "$OUT_PATH/docs/assets/images/"
    if [[ -d "$OUT_PATH/docs/markdown" ]];
    then sed -i "" -e 's/<img[^>]*>//g' "$OUT_PATH"/*.md "$OUT_PATH"/docs/markdown/*.md
    else sed -i "" -e 's/<img[^>]*>//g' "$OUT_PATH"/*.md
    fi
  fi

  # Generate HTML documentation
  if [[ "$FLAG_DOC_HTML" == 1 ]]; then
    deno run --allow-env --allow-read --allow-sys --allow-write "$MD2HTML" "$DIST_DIR" "$TYPE" "$OUT_NAME"
    log_info "\t...with HTML"
  fi

  # Generate text documentation (README and CHANGELOG only)
  if [[ "$FLAG_DOC_TEXT" == 1 ]]; then
    deno run --allow-env --allow-read --allow-write "$MD2TEXT" "$DIST_DIR" "$TYPE" "$OUT_NAME"
    log_info "\t...with text"
  fi

  # Remove markdown documentation
  if [[ "$FLAG_DOC_MARKDOWN" == 1 ]]; then
    log_info "\t...with markdown"
  else
    rm $OUT_PATH/*.md
    rm -rf "$OUT_PATH/docs/markdown/"
  fi

  # Remove all documentation
  if [[ "$FLAG_DOC_HTML" != 1 && "$FLAG_DOC_MARKDOWN" != 1 && "$FLAG_DOC_TEXT" != 1 ]]; then
    rm -rf "$OUT_PATH/docs/"
  fi

  # Remove CLI custom files
  if [[ -d "$OUT_PATH/$CLI_DIR" ]]; then rm -rf "$OUT_PATH/$CLI_DIR"; fi

  # Remove empty directories
  find "$OUT_PATH" -type d -empty -delete

  # Create archive
  cd "$OUT_DIR"
  zip -qr "$ZIP_NAME" "$OUT_NAME" -x "*.DS_Store"
  cd - > /dev/null

  # Verify that archive has been created
  if [[ ! -f "$ZIP_PATH" ]]; then
    log_fail "Failed to create archive";
    exit 1
  fi
fi


#-------------------------------------------------------------------------------
# Create Release
#-------------------------------------------------------------------------------

if [[ "$FLAG_PHASE_RELEASE" != 1 ]]; then
  log_warn "Skip release: disabled"
elif [[ $(gh release list | grep "$GIT_TAG") ]]; then
  log_warn "Skip release: already released"
elif [[ ! $(git tag --list "$GIT_TAG") ]]; then
  log_warn "Skip release: tag $GIT_TAG found"
else
  log_info "Publish release $GH_URL"

  # Get notes and title
  GH_NOTES=$(deno run --allow-env --allow-read "$GH_GET_NOTES" "$ROOT" "$TYPE" "$NAME")
  GH_TITLE="$(deno run --allow-env --allow-read "$GH_GET_TITLE" "$ROOT" "$TYPE" "$NAME") $VERSION"

  # Generate release
  GH_URL=$(gh release create "$GIT_TAG" "$ZIP_PATH" --latest --notes "$GH_NOTES" --title "$GH_TITLE" --verify-tag)
fi


#-------------------------------------------------------------------------------
# Notify Discord
#-------------------------------------------------------------------------------

if [[ "$FLAG_PHASE_DISCORD" != 1 ]]; then
  log_warn "Skip Discord: disabled"
elif [[ -z "$GH_URL" ]]; then
  log_warn "Skip Discord: no release"
elif [[ -z "$DISCORD_WEBHOOK" ]]; then
  log_warn "Skip Discord: no webhook"
else
  log_info "Notify Discord"
  curl -H "Content-Type: application/json" -d "{\"username\":\"Release\",\"content\":\"\",\"embeds\":[{\"title\":\"$GH_TITLE\",\"description\":\"$TYPE_LABEL\",\"url\":\"$GH_URL\"}]}" $DISCORD_WEBHOOK
fi


#-------------------------------------------------------------------------------
# Update Main README
#-------------------------------------------------------------------------------

if [[ "$FLAG_PHASE_SUMMARY" != 1 ]]; then
  log_warn "Skip summary: disabled"
elif [[ -z $(gh release list | grep "$GIT_TAG") ]]; then
  log_warn "Skip summary: no release for $GIT_TAG"
elif [[ $(jq ".\"$TYPE_DIR\".\"$NAME\".version" "$SUMMARY_JSON") == "\"$VERSION\"" ]]; then
  log_warn "Skip summary: already up to date"
else
  log_info "Update summary"

  # Update JSON
  GH_TITLE="$(deno run --allow-env --allow-read "$GH_GET_TITLE" "$ROOT" "$TYPE" "$NAME")"
  jq ".\"$TYPE_DIR\".\"$NAME\" += {\"name\":\"$GH_TITLE\",\"version\":\"$VERSION\"}" "$SUMMARY_JSON" > "$SUMMARY_JSON.temp"
  rm "$SUMMARY_JSON"
  mv "$SUMMARY_JSON.temp" "$SUMMARY_JSON"

  # Generate README
  deno run --allow-env --allow-read --allow-write "$SUMMARY_UPDATE" "$SUMMARY_PATH" "$SUMMARY_JSON"

  # Commit update
  git add "$SUMMARY_PATH" "$SUMMARY_JSON" > /dev/null
  git commit -m "Update README" > /dev/null
  git push > /dev/null
fi


#-------------------------------------------------------------------------------
# Custom Publish
#-------------------------------------------------------------------------------

if [[ "$FLAG_PHASE_PUBLISH" != 1 ]]; then
  log_warn "Skip publish: disabled"
elif [[ ! -f "$CLI_PUBLISH_PATH" ]]; then
  log_warn "Skip publish: no custom publish script"
else
  pushd "$SRC_PATH" > /dev/null
  "./$CLI_PUBLISH_NAME"
  popd > /dev/null
fi

#-------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------

# If all went well, print a message
log_good "Release complete!"
if [[ "$OPEN_OUT_PATH" == 1 ]]; then open "$OUT_PATH"; fi
