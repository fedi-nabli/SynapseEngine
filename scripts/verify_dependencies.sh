#!/bin/sh

if ! perl --version 2>&1 >/dev/null
then
  echo "Perl is not installed, trying to install it..."
else
  echo "Perl is installed"
  perl ./scripts/check_dependencies.pl
fi
