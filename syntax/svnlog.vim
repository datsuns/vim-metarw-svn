let s:cpo_save = &cpo
set cpo&vim

syn match   svnLogRevisionSeparator /^-\+$/
syn match   svnLogDiffFileEntry     /^ \{3\}[M|A|D]/
syn region  svnLogFoldSyntax
      \ start=/^r[0-9]\+ |/
      \ contains = svnLogRevisionSeparator, svnLogDiffFileEntry
      \ end=/\------------------------------------------------------------------------$/
	    \ keepend
      \ fold

hi def link svnLogRevisionSeparator Special
hi def link svnLogDiffFileEntry		  ToDo

let &cpo = s:cpo_save
unlet s:cpo_save
