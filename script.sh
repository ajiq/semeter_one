#!/bin/bash

# Function to print usage
usage() {
  echo "Usage: $0 [options] [--] file1 file2 ..."
  echo "Options:"
  echo "    -s     Show size of each file and total size."
  echo "    -S     Show only total size."
  echo "    --usage Display short usage guide."
  echo "    --help  Display detailed help."
}

# Function to print help
help() {
  usage
  echo "\nThis script provides file size information."
  echo "\nNotes:"
  echo "    - Supports filenames with spaces and special characters."
}

# Error handling
error_unsupported_option() {
  echo "Error: Unsupported option $1." >&2
  exit 2
}

error_file_not_found() {
  echo "Error: File $1 does not exist." >&2
}

# Initialize variables
show_sizes=false
show_total_only=false
files=()
total_size=0
exit_code=0
found_double_dash=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  if [[ "$1" == "--" ]]; then
    found_double_dash=true
    shift
    continue
  fi

  if [[ $found_double_dash == true ]]; then
    # After '--', treat everything as filenames, including options
    files+=("$1")
  else
    case "$1" in
      -s)
        show_sizes=true
        ;;
      -S)
        if [[ $found_double_dash == true ]]; then
          files+=("$1")  # Treat -S as a filename after '--'
        else
          show_total_only=true
        fi
        ;;
      --usage)
        usage
        exit 0
        ;;
      --help)
        help
        exit 0
        ;;
      -* )
        if [[ $found_double_dash == true ]]; then
          files+=("$1")  # Treat all options as filenames after '--'
        else
          error_unsupported_option "$1"
        fi
        ;;
      * )
        files+=("$1")
        ;;
    esac
  fi
  shift
done

# Check if no files provided
if [[ ${#files[@]} -eq 0 ]]; then
  echo "Error: No files provided." >&2
  exit 2
fi

# Process each file
for file in "${files[@]}"; do
  if [[ -e "$file" ]]; then
    if stat -f%z -- "$file" &>/dev/null; then # macOS
      size=$(stat -f%z -- "$file")
    else
      size=$(stat -c%s -- "$file" 2>/dev/null) # Linux
    fi

    if [[ $? -ne 0 ]]; then
      error_file_not_found "$file"
      exit_code=1
    else
      total_size=$((total_size + size))
      if [[ $show_total_only == false ]]; then
        echo "$size $file"
      fi
    fi
  else
    error_file_not_found "$file"
    exit_code=1
  fi
done

# Print total size if requested
if [[ $show_total_only == true ]]; then
  echo "Total size: $total_size"
elif [[ $show_sizes == true ]]; then
  echo "Total size: $total_size"
fi

exit $exit_code
