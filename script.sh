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
  echo "    - Use '--' to separate options from filenames starting with '-'."
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

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s)
      show_sizes=true
      ;;
    -S)
      show_total_only=true
      ;;
    --usage)
      usage
      exit 0
      ;;
    --help)
      help
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        files+=("$1")
        shift
      done
      break
      ;;
    -* )
      error_unsupported_option "$1"
      ;;
    * )
      files+=("$1")
      ;;
  esac
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
