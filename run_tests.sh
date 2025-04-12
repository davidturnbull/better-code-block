#!/bin/bash

# Script to run Vader tests for better-fenced-code-block vim plugin
# Usage: ./run_tests.sh [test_file] [options]
#   If test_file is not provided, all tests will be run
#   Options:
#     -v, --verbose: Run tests with verbose output

# Set script to exit on error
set -e
cd better-code-blocks

# Check if Vader.vim exists
if [ ! -d "../vader.vim" ]; then
  echo "Vader.vim not found. Cloning it now..."
  git clone https://github.com/junegunn/vader.vim.git ../vader.vim
fi

# Parse arguments
VERBOSE=""
TEST_FILE="test/**/*.vader"

while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose)
      VERBOSE="-V1"
      shift
      ;;
    *)
      if [[ -f "$1" ]]; then
        TEST_FILE="$1"
      elif [[ "$1" == "all" ]]; then
        TEST_FILE="test/**/*.vader"
      else
        echo "Unknown argument: $1"
        echo "Usage: ./run_tests.sh [test_file] [options]"
        echo "  If test_file is not provided, all tests will be run"
        echo "  Options:"
        echo "    -v, --verbose: Run tests with verbose output"
        exit 1
      fi
      shift
      ;;
  esac
done

# Run tests using the same configuration as GitHub Actions
echo "Running tests: $TEST_FILE"
vim -Nu <(cat << VIMRC
set nocompatible
filetype off
set rtp+=../vader.vim
set rtp+=.
set rtp+=after
filetype plugin indent on
syntax enable
VIMRC
) -c "Vader! $TEST_FILE" $VERBOSE

echo "Tests completed!"