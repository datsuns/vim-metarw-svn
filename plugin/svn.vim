"command! -nargs=0 SvnExplorerOpen call metarw#svn#read("hello")

"nnoremap <buffer> <Return>  SvnExplorerOpen()<Return>
"nnoremap <buffer> <C-m>  SvnExplorerOpen()<Return>
"nmap <buffer> <Return>  SvnExplorerOpen()<Return>
"nmap <buffer> <C-m>  SvnExplorerOpen()<Return>
"nmap <silent> <Plug>(metarw-open-here)
"  \ :<C-u>call <SID>SvnExplorerOpen()<Return>

command! -nargs=0 SvnExplorerEnableLogging call metarw#svn#enable_logging()
command! -nargs=0 SvnExplorerDisableLogging call metarw#svn#disable_logging()
command! -nargs=0 SvnExplorerSwitchEncoding call metarw#svn#switch_encoding('cp932')
command! -nargs=0 SvnExplorerShowLog call metarw#svn#show_log(buffer_name("%"))
command! -nargs=0 SvnExplorerShowDiff call metarw#svn#show_diff()
nmap <Space>sl :SvnExplorerShowLog<CR>
nmap <Space>sd :SvnExplorerShowDiff<CR>

