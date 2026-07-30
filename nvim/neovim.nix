{ pkgs, lib, ... }:
{

  # xdg.configFile."nvim/colors/dms.lua".text = ''
  #   ${builtins.readFile ./colors/dms.lua}
  # '';

  programs.neovim =
    let
      luaRc = ''
        ${builtins.readFile ./config.lua}
      '';
      base46-avengemedia = import ./base46-avengemedia.nix {
        inherit pkgs lib;
      };
    in
    {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      initLua = luaRc;
      plugins = with pkgs.vimPlugins; [
        base46-avengemedia
        neo-tree-nvim
        plenary-nvim
        nvim-web-devicons
        nui-nvim

        nvim-treesitter
        fzf-lua
        which-key-nvim
        comment-nvim
        (nvim-treesitter.withPlugins (
          parsers:
          builtins.attrValues {
            inherit (parsers)
              nix
              markdown
              markdown_inline
              lua
              vim
              python
              regex
              bash
              ;
          }
        ))
        friendly-snippets
        luasnip
        nvim-cmp
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-buffer
        cmp_luasnip
        cmp-path
        cmp-cmdline
        none-ls-nvim
        nvim-lspconfig
        nord-nvim
        noice-nvim
        lualine-nvim
        bufferline-nvim
        lspsaga-nvim
      ];

    };
}
