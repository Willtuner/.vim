"ȥ��vi��һ����"
set nocompatible
"������������ɼ�
set laststatus=2
"�ر��Զ�����
set nobackup
"�رս����ļ�
set noswapfile
"���ÿ�������
set incsearch
"������������������1000��
set history=1000
"��������ƥ��
set showmatch
"�����к�"
set nu
"��������к�
set relativenumber
"�������
set mouse=a
"Vim��Ĭ�ϼĴ�����ϵͳ�����干��
set clipboard+=unnamed
" ��Tab�Զ�ת���ɿո�
set expandtab
" ����tab���Ŀ��
set tabstop=2
"�﷨����
syntax on
"����������"
set hlsearch
"ͻ����ʾ��ǰ��"
"set cursorline
"ͻ����ʾ��ǰ��" 
"set cursorcolumn
"-------------------------------------------------------------------------------------------"
"��F5����python"
map <F5> :Autopep8<CR> :w<CR> :call RunPython()<CR>
function RunPython()
  let mp = &makeprg
  let ef = &errorformat
  let exeFile = expand("%:t")
  setlocal makeprg=python\ -u
  set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
  silent make %
  copen
  let &makeprg = mp
  let &errorformat = ef
endfunction