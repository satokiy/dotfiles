" Plugin
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" 導入したいプラグインを以下に列挙
" Plugin '[Github Author]/[Github repo]' の形式で記入
" :BundleInstall を実行するとvim/bundle配下にinstallされる
Plugin 'VundleVim/Vundle.vim'
" tree表示
Plugin 'scrooloose/nerdtree'
" git diffを左に表示
Plugin 'airblade/vim-gitgutter'
" file finder. ctrl + p -> ctrl + jk
Plugin 'ctrlpvim/ctrlp.vim'
" (), {}などをうまく処理する
Plugin 'tpope/vim-surround'

call vundle#end()
filetype plugin indent on


"  設定
"文字コードをUFT-8に設定
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
" 入力中のコマンドをステータスに表示する
set showcmd
set backspace=indent,eol,start

" 見た目系
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore
" インデントはスマートインデント
set smartindent
set softtabstop=2
set shiftwidth=2
" ビープ音を可視化
set visualbell
" 括弧入力時の対応する括弧を表示
set showmatch
" ステータスラインを常に表示
set laststatus=2
" コマンドラインの補完
set wildmode=list:longest
" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk
" シンタックスハイライトの有効化
syntax enable
let g:netrw_liststyle = 3
noremap PP "0p

" 検索系
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索語をハイライト表示
set hlsearch
" :e のタブ補完
set nocompatible
set wildmenu
" ESC連打でハイライト解除
inoremap <silent> jj <ESC>
nnoremap <Esc><Esc> :nohlsearch<CR>
set fileformats=unix,dos,mac
set fileencodings=utf-8,sjis
" nnoremap ; :
" nnoremap : ;

" NERDTree shortcut
nnoremap <silent><C-e> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
" autocmd
autocmd QuickFixCmdPost *grep* cwindow
