# fzf-complete-flags

This script shows how to complete flags from your history by typing `<c-q>`.
I originally had this as a
[gist](https://gist.github.com/srsudar/a3b5ce33294c810ac7d5be2af7e8af35), but
it will be easier for people to submit improvements via pull requests to a full
repo.

[![demo](https://asciinema.org/a/384954.svg)](https://asciinema.org/a/384954)

## Installation

You'll need to source the `fzf-complete-flags.zsh` file. I have this block in my
`zshrc`:

```zsh
# Make sure you clone this first on new installations:
# git clone https://github.com/srsudar/fzf-complete-flags ~/.zsh/fzf-complete-flags
if [ ! -f ~/.zsh/fzf-complete-flags/fzf-complete-flags.zsh ]; then
  echo "fzf-complete-flags.zsh not found--did you clone the repo?" >&2
else
  source ~/.zsh/fzf-complete-flags/fzf-complete-flags.zsh
fi
```

It assumes that you have `gawk` and `rg` (i.e.
[`ripgrep`](https://github.com/BurntSushi/ripgrep)) installed and on your path.

Also, normally `<c-q>` is already bound to a command. It is the counterpart to
`<c-s>`, which I wouldn't be surprised if at some point you've accidentally
entered and then wondered why your terminal was frozen. I've disabled `<c-s>` by
putting this in my `zshrc`:

```zsh
stty -ixon
```

If you want to keep default `<c-q>` behavior, you'll need a different trigger.
