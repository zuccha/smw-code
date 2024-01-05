rm -rf dist/

npm run build > /dev/null

mv dist/index.html dist/byte_converter.html
cp CHANGELOG.md dist/CHANGELOG.md

BUILD_OUT_PATH=dist
