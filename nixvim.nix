{
  config,
  lib,
  pkgs,
  ...
}:
let
  nixvim.enable = false; #TODO: not optimal
in
{
  config = lib.mkIf nixvim.enable {
    programs.nixvim = {
      enable = false;
      vimAlias = true;
      #------------------

      colorschemes.gruvbox.enable = true;
      #extraConfigLua = ''
      #${builtins.readFile ./nvim/on_save.lua}
      #${builtins.readFile ./nvim/init.lua}
      #'';

      extraConfigLua = ''
        ${builtins.readFile ./nvim/init.lua}
        vim.api.nvim_set_keymap('n', '<leader>k', 'gcc', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('v', '<leader>k', 'gc', { noremap = true, silent = true })
      '';
      clipboard.register = "unnamedplus";
      clipboard.providers.xsel.enable = true;
      plugins.conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nix-fmt-formatter" ];
          };
          log_level = "warn";
          notify_on_error = false;
          notify_no_formatters = false;
          formatters = {
            nix-fmt-formatter = {
              command = lib.getExe pkgs.nixfmt-rfc-style;

            };
          };
        };

      };
      plugins.comment = {
        enable = true;
        settings = {
          mappings = {
            basic = true;
            extra = false;
          };

          toggler = {
            line = "gcc"; # Key mapping for toggling comments
            block = "gbc"; # Key mapping for block comments (optional)
          };
          opleader = {
            line = "gc"; # Key mapping for operator-pending mode
            block = "gb"; # Key mapping for operator-pending block comments (optional)
          };
        };
      };
      plugins.lsp = {
        enable = true;
        servers = {
          lua_ls.enable = true;
          nixd.enable = true;
          typos_lsp = {
            enable = true;
            extraOptions.init_options.diagnosticSeverity = "Hint";
          };
        };
        keymaps = {
          lspBuf = {
            "<leader>la" = {
              action = "code_action";
              desc = "LSP code action";
            };

            gd = {
              action = "definition";
              desc = "Go to definition";
            };

            gI = {
              action = "implementation";
              desc = "Go to implementation";
            };

            gy = {
              action = "type_definition";
              desc = "Go to type definition";
            };

            K = {
              action = "hover";
              desc = "LSP hover";
            };
          };
        };
      };

      plugins.cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      extraPlugins = with pkgs.vimPlugins; [
        {
          plugin = vim-wakatime;
          #idk, how make it declarative way :shrug:
          #	config = '''';
        }
      ];
    };
  };
}
