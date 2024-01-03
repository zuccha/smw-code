# Usage: ./.utils/release [-htmi] <type> <name> <version>
#   -h          Generate HTML documentation
#   -t          Generate text documentation
#   -m          Include markdown documentation
#   -i          Include images and preserve image tags in HTML and markdown
#   <type>      Resource type, one of: "block", "patch", "port", "sprite", "tool", "uberasm"
#   <name>      Name of the resource
#   <version>   Version, following semver convention

# Make script exit if any command fails
set -e

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

# Generic variables
TAG="$TYPE/$NAME/$VERSION"
BRANCH="feat/$TAG"
DIST="./_dist/$TYPE"
SRC="./$TYPE/$NAME"
OUT="$DIST/$NAME-$VERSION"
ZIP="$OUT.zip"

# Check if resource exists
if [[ ! -d "$SRC" ]]; then
    echo Resource $SRC doesn\'t exist
    exit 1
fi

# Check if readme exists
if [[ ! -f "$SRC/README.md" ]]; then
    echo Resource $SRC doesn\'t have a README
    exit 1
fi

# Check if changelog exists
if [[ ! -f "$SRC/CHANGELOG.md" ]]; then
    echo Resource $SRC doesn\'t have a CHANGELOG
    exit 1
fi

# Merge branch and setup tags
git merge --squash $BRANCH
git commit -m $TAG
git tag $TAG
git push
git push origin $TAG

# Copy output directory
mkdir -p $DIST
rm -rf $OUT $ZIP
cp -r $SRC $OUT

# Remove images
if [[ "$KEEP_IMAGES" != 1 ]]; then
    rm -rf $OUT/docs/assets/images/
    if [[ -d "$OUT/docs/markdown" ]];
    then sed -i "" -e 's/<img[^>]*>//g' $OUT/*.md $OUT/docs/markdown/*.md
    else sed -i "" -e 's/<img[^>]*>//g' $OUT/*.md
    fi
fi

# Generate HTML documentation
if [[ "$DOCS_HTML" == 1 ]]; then
    deno run --allow-read --allow-write ./.utils/md2html.ts $TYPE $NAME-$VERSION
fi

# Generate text documentation (README and CHANGELOG only)
if [[ "$DOCS_TEXT" == 1 ]]; then
    for file in $OUT/*.md; do cp "$file" "${file%.md}.txt"; done
    deno run --allow-read --allow-write ./.utils/md2text.ts $TYPE $NAME-$VERSION
fi

# Remove markdown documentation
if [[ "$DOCS_MARKDOWN" != 1 ]]; then
    rm $OUT/*.md
    rm -rf $OUT/docs/markdown/
fi

# Remove all documentation
if [[ "$DOCS_HTML" != 1 && "$DOCS_MARKDOWN" != 1 && "$DOCS_TEXT" != 1 ]]; then
    rm -rf $OUT/docs/
fi

# Create archive
zip -qr $ZIP $OUT -x "*.DS_Store"
