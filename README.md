
# tagabana.vim
Generate ctags into central location for git super-projects and submodules, vim 'setlocal' helper combined with .git/hooks.

## Features
- Tiny. [~30LoC](./plugin/tagabana.vim)
- [ctags generator] as automatic [custom git hooks]
- Vim helper to set `tags` with project's central tag file
- Fast! Caches the project-path per tab
- Easy to hack and change

## Installation
First, copy the [custom git hooks] to your template at `.git_template/hooks`:

	mkdir -p ~/.git_template/hooks
	cp contrib/hooks/* ~/.git_template/hooks

And set your `.gitconfig` (or `.config/git/config`) globally:

	git config --global init.templatedir '~/.git_template'

_Note:_ Git >=1.7.12 is in line with XDG, e.g. `.config/git/template`.

Then install this vim plugin using your favorite plugin manager, or copy
`tagabana.vim` to your `.vim/plugin/` directory and start hacking.

## Usage

### Git+ctags Work-flow
When you `git init`, your template hooks will be copied into the new repository.
You can manually copy them into an existing git project. These hooks will
generate the ctags files in your `$XDG_CACHE_HOME/vim/tags/` folder every time
you:
- Checkout ([post-checkout])
- Commit ([post-commit])
- Merge ([post-merge])
- Rebase ([post-rewrite])

These git hooks will execute the main [ctags generator] script.

### Ensure ~/.ctags Configuration
To set different ctags options, create yourself a `~/.ctags`, I've included an
example at [contrib/example.ctags]

### Vim work-flow
When you open Vim the plugin will try to detect the working-directory of the git
super-project or submodule, and tells Vim to use the generated ctags file in the
central location. This also happens after creating or reading a file. **Note:**
The plugin caches the tags location per-tab, so mixing different project files
in the same tab won't work as expected. You can easily change this behaviour to
act per-buffer by hacking on [tagabana.vim](./plugin/tagabana.vim).

## Customization

### Options

Options you can set in your `.vimrc` to overwrite default behaviour.

| Option                | Default                   | Description                |
|-----------------------|---------------------------|----------------------------|
| `g:tagabana_tags_dir` | $XDG_CACHE_HOME/vim/tags/ | Central directory for tags |
| `g:tagabana_match_submodule` | 0 | Match submodules as well? |

## Credits & Contribution

This plugin was developed by Rafael Bodill under the [MIT License][license]. Pull requests are welcome.

[contrib/example.ctags]: ./contrib/example.ctags
[post-checkout]: ./contrib/hooks/post-checkout
[post-commit]: ./contrib/hooks/post-commit
[post-merge]: ./contrib/hooks/post-merge
[post-rewrite]: ./contrib/hooks/post-rewrite
[ctags generator]: ./contrib/hooks/ctags
[custom git hooks]: ./contrib/hooks/
[license]: ./LICENSE
