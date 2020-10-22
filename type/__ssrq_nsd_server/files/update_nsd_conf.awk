#!/usr/bin/awk -f

# Usage: awk -f update_nsd_conf.awk /etc/nsd/nsd.conf <diff

# WARNING: This code assumes a "sane" NSD config file, i.e. it adheres to the
#          common layout of options (only one option per line)

# This script reads a "diff" specification on stdin.
# It is of the form:
#
#  + TOP_LEVEL:option: value  (ensure the given value is one of the options)
#  = TOP_LEVEL:option: value  (ensure only one of "option" is present with "value")
#  - TOP_LEVEL:option: value? (remove either option with given value or if value is empty all options)

function comment_pos(line) {
	# returns the position in line at which the comment'\''s text starts
	# (0 if the line is not a comment)
	return match(line, /[ \t]*\#+[ \t]*/) ? (RSTART + RLENGTH) : 0
}

# NOTE: s starts with option name and colon, returns position of colon
function is_option(s) { return match(s, /^[a-z0-9-]+:/) ? (RLENGTH - 1) : 0 }

function comment_only_line(line) {
	# HACK: Accessing RSTART of other function
	return comment_pos(line) ? RSTART == 1 : 0
}
function empty_line(line) { return line ~ /^[ \t]*$/ }
function option_hint_line(line,    x) {
	x = comment_pos(line)
	return x && is_option(substr(line, x))
}
function get_option(line) {
	match(line, /[^ \t]/)
	line = substr(line, RSTART)
	return substr(line, 1, is_option(line))
}

function top_level_keyword(line) {
	if (match(line, /^[ \t]*(server|key|pattern|zone|remote-control|dnstap):/))
		return substr(line, RSTART, RLENGTH - 1)
	else
		return ""
}

# function is_quoted(value) { return (value ~ /^".*"$/) }
# function quote(value) { return "\"" value "\"" }
# function unquote(value) {
# 	return is_quoted(value) \
# 		? substr(value, 2, length(value) - 2) \
# 		: value
# }
function in_list(list, val,    idx) {
	idx = index(list, val)
	if (!idx)
		return 0
	else if (length(list) == length(val))
		# special case: only one element
		return idx == 1
	else if (idx == 1)
		return substr(list, length(val) + 1, 1) == SUBSEP \
			|| in_list(substr(list, length(val) + 2), val)
	else if (idx == (length(list) - length(val) + 1))
		return substr(list, length(list) - length(val), 1) == SUBSEP
	else
		return (substr(list, idx - 1, 1) == SUBSEP && substr(list, idx + length(val), 1) == SUBSEP) \
			|| in_list(substr(list, idx + length(val) + 2), val)
}

function join(arr, sep,    s) {
	s = arr[1]
	for (i = 2; i in arr; ++i)
		s = s sep arr[i]
	return s
}

function drop(list, val,    i, parts) {
	split(list, parts, SUBSEP)
	for (i = 1; i in parts; ++i)
		if (parts[i] == val)
			delete parts[i]
	return join(parts, SUBSEP)
}

function proc_diff_line(line, conf_set, conf_unset,    op, kwd, opt) {
	# Extract operation
	op = substr(line, 1, 1)
	sub(/^[+=-][ \t]*/, "", line)

	# Extract top-level keyword
	if (!top_level_keyword(line)) return 1
	kwd = substr(line, RSTART, RLENGTH - 1)
	line = substr(line, RSTART + RLENGTH)

	# We only support "singleton" sections
	if (kwd ~ /^(key|pattern|zone)$/)
		return 1

	# Extract option
	if (!is_option(line)) return 2
	opt = get_option(line)
	line = substr(line, length(opt) + 2)

	# Strip whitespace before value
	sub(/^[ \t]*/, "", line)

	# Process
	if (op == "=") {
		conf_set[kwd, opt] = line
		if ((kwd, opt) in conf_unset) return 3  # remove some and all? wat?!
		conf_unset[kwd, opt] = ""
	} else if (op == "+") {
		if ((kwd, opt) in conf_set)
			conf_set[kwd, opt] = conf_set[kwd, opt] SUBSEP line
		else
			conf_set[kwd, opt] = line
	} else if (op == "-") {
		if ((kwd, opt) in conf_unset) {
			if (!conf_unset[kwd, opt]) return 3  # remove all and some? wat?!
			conf_unset[kwd, opt] = conf_unset[kwd, opt] SUBSEP line
		} else {
			conf_unset[kwd, opt] = line
		}
	} else return 4
}

function print_rest_for(top_level,    i, k, p, values) {
	for (k in conf_set) {
		split(k, p, SUBSEP)
		if (p[1] == top_level) {
			split(conf_set[k], values, SUBSEP)
			for (i = 1; i in values; ++i)
				printf "\t%s: %s\n", p[2], values[i]

			delete conf_set[k]
		}
	}
}

BEGIN {
	FS = "\n"  # disable field splitting

	if (ARGC != 2) exit -1  # incorrect number of arguments

	# Loop over file twice
	ARGV[2] = ARGV[1]
	ARGC++

	# read the "diff" into the `conf` arrays
	split("", conf_set)
	split("", conf_unset)
	while (getline < "/dev/stdin") {
		if (empty_line($0)) continue  # ignore empty lines
		if (proc_diff_line($0, conf_set, conf_unset))
			exit 1
	}
}


NR == FNR {
	# first pass (collect "statistics")

	if (/^[ \t]*#*[ \t]*include:/) {
		# ignore
	} else if (option_hint_line($0)) {
		hinted_option = get_option(substr($0, comment_pos($0)))

		if (top_level_keyword(hinted_option ":")) {
			TOP_LEVEL = hinted_option
		} else {
			last_occ["#" TOP_LEVEL ":" hinted_option ":"] = FNR
		}
		last_occ[TOP_LEVEL ":"] = FNR
	} else if (top_level_keyword($0)) {
		TOP_LEVEL = top_level_keyword($0)
		last_occ[TOP_LEVEL ":"] = FNR
	} else {
		option = get_option($0)

		if (option) {
			last_occ[TOP_LEVEL ":" option ":"] = FNR
			last_occ[TOP_LEVEL ":"] = FNR
		}
	}

	next
}

# before second pass prepare hashes containing location information to be used
# in the second pass.
NR > FNR && FNR == 1 {
	# First we drop the locations of commented-out options if a non-commented
	# option is available. If a non-commented option is available, we will
	# append new config options there to have them all at one place.
	for (k in last_occ) {
		if (k ~ /^#/ && (substr(k, 2) in last_occ))
			delete last_occ[k]
	}

	# Reverse the option => line mapping. The line_map allows for easier lookups
	# in the second pass.
	# We only invert options, not top-level keywords because we can only have
	# one entry per line and there are likely conflicts with top-level keywords
	for (k in last_occ) {
		if (k !~ /^#?.*:.*:$/) continue
		line_map[last_occ[k]] = k
	}
}

# Second pass
{
	if (/^[ \t]*include:/ || empty_line($0) || comment_only_line($0)) {
		print
	} else if (top_level_keyword($0)) {
		TOP_LEVEL = top_level_keyword($0)
		print
	} else if (get_option($0)) {
		# This is an option line
		option = get_option($0)

		comment_start = comment_pos($0) ? RSTART : 0  # HACK
		if (comment_start) {
			comment = substr($0, comment_start)
			$0 = substr($0, 1, comment_start - 1)
		} else {
			comment = ""
		}

		value_start = index($0, option) + length(option) + 1
		value_start += match(substr($0, value_start), /[^ \t]/) - 1
		raw_value = substr($0, value_start)

		if ((TOP_LEVEL, option) in conf_unset) {
			if (conf_unset[TOP_LEVEL, option]) {
				# only unset some, so check
				if (!in_list(conf_unset[TOP_LEVEL, option], raw_value))
					printf "%s%s\n", $0, comment
			} else {
				# only set some, so check
				if (in_list(conf_set[TOP_LEVEL, option], raw_value)) {
					printf "%s%s\n", $0, comment

					conf_set[TOP_LEVEL, option] = drop( \
						conf_set[TOP_LEVEL, option], raw_value)
				}
			}
		} else {
			# "append-only
			printf "%s%s\n", $0, comment
		}
	}
}

line_map[FNR] {
	# we have the last occurrence of a (hinted) option here...
	tok = (line_map[FNR] ~ /^#/ ? substr(line_map[FNR], 2) : line_map[FNR])
	top_level = get_option(tok)
	option = get_option(substr(tok, length(top_level) + 2))

	split(conf_set[top_level, option], parts, SUBSEP)
	for (i = 1; i in parts; ++i)
		printf "\t%s: %s\n", option, parts[i]

	delete conf_set[top_level, option]
}

last_occ[TOP_LEVEL ":"] == FNR {
	for (k in conf_set) {
		if (index(k, TOP_LEVEL SUBSEP) == 1) {
			# Only inset newline if there is a rest
			printf "\n"
			break
		}
	}
	print_rest_for(TOP_LEVEL)
}

END {
	# Print the rest for which no "section" could be found in the input file
	for (k in conf_set) {
		split(k, parts, SUBSEP)
		if (!(parts[1] in missing_sections))
			missing_sections[parts[1]] = ""
	}

	for (top_level in missing_sections) {
		printf "\n%s:\n", top_level
		print_rest_for(top_level)
	}
}
