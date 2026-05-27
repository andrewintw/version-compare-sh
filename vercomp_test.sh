#! /bin/sh

. ./vercomp.sh


test_version_compare() {
	local case_file="$1"

	if [ ! -f "$case_file" ]; then
		echo "ERROR: $case_file not found!"
		return 1
	fi

	local total=0 passed=0 failed=0
	echo "====================================================="
	echo " Reading $case_file line by line for verification..."
	echo "====================================================="

	while read -r v1 exp_op v2 || [ -n "$v1" ]; do
		[ -z "$v1" ] || [ "${v1#\#}" != "$v1" ] && continue

		total=$((total + 1))
		version_compare "$v1" "$v2"
		local ret=$?
		local actual_op=''

		case $ret in
			0) actual_op='=';;
			1) actual_op='>';;
			2) actual_op='<';;
		esac

		if [ "$actual_op" = "$exp_op" ]; then
			printf "[PASS] Case #%02d: %s %s %s\n" "$total" "$v1" "$actual_op" "$v2"
			passed=$((passed + 1))
		else
			printf "[FAIL] Case #%02d: Expected %s %s %s, but got actual: %s\n" "$total" "$v1" "$exp_op" "$v2" "$actual_op"
			failed=$((failed + 1))
		fi

	done < "$case_file"

	echo "====================================================="
	echo " TEST SUMMARY FROM FILE:"
	echo "   Total Cases : $total"
	echo "   Passed      : $passed"
	echo "   Failed      : $failed"
	echo "====================================================="

	[ $failed -eq 0 ] && return 0 || return 1
}

test_version_compare "$1"
