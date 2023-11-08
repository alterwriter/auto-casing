#!/bin/bash

PREFIX=""
PATHFILES=""

while (( "$#" )); do
  case "$1" in
    --prefix=*)
    PREFIX="${1#*=}"
    shift
    ;;
    --path=*)
    PATHFILES="${1#*=}"
    shift 
    ;;
    *) 
    echo "Invalid option: $1" >&2
    exit 1
    ;;
esac
done

if [ -z "$PREFIX" ] || [ -z "$PATHFILES" ]; then
  echo "Both --prefix and --path arguments are required."
  exit 1
fi

for file in $PATHFILES; do
  if [[ "$file" == *.json ]]; then
    python3 -c "import sys, json; json_obj=json.load(sys.stdin); json_obj['$PREFIX'] = ' '.join(word[0].upper() + word[1:] for word in json_obj['$PREFIX'].split(' ')); print(json.dumps(json_obj, indent=2))" < $file > temp && mv temp $file
  else
    while IFS= read -r line; do
      if [[ "$line" =~ ^$PREFIX ]]; then
        new_line="$(echo $line | awk -v RS=[[:space:]] '{print toupper(substr($0, 1, 1)) substr($0, 2)}' ORS=' ')"
        echo "${new_line}"
      else
        echo "${line}"
      fi
    done < "${file}" >${file}.bak && mv ${file}.bak "${file}"
  fi
done