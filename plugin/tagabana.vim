" tagabana - Manages central tag files location per git repository
" Maintainer:  Rafael Bodill <justrafi at gmail dot com>
" Version:     0.9
" License:     MIT License (c) 2014 Rafael Bodill
" Manual:      Read ":help tagabana"
"--------------------------------------------------------------------

" Ensure Loading {{{1
if exists('g:loaded_tagabana') || &cp
	finish
endif
let g:loaded_tagabana = 1

" Configuration {{{1

" Central tag directory
if ! exists('g:tagabana_tags_dir')
	let g:tagabana_tags_dir = $XDG_CACHE_HOME.'/vim/tags/'
else
	" Append a forward-slash if missing
	if g:tagabana_tags_dir !~ '/$'
		let g:tagabana_tags_dir .= '/'
	endif
endif

" Match submodules as well?
if ! exists('g:tagabana_match_submodule')
	let g:tagabana_match_submodule = 0
endif

" Functions {{{1

" Append to buffer's `tags` setting the central tags hash
" for this Git super-project or submodule.
function! tagabana#setlocal_tags()
	" Use cached per-tab values if cwd hasn't changed.
	if ! exists('t:worktree_hash') || ! (exists('t:worktree') && t:worktree == getcwd())
		" Finds the current or parent project dir and hashes it
		" Caches results per-tab, meaning that mixing different project files in the
		" same tab won't work as expected. You can change t: => b: and remove the
		" getcwd check if you want to tweak it that way.
		let t:worktree = s:find_git_repo_or_submodule()
		let t:worktree_hash = g:TagabanaHash(t:worktree)
	endif

	" Append the central tag path to Vim's tags setting.
	execute 'setlocal tags+='.g:tagabana_tags_dir.t:worktree_hash
endfunction

" Finds the Git super-project or submodule directory.
function! s:find_git_repo_or_submodule()
	let cwd = getcwd()
	let parent = ''
	" Look for a .git folder, traverse parents if needed
	if ! isdirectory('.git')
		if g:tagabana_match_submodule
			if ! filereadable('.git')
				" Look upwards (at parents) for a file or dir named '.git':
				" First lookup for a .git file, symbolizing a git submodule
				let parent = substitute(findfile('.git', '.;'), '/.git', '', '')
				" If found, use it instead of cwd
				if parent != ''
					let cwd = parent
				endif
			else
				let parent = cwd
			endif
		endif
		if parent == ''
			" Lookup for a .git folder, symbolizing a git repo
			let parent = substitute(finddir('.git', '.;'), '/.git', '', '')
			" If found, use it instead of cwd
			if parent != ''
				let cwd = parent
			endif
		endif
	endif
	return cwd
endfunction

" Hashes a path string
" Credits: https://github.com/Shougo
function! g:TagabanaHash(str)
	" Hash the project directory
	if len(a:str) < 150
		" Just replacing directory separators if path is
		" less than 150 characters.
		let hash = substitute(substitute(
					\ a:str, ':', '=-', 'g'), '[/\\\ ]', '=+', 'g')
	elseif executable('sha256sum')
		" Use SHA256 for long paths. Use the command line executable and not Vim's
		" internal sha256() function to stay compatible with the bash 'ctags' hook
		" script that generates these files.
		let hash = substitute(
					\ system("printf '".a:str."' | sha256sum"),
					\ '\s\+\-.*$', '', '')
	else
		" Simple hash when sha256sum isn't available
		let sum = 0
		for i in range(len(a:str))
			let sum += char2nr(a:str[i]) * (i + 1)
		endfor
		let hash = printf('%x', sum)
	endif

	return hash
endfunction

" Auto-commands {{{1

augroup tagabana
	" setlocal tags to central path hash on these events:
	autocmd VimEnter,BufNewFile,BufReadPost * call tagabana#setlocal_tags()
augroup END

" }}}
" vim: set ts=2 sw=2 tw=80 noet :
