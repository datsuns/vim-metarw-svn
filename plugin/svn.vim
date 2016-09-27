"command! -nargs=0 SvnExplorerOpen call metarw#svn#read("hello")

"nnoremap <buffer> <Return>  SvnExplorerOpen()<Return>
"nnoremap <buffer> <C-m>  SvnExplorerOpen()<Return>
"nmap <buffer> <Return>  SvnExplorerOpen()<Return>
"nmap <buffer> <C-m>  SvnExplorerOpen()<Return>
"nmap <silent> <Plug>(metarw-open-here)
"  \ :<C-u>call <SID>SvnExplorerOpen()<Return>

