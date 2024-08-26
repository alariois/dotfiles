# npm rename
npmrn() {
  # Split package name and version by '@'
  local input=$1

  # Find the last '@' symbol in the input
  local package=${input%@*}
  local version=${input##*@}

  # If no version is specified, assume @latest
  if [[ "$version" == "$package" || "$version" == "" ]]; then
    version=$(npm show "$package" version)
  elif [[ "$version" == "latest" ]]; then
    version=$(npm show "$package" version)
  fi

  echo "replacing with ${package} version ${version}"

  # Replace the package version in all package.json files, excluding node_modules
  find -not -path '*node_modules*' -name 'package.json' | xargs sed -i "s#\(\"$package\" *: *\"[\^~]*\)[0-9]\+\.[0-9]\+\.[0-9]\+\"#\1$version\"#"
}

# just updates all the packages to the latest
pnpmupdate() {
  for package in $(pnpm outdated -r --json | jq -r 'keys[]'); do npmrn "$package@latest"; done
}

export -f npmrn
export -f pnpmupdate
