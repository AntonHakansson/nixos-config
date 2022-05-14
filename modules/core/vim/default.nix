{ config, pkgs, ... }:
let
  base = user: {
    programs.zsh.shellAliases = {
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
    };
    programs.neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        # :ui
        onedark-nvim
        telescope-nvim
        telescope-fzf-native-nvim

        # :editor
        vim-surround

        # :completion
        which-key-nvim
        nvim-lspconfig
        nvim-treesitter

        # :lang
        vim-nix
      ];
      extraConfig = ''
        colorscheme onedark

        let mapleader = " "
        inoremap <C-c> <esc>

        set guicursor=
        set relativenumber
        set noerrorbells
        set tabstop=2 softtabstop=2
        set shiftwidth=2
        set expandtab
        set smartindent
        set clipboard+=unnamedplus

        " Doom Emacs bindings
        nnoremap <leader>wj <C-W>j
        nnoremap <leader>wk <C-W>k
        nnoremap <leader>wh <C-W>h
        nnoremap <leader>wl <C-W>l
        nnoremap <leader>ws <C-W>s
        nnoremap <leader>wv <C-W>v
        nnoremap <leader>wd <C-W>c

        nnoremap <leader><leader> :lua require('telescope.builtin').commands()<CR>
        nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
        nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
        nnoremap <Leader>pf :lua require('telescope.builtin').find_files()<CR>

        nnoremap <leader>pw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
        nnoremap <leader>pb :lua require('telescope.builtin').buffers()<CR>
        nnoremap <leader>bb :lua require('telescope.builtin').buffers()<CR>
        nnoremap <leader>vh :lua require('telescope.builtin').help_tags()<CR>

        nnoremap <Leader><CR> :so ~/.config/nvim/init.vim<CR>

        " Ignore files
        set wildignore+=*.pyc
        set wildignore+=*_build/*
        set wildignore+=**/coverage/*
        set wildignore+=**/node_modules/*
        set wildignore+=**/android/*
        set wildignore+=**/ios/*
        set wildignore+=**/.git/*
      '';
    };
    home.sessionVariables = {
      MANPAGER = "nvim +Man!";
    };
  };
in {
  config = {
    home-manager.users.root = { ... }: (base "root");
    home-manager.users.hakanssn = { ... }: (base "hakanssn");
  };
}
