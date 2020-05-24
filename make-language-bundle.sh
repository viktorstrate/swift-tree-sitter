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
(cd $inputPath && npm build)

mkdir -p "$outputFolder"

sourceFiles=("$inputPath/src/*.c")

# Compile all source c files into object files
(cd "$outputFolder" && xcrun clang -c $sourceFiles -I"$inputPath/src")

cat > "$outputFolder/info.plist" <<-INFOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>STSLoadFunction</key>
	<string>tree_sitter_${languageName}</string>
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

