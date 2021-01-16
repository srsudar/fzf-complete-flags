# See https://github.com/junegunn/fzf/issues/2297 for original discussion.
#
# This generates a list of flags that have previously been used in history
# commands, trying to intelligently parse values for reuse on the prompt. For
# example, with the following history entry files (as shown on zsh):
#
# 1 foo --test --bar=val
# 2 foo -f 123 --bar val
#
# `_find_flags foo` should return:
#
# --test
# --bar
# --bar=val
# -f
# -f 123
# --bar val
_find_flags() {
  # $1 is passed to the function and should be the command.
  local match_prefix=$1
  fc -rl 1 | \
    # strip leading command number and trailing slashes. Trailing slashes
    # somehow confuse fzf or the do while. We use -E for portability with both
    # mac and unix.
      sed -E -e 's/^[[:space:]]*[0-9]*\*?[[:space:]]*//' -e 's/\\+$//' | \
      rg "^${match_prefix}" --color=never --no-line-number |
# Use gawk rather than awk here for portability. On mac this requires you to
# first install gawk, eg `brew install gawk`.
gawk -v match_prefix=${match_prefix} ' { for (i = 1; i <= NF; i++) {
  flag = ""
  is_value = ""
  maybe_value = ""

  if ($i ~ /^\\\\n/) {
    # Then this begins might be the first line after a continuation and begin
    # like "\\n--foo". We want this to be interpreted as if fresh, without a new
    # line.
    $i = gensub(/^\\\\n/, "", "g", $i)
  }

  if ($i ~ /^--?[a-zA-Z0-9]/) {
    # Then it looks like a flag.
    split($i, parts, "=")
    if (parts[2] != "") {
      # It is something like --flag=value
      flag = parts[1]
      is_value = parts[2]
    } else {
      # It is something like -f, and might be -f val.
      flag = $i
      maybe_value = $(i+1)
      if (maybe_value ~ /^\\\\n/) {
        # Then we probably consumed the next line in a line continuation.
        # Newlines in output will confuse a later process, so remove this.
        maybe_value = gensub(/^\\\\n/, "", "g", maybe_value)
      }
      if (maybe_value ~ /^--?[a-zA-Z0-9]/) {
        # Then we probably consumed another flag, eg `--foo` from
        # `--foo --bar=val`. Reset to empty string so we do not print that as an
        # option, as if `-foo` took the value `--bar=val`.
        maybe_value = ""
      }
    }

    # Colorize the part that we will not match in the output to make clear
    # we are matching only the leading flags.
    cmd_with_color = "\033[0;35m" $0 "\033[0m"

    # A note on the \xC2\xA0 strings here: we want a nbsp before the command so
    # that we can split easily and pull out the flag rather than the entire
    # line. This also allows us to tell fzf --nth and select only the first
    # column to search on. This is the nbsp notation that awk is able to output.
    # Fzf wants a \u00a0 format, which we use elsehwere, but note that these are
    # the same character.
    if (flag != "") {
      # Then we parsed a flag.

      # Print the flag itself.
      if (seen_arr[flag] != 1) {
        seen_arr[flag] = 1
        print flag "\xC2\xA0" cmd_with_color
      }

      if (is_value != "") {
        # The whole token is a valid value.
        if (seen_arr[$i] != 1) {
          seen_arr[$i] = 1
          print $i "\xC2\xA0" cmd_with_color
        }
      }
      if (maybe_value != "") {
        # We guessed at a value.
        output_with_guessed_value = flag " " maybe_value
        if (seen_arr[output_with_guessed_value] != 1) {
          seen_arr[output_with_guessed_value] = 1
          print flag " " maybe_value "\xC2\xA0 " cmd_with_color
        }
      }
    }
  } else {
    continue
  }
}
}'

}

# CTRL-Q - Paste the selected flags into the command line. Copied from CTRL-T
# bindings shown here:
# https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh
__flagsel() {
  # Normally, BUFFER is adequate. However, if we're in a line continutation, as
  # indicated by CONTEXT=cont, we want PREBUFFER:
  # https://linux.die.net/man/1/zshzle.
  local buffer_with_start_of_cmd=${BUFFER}
  if [[ $CONTEXT == "cont" ]]; then
    buffer_with_start_of_cmd=${PREBUFFER}
  fi
  # echo "bwsoc: |${buffer_with_start_of_cmd}|"
  # First we tr to remove new lines. and whitespace, which can trip us up on
  # multiline input like continuations. Then we use sed to replace white space
  # with space, which we will use as our delimiter to cut.
  local match_prefix=`echo ${buffer_with_start_of_cmd} | tr "\n" " " | sed -e "s/[[:space:]]\+/ /g" -e "s/\n/ /g" | cut -d ' ' -f 1`
  local cmd="_find_flags ${match_prefix}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  # Need to set this outside the surrounding string to enable $'' notation so
  # fzf is able to interpret the delimiter correctly.
  local delimiter_arg=$'--delimiter \u00a0'
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --prompt='${match_prefix}> ' ${delimiter_arg} --nth 1 --reverse --multi --ansi $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${item}" | awk -F '\xC2\xA0' '{ if (NF > 1) { printf "%s ", $1 } }'
  done
  local ret=$?
  echo
  return $ret
}

fzf-flag-widget() {
  LBUFFER="${LBUFFER}$(__flagsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-flag-widget
bindkey '^Q' fzf-flag-widget
