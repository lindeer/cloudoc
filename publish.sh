#!/bin/bash

DRY_RUN=--dry-run
for arg in "$@"
do
  case $arg in
    -r)
      DRY_RUN=;
      ;;
    *)
      ;;
  esac
done

if [[ -z "$DRY_RUN" ]]; then
  echo "Start publishing ..."
  unset PUB_HOSTED_URL
  if [[ -z "$http_proxy" ]]; then
    echo "\$http_proxy is empty, uploading may have trouble, set http://127.0.0.1:7890."
    export http_proxy="http://127.0.0.1:7890"
  fi
else
  echo "Test publishing ..."
fi

echo 'format code according to 80 line length, but would not save in repo'
dart format .

dart pub publish $DRY_RUN

git checkout .
