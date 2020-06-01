#!/bin/sh
set -e

inputPath="$(realpath $1)"

if [ ! -d "$inputPath" ]; then
  echo "Usage: $0 <tree-sitter language dir>"
  exit 1
fi

if [ ! -f "$inputPath/package.json" ]; then
  echo "package.json missing in directory"
  exit 1
fi

languageName="$(jq .name $inputPath/src/grammar.json -r)"
version="$(jq .version $inputPath/package.json -r)"
outputFolder="$(pwd)/$languageName-bundlefiles"

echo "Building language bundle files for $languageName at $inputPath"

(cd $inputPath && npm install)
(cd $inputPath && npm run build || echo "WARN: package.json did not have a build command")

mkdir -p "$outputFolder"

# Copy source files
sourceFiles=("$inputPath/src/*.c")
headerFiles=("$inputPath/src/tree_sitter/*.h")

cp $sourceFiles "$outputFolder/"
cp $headerFiles "$outputFolder/"

# Copy resource files
if [ -d "$inputPath/queries" ]; then
	cp -r "$inputPath/queries" "$outputFolder/"
fi

# Generate xml metadata
if jq . "$inputPath/package.json" &> /dev/null; then
	metaScope="$(yq --xml-output '{ key: "Scope", string: ."tree-sitter"[].scope }' $inputPath/package.json)"
	metaFiletypes="$(yq --xml-output '{ key: "Filetypes", array: { string: ."tree-sitter"[]."file-types" } }' $inputPath/package.json)"
	metaFirstLineRegex="$(yq --xml-output '{ key: "FirstLineRegex", string: ."tree-sitter"[]."first-line-regex" }' $inputPath/package.json)"
	metaContentRegex="$(yq --xml-output '{ key: "ContentRegex", string: ."tree-sitter"[]."content-regex" }' $inputPath/package.json)"
	metaInjectionRegex="$(yq --xml-output '{ key: "InjectionRegex", string: ."tree-sitter"[]."injection-regex" }' $inputPath/package.json)"
	#metaHighlights="$(yq --xml-output '{ key: "Highlights", array: { string: ."tree-sitter"[]."highlights" } }' $inputPath/package.json)"
fi

cat > "$outputFolder/info.plist" <<-INFOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>STSLoadFunction</key>
	<string>tree_sitter_${languageName}</string>
	<key>TreeSitter</key>
	<dict>
	${metaScope}
	${metaFiletypes}
	${metaFirstLineRegex}
	${metaContentRegex}
	${metaInjectionRegex}
	</dict>
	<key>CFBundleExecutable</key>
	<string>${languageName}</string>
	<key>CFBundleIdentifier</key>
	<string>io.github.viktorstrate.SwiftTreeSitter.language.${languageName}</string>
	<key>CFBundleName</key>
	<string>${languageName}</string>
	<key>CFBundleShortVersionString</key>
	<string>${version}</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>MacOSX</string>
	</array>
</dict>
</plist>
INFOPLIST

