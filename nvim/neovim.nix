{ pkgs, ... }:
{
  programs.neovim =
    let
      luaRc = ''
        ${builtins.readFile ./config.lua}
      '';
    in
    {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      initLua = luaRc;
      plugins = with pkgs.vimPlugins; [
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
#       configure = {
#         customRC = ''
#           lua <<EOF
#           ${luaRc}
#           EOF
#         '';
#
#         packages.myPlugins.start = with pkgs.vimPlugins; [
#           # nvim-treesitter
#           fzf-lua
#           which-key-nvim
#           comment-nvim
#           (nvim-treesitter.withPlugins (
#             parsers:
#             builtins.attrValues {
#               inherit (parsers)
#                 nix
#                 markdown
#                 markdown_inline
#                 lua
#                 vim
#                 python
#                 regex
#                 bash
#                 ;
#             }
#           ))
#           friendly-snippets
#           luasnip
#           nvim-cmp
#           cmp-nvim-lsp
#           cmp-nvim-lua
#           cmp-buffer
#           cmp_luasnip
#           cmp-path
#           cmp-cmdline
#           none-ls-nvim
#           nvim-lspconfig
#           nord-nvim
#           noice-nvim
#           lualine-nvim
#           bufferline-nvim
#           lspsaga-nvim
#         ];
#       };
#     };
# }
