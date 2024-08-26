# npm rename
npmrn() {
  # Split package name and version by '@'
  local input=$1
  local package=${input%@*}
  local version=${input#*@}

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

