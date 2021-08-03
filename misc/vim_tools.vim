" writes @" to the temp la file
" then presses enter on the other tmux window
function LaSend()
  let c = getreg('"', 1, v:true)
  call writefile(c, "/tmp/la_tmp.lua")
  silent exec "!tmux send-keys -t 1 Enter"
endfunction

noremap <silent> <leader>e :yank<CR>:call LaSend()<CR>
inoremap <silent> <leader>e <C-o>:yank<CR><C-o>:call LaSend()<CR>
vnoremap <silent> <leader>e :yank<CR>:call LaSend()<CR>
