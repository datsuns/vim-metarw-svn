"
" TODO
"   [ ]log中のファイル名によるdiff表示
"   [ ]log中にあるURLをbrowserで開く

let s:debug_log_path = 'svn.log'
let s:enable_local_logging = v:false
let s:iconv_encoding = 'utf-8'

function! s:log(list)
  if s:enable_local_logging == v:true
    call writefile(a:list, s:debug_log_path, 'a')
endif
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

function! s:parentdir(path)
  let param = split(a:path, '/')
  return join(param[0 : -2], '/') . '/'
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

function! s:fixpath(path)
  if s:isdir(a:path)
    return a:path
  else
    return a:path . '/'
  endif
endfunction

function! s:sort(i1, i2)
  return toupper(a:i1) > toupper(a:i2)
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
          \    'label': k . ': ' . s:fixpath(v),
          \    'fakepath': s:append(a:fakepath, s:fixpath(v))
          \ })
    call s:log(["    => " . result[-1]['label'] . ' , ' . result[-1]['fakepath']])
  endfor
  return ['browse', result]
endfunction

function! s:browse_directory(fakepath, rawpath)
  call s:log(['  dir ' . a:fakepath . ' (' . a:rawpath . ')'])
  let result = []
  let list = systemlist('svn ls ' . a:rawpath)

  call add(result, {
        \    'label': '..',
        \    'fakepath': s:parentdir(a:fakepath)
        \ })

  for e in sort(list, "s:sort")
    call add(result, {
          \    'label': ' ' . e,
          \    'fakepath': s:to_entry(a:fakepath) . '/' . e
          \ })
  endfor
  return ['browse', result]
endfunction

function! s:read_content(fakepath, rawpath)
  call s:log(['  raw(file) ' . a:rawpath])
  let content = system('svn cat ' . a:rawpath)
  call setline(2, split(iconv(content, s:iconv_encoding, &encoding), "\n"))
  return ['done', content]
endfunction

function! s:get_revision(start_lnum)
  let s = a:start_lnum
  while s > 0
    let now = getline(s)
    if now =~ "^r[0-9]\\+ "
      break
    endif
    let s = s - 1
  endwhile
  if s == 0
    return [v:false, ""]
  endif
  let rev = split(now, " ")[0]
  return [v:true, substitute(rev, "r", "", "g")]
endfunction

function! s:get_updated_fname_url()
  let fname_line = getline(line("."))
  let fname_raw = substitute(fname_line, "^ \\+\[M|A|D\] ", "", "g")
  let fname_full = g:metaraw_svn_repository_root . fname_raw
  return fname_full
endfunction

function! s:build_diff_cmd(revision)
  let current = a:revision
  let prev = current - "1"
  let fname_line = getline(line("."))
  let fname_raw = substitute(fname_line, "^ \\+\[M|A|D\] ", "", "g")
  let fname_full = g:metaraw_svn_repository_root . fname_raw
  return "svn --diff-cmd \"diff\" --extensions \"-y\" diff -r" . prev . ":" . current . " " . fname_full
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
    return s:read_content(a:fakepath, raw)
  endif
endfunction

function! metarw#svn#write(fakepath, line1, line2, append_p)
  call s:log(['write'])
endfunction

function! metarw#svn#enable_logging()
  let s:enable_local_logging = v:true
endfunction

function! metarw#svn#disable_logging()
  let s:enable_local_logging = v:false
endfunction

function! metarw#svn#switch_encoding(enc)
  let s:iconv_encoding = a:enc
endfunction

function! metarw#svn#show_log(fakepath)
  let raw = s:rawpath(a:fakepath)
  let content = system('svn log --verbose -l 10 ' . raw)
  tabnew
  call setline(1, "log for " . raw)
  call setline(2, split(iconv(content, s:iconv_encoding, &encoding), "\n"))
  setlocal readonly nomodified
  setlocal foldmethod=marker foldtext=metarw#svn#foldtext() foldcolumn=3
  execute ":f svnlog"
  "execute ":SVNLog " . raw
endfunction

function! metarw#svn#show_diff()
  let ret = s:get_revision(line("."))
  if ret[0] == v:false
    echo "NOT FOUND"
    return
  endif
  let url = s:get_updated_fname_url()
  let current = ret[1]
  let prev = current - "1"

  tabnew
  let left = system("svn cat -r " . current . " " . url)
  execute ":f " . url
  call setline(1, split(left, "\n"))
  setlocal readonly nomodified
  execute ":f " . current
  execute ":diffthis"
  execute ":vnew"
  let right = system("svn cat -r " . prev . " " . url)
  execute ":f " . url
  call setline(1, split(right, "\n"))
  setlocal readonly nomodified
  execute ":f " . prev
  execute ":diffthis"
endfunction

function! metarw#svn#foldtext()
  echo v:foldstart
endfunction

