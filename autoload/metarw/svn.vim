let s:debug_log_path = 'svn.log'

function! s:log(list)
  call writefile(a:list, s:debug_log_path, 'a')
endfunction

function! s:rawpath(path)
  "remove the top of 'svn:'
  if a:path[0:4] == 'svn:/'
    return a:path[5 : -1]
  elseif a:path[0:3] == 'svn:'
    return a:path[4 : -1]
  else
    return a:path
  endif
endfunction

function! s:to_entry(path)
  if s:isdir(s:rawpath(a:path))
    return a:path[ : -2]
  else
    return a:path
  endif
endfunction

function! s:last(path)
  return a:path[-1 : -1]
endfunction

function! s:append(parent, child)
  if s:isdir(a:parent)
    return a:parent . a:child
  else
    return a:parent . '/' . a:child
  endif
endfunction

function! s:uppath(path)
  let param = split(a:path, '/')
  return join(param[0 : -2], '/')
endfunction

function! s:basename(path)
  let param = split(a:path, '/')
  return param[-1]
endfunction

function! s:isroot(path)
  return a:path == ''
endfunction

function! s:isdir(path)
  let result = v:false
  if s:last(a:path) == '/'
    let result = v:true
  endif
  return result
endfunction

" take a long time...
function! s:isdir_not_used(path)
  let raw = s:rawpath(a:path)
  call s:log([' directory ? ' . raw])
  let kind = systemlist('svn info --show-item kind ' . raw)
  if kind[0] == 'dir'
    call s:log(['   -> yes'])
    return v:true
  else
    call s:log(['   -> no'])
    return v:false
  endif
endfunction

function! s:choose_repository(fakepath)
  call s:log(["choose: " . a:fakepath])
  let result = []
  for [k, v] in items(g:metaraw_svn_repository_list)
    call add(result, {
          \    'label': k . ': ' . v,
          \    'fakepath': s:append(a:fakepath, v)
          \ })
    call s:log(["    => " . result[-1]['label'] . ' , ' . result[-1]['fakepath']])
  endfor
  return ['browse', result]
endfunction

function! s:browse_directory(fakepath, rawpath)
  call s:log(['  dir' . a:fakepath])
  let result = []
  let list = systemlist('svn ls ' . a:rawpath)

  call add(result, {
        \    'label': '..',
        \    'fakepath': s:uppath(a:fakepath)
        \ })

  for e in list
    call add(result, {
          \    'label': ' ' . e,
          \    'fakepath': s:to_entry(a:fakepath) . '/' . e
          \ })
  endfor
  return ['browse', result]
endfunction

function! s:read_content(fakepath)
  let raw = s:rawpath(a:fakepath)
  call s:log(['  raw(file)' . raw])
  let content = system('svn cat ' . raw)
  call setline(2, split(iconv(content, 'utf-8', &encoding), "\n"))
  return ['done', content]
endfunction


function! metarw#svn#complete(arglead, cmdline, cursorpos)
  call s:log(['complete'])
endfunction

function! metarw#svn#read(fakepath)
  call s:log(['read ' . a:fakepath])
  let raw = s:rawpath(a:fakepath)
  if s:isroot(raw)
    return s:choose_repository(a:fakepath)
  elseif s:isdir(raw)
    return s:browse_directory(a:fakepath, raw)
  else
    return s:read_content(a:fakepath)
  endif
endfunction

function! metarw#svn#write(fakepath, line1, line2, append_p)
  call s:log(['write'])
endfunction

