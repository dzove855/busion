#!/usr/local/bin/bash

# This script is used to copy content from a link into a file based on a comment section
# This can help to share the same function cross multiple files and generate a final file instead of having multiple files

SELF="${BASH_SOURCE[0]##*/}"
# shellcheck disable=SC2034
NAME="${SELF%.sh}"

OPTS="i:o:xh"
USAGE="Usage: $SELF [$OPTS]"

HELP="
$USAGE

    Options:
        -i      Inputfile
        -o      Outputfile
        -h      Help

    Example:
        Inputfile contains a comment:
            # Busion source url URL
        The comment will be replaced by the content of the downloaded URL
"

_quit(){
    local retCode="$1" msg="${*:2}"

    printf '%s \n' "$msg"
    exit "$retCode"
}

_clean(){ rm $tmpFile; }

while getopts "${OPTS}" arg; do
    case "${arg}" in
        i)
            inputFile="$OPTARG"
        ;;
        o)
            outputFile="$OPTARG"
        ;;
        h)
            _quit 0 "$HELP"
        ;;
        x)
            set -x
        ;;
        ?)
            _quit 1 "Invalid Argument: $USAGE"
        ;;
        *)
            _quit 1 "$USAGE"
        ;;
    esac
done
shift $((OPTIND - 1))

[[ -z "$inputFile" || ! -f "$inputFile" ]] && _quit 2 "$HELP"
[[ -z "$outputFile" ]] && _quit 2 "$HELP"

declare -A config

tmpFile="$(mktemp)"
trap '_clean' EXIT
while IFS= read -r line; do
    case "$line" in
        *"Busion source"*)
            read _ _ _ include content <<<"$line"
            for key in "${!config[@]}"; do
                content="${content//\$$key/${config[$key]}}"
            done
            case "$include" in
                url)
                    curl -s "$curlOpts" "${content}" || _quit 2 "Could not download $content"
                ;;
                file)
                    [[ -f "$content" ]] && \
                        printf '%s\n' "$(<$content)"
                ;;
            esac
            continue
        ;;
        *"Busion var"*)
            read _ _ _ var <<<"$line"
            IFS="=" read key value <<<"$var"
            config[$key]="$value"
            continue
        ;;
        *"Busion curlopt"*)
            [[ "$line" =~ .*curlopt[[:space:]](.*) ]] && \
                curlOpts="${BASH_REMATCH[1]}"
            continue
        ;;
    esac
        
    printf '%s\n' "$line"
done < $inputFile > $tmpFile

cp "$tmpFile" "$outputFile"
