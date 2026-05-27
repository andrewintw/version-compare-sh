#!/bin/sh

version_compare() {
	# -------------------------------------------------------------------------
	# Compares two version strings (supports up to 4 digits: Major.Minor.Patch.Build).
	# Combines high efficiency with zero-fork process execution.
	#
	# Arguments:
	#   $1 - v_old (Current running version on the device)
	#   $2 - v_new (Target firmware version to flash)
	#
	# Return Codes:
	#   0 - Target version is EQUAL to current version (v_new == v_old) -> Do not upgrade
	#   1 - Target version is OLDER than current version (v_new < v_old) -> Block downgrade
	#   2 - Target version is NEWER than current version (v_new > v_old) -> Proceed to upgrade
	# -------------------------------------------------------------------------

	# Declare local variables to prevent global scope contamination.
	# Fallback to "0.0.0.0" if arguments are missing or empty.
	local v1="${1:-0.0.0.0}"
	local v2="${2:-0.0.0.0}"

	# Internal Field Separator (IFS) is set locally to '.' for string splitting.
	# Save old IFS to guarantee a full environment restore.
	local old_ifs="$IFS"
	local IFS='.'

	# Leverage shell-builtin parameter expansion via positional arguments ($1..$4).
	# This splits the string in memory without spawning external processes (like cut/sed).
	set -- $v1
	local v1_1=${1:-0} v1_2=${2:-0} v1_3=${3:-0} v1_4=${4:-0}

	# Reset positional arguments for the second version string.
	set -- $v2
	local v2_1=${1:-0} v2_2=${2:-0} v2_3=${3:-0} v2_4=${4:-0}

	# 100% Restore IFS to prevent environmental pollution
	IFS="$old_ifs"

	# Suffix Stripping Shield: Strip any alphabetical suffixes from left-to-right 
	# (e.g., transforming '1a' or '1-rc' safely into the integer '1').
	v1_1=${v1_1%%[!0-9]*} v1_2=${v1_2%%[!0-9]*} v1_3=${v1_3%%[!0-9]*} v1_4=${v1_4%%[!0-9]*}
	v2_1=${v2_1%%[!0-9]*} v2_2=${v2_2%%[!0-9]*} v2_3=${v2_3%%[!0-9]*} v2_4=${v2_4%%[!0-9]*}

	# Asymmetrical Padding Defense: Fallback to 0 if components are empty 
	# to ensure safe and flawless integer comparison within [ ] brackets.
	v1_1=${v1_1:-0} v1_2=${v1_2:-0} v1_3=${v1_3:-0} v1_4=${v1_4:-0}
	v2_1=${v2_1:-0} v2_2=${v2_2:-0} v2_3=${v2_3:-0} v2_4=${v2_4:-0}

	# 1. Compare Major digits
	if [ $v1_1 -lt $v2_1 ]; then return 2; fi  # v_old < v_new
	if [ $v1_1 -gt $v2_1 ]; then return 1; fi  # v_old > v_new

	# 2. Compare Minor digits
	if [ $v1_2 -lt $v2_2 ]; then return 2; fi  # v_old < v_new
	if [ $v1_2 -gt $v2_2 ]; then return 1; fi  # v_old > v_new

	# 3. Compare Patch digits
	if [ $v1_3 -lt $v2_3 ]; then return 2; fi  # v_old < v_new
	if [ $v1_3 -gt $v2_3 ]; then return 1; fi  # v_old > v_new

	# 4. Compare Build digits
	if [ $v1_4 -lt $v2_4 ]; then return 2; fi  # v_old < v_new
	if [ $v1_4 -gt $v2_4 ]; then return 1; fi  # v_old > v_new

	# Perfect alignment across all components (v_new == v_old)
	return 0
}