# fzf-complete-flags

This script uses [`fzf`](https://github.com/junegunn/fzf) to complete flags from
your history by typing `<c-q>`.

[![demo](https://asciinema.org/a/384954.svg)](https://asciinema.org/a/384954)

## Installation

This relies on `fzf`, so make sure you have that installed.

The script assumes that you have `gawk` and `rg` (i.e.
[`ripgrep`](https://github.com/BurntSushi/ripgrep)) installed and on your path.

Also, normally `<c-q>` is already bound to a command. It is the counterpart to
`<c-s>`, which I wouldn't be surprised if at some point you've accidentally
entered and then wondered why your terminal was frozen. I've disabled `<c-s>` by
putting this in my `zshrc`:

```zsh
stty -ixon
```

If you want to keep default `<c-q>` behavior, you'll need a different trigger.

After all the dependencies are out of the way, source `fzf-complete-flags.zsh`.
I have this block in my `zshrc`:

```zsh
# Make sure you clone this first on new installations:
# git clone https://github.com/srsudar/fzf-complete-flags ~/.zsh/fzf-complete-flags
if [ ! -f ~/.zsh/fzf-complete-flags/fzf-complete-flags.zsh ]; then
  echo "fzf-complete-flags.zsh not found--did you clone the repo?" >&2
else
  source ~/.zsh/fzf-complete-flags/fzf-complete-flags.zsh
fi
```

## Background

This began as an [issue](https://github.com/junegunn/fzf/issues/2297) on the
main `fzf` repo. This [blog
post](https://samsudar.com/code/2021/fzf-for-flag-completion/) describes what
the script does.
