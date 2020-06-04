### detect_program.sh -- Detect program and save its path

wlog()
{
    { printf "$@"; printf '\n'; } 1>&2
}

detect_which()
{
    ( IFS=':'
      for path_elt in ${PATH}; do
          wlog 'Debug: Looking for %s in %s' "$1" "${path_elt}"
          if [ -x "${path_elt}/$1" ]; then
              printf '%s' "${path_elt}/$1"
              exit 0
          fi
      done

      printf 'false'
      exit 1 )
}

detect_config()
{
    local program_path

    program_path=$(detect_which "$2")

    if [ "${program_path}" = 'false' ]; then
        wlog 'Debug: %s: Not found in PATH.' "$2"
        exit 1
    fi

    cat > "$1" <<EOF
path: "${program_path}"
EOF
}

wlog 'Debug: program: %s' "$2"
wlog 'Debug: output: %s' "$1"
wlog 'Debug: pwd: %s' "$(pwd)"

detect_config "$1" "$2"
