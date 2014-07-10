function! metarw#svn#complete(arglead, cmdline, cursorpos)
endfunction

function! metarw#svn#read(fakepath)
  let result = []
  call add(result, {
        \ 'label': 'label',
        \ 'fakepath': 'fakepath'
        \ })
  return ['browse', result]
endfunction

function! metarw#svn#write(fakepath, line1, line2, append_p)
endfunction

