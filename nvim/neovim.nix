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
      configure = {
        customRC = ''
          lua <<EOF
          ${luaRc}
          EOF
        '';

        packages.myPlugins.start = with pkgs.vimPlugins; [
          nvim-treesitter
          (nvim-treesitter.withPlugins (
            parsers:
            builtins.attrValues {
              inherit (parsers)
                nix
                markdown
                markdown_inline
                lua
                vim
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
    };
}
