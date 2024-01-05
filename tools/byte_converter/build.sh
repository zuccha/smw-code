rm -rf dist/

npm run build

mv dist/index.html dist/byte_converter.html
cp CHANGELOG.md dist/CHANGELOG.md

BUILD_OUT_PATH=dist
