#!/usr/bin/awk -f

# WARNING: This code assumes a "sane" NSD config file, i.e. it adheres to the
#          common layout of options (only one option per line)

function comment_pos(line) {
	# returns the position in line at which the comment'\''s text starts
	# (0 if the line is not a comment)
	return match(line, /[ \t]*\#+[ \t]*/) ? (RSTART + RLENGTH) : 0
}

# NOTE: s starts with option name and colon, returns position of colon
function is_option(s) { return match(s, /^[a-z0-9-]+:/) ? RLENGTH : 0 }

function comment_only_line(line) {
	# HACK: Accessing RSTART
	return comment_pos(line) ? RSTART == 1 : 0
}
function empty_line(line) { return line ~ /^[ \t]*$/ }
function option_hint_line(line,    x) {
	x = comment_pos(line)
	return x && is_option(substr(line, x))
}

function top_level_keyword(line) {
	if (match(line, /^[ \t]*(server|key|pattern|zone|remote-control):/))
		return substr(line, RSTART, RLENGTH - 1)
	else
		return ""
}

function proc_diff_line(line, conf_set, conf_unset,    op, kwd, opt) {
	# Extract operation
	op = substr(line, 1, 1)
	sub(/^[+-][ \t]*/, "", line)

	# Extract top-level keyword
	if (!top_level_keyword(line)) return 1
	kwd = substr(line, RSTART, RLENGTH - 1)
	line = substr(line, RSTART + RLENGTH)

	# Extract option
	if (!is_option(line)) return 2
	opt = substr(line, 1, index(line, ":") - 1)

	# Extract value
	line = substr(line, length(opt) + 2)
	sub(/^[ \t]*/, "", line)

	# Process
	if (op == "+")
		conf_set[kwd, opt] = line
	else if (op == "-")
		conf_unset[kwd, opt] = ""
	else
		return 3
}

function print_rest_for(kwd,    k, p) {
	for (k in conf_set) {
		split(k, p, SUBSEP)
		if (p[1] == TOP_LEVEL) {
			printf "\t%s: %s\n", p[2], conf_set[k]

			delete conf_set[k]
			conf_unset[k] = ""
		}
	}
}

BEGIN {
	FS = "\n"  # disable field splitting

	# read the "diff" into the `conf` array
	split("", conf_set)
	split("", conf_unset)
	while (getline < "/dev/stdin") {
		if (proc_diff_line($0, conf_set, conf_unset))
			exit 1
	}
}

/^[ \t]*include:/ {
	# Ignore includes here
	print
	next
}

empty_line($0) || comment_only_line($0) {
	# Leave empty or comment lines alone
	print

	if (option_hint_line($0)) {
		x = substr($0, comment_pos($0))
		hinted_option = substr(x, 1, is_option(x) - 1)

		if ((TOP_LEVEL, hinted_option) in conf_set) {
			printf "%s%s: %s\n",
				substr($0, 1, index($0, "#") - 1),
				hinted_option,
				conf_set[TOP_LEVEL, hinted_option]

			delete conf_set[TOP_LEVEL, hinted_option]
			conf_unset[TOP_LEVEL, hinted_option] = ""
		}
	}

	next
}

top_level_keyword($0) {
	# Print rest of should options ...
	print_rest_for(TOP_LEVEL)

	TOP_LEVEL = top_level_keyword($0)
	print
	next
}

{
	comment_start = comment_pos($0)
	if (comment_start) {
		comment = substr($0, comment_start)
		$0 = substr($0, 1, RSTART - 1)  # HACK
	} else {
		comment = ""
	}

	if (match($0, /: /)) {
		option = substr($0, 1, RSTART - 1)
		sub(/^[ \t]*/, "", option)

		value_start = (RSTART + RLENGTH)
		value = substr($0, value_start)

		quoted = (value ~ /^".*"$/)
		if (quoted)
			value = substr(value, 2, length(value) - 2)
	} else {
		# Dafuq is this line??
		print "DAFUQ!!!!!11???"
		exit 2
	}

	if ((TOP_LEVEL, option) in conf_set) {
		value = conf_set[TOP_LEVEL, option]
		printf "%s%s%s\n",
			substr($0, 1, value_start - 1),
			(quoted ? "\"" value "\"" : value),
			comment

		# Move option to unset array to delete all further occurrences
		delete conf_set[TOP_LEVEL, option]
		conf_unset[TOP_LEVEL, option] = ""
	} else if ((TOP_LEVEL, option) in conf_unset) {
		next
	} else {
		printf "%s%s\n", $0, comment
	}
}

END {
	if (TOP_LEVEL) print_rest_for(TOP_LEVEL)
}
