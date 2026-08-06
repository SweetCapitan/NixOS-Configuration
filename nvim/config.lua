-------------------
-- Basic options --
-------------------
local options = {
  clipboard = "unnamedplus",
  mouse = "a",
  undofile = true,
  ignorecase = true,
  showmode = false,
  showtabline = 2,
  smartindent = true,
  autoindent = true,
  swapfile = false,
  hidden = true, --default on
  expandtab = true,
  cmdheight = 1,
  shiftwidth = 2,    --insert 2 spaces for each indentation
  tabstop = 2,       --insert 2 spaces for a tab
  cursorline = true, --Highlight the line where the cursor is located
  cursorcolumn = false,
  number = true,
  numberwidth = 4,
  relativenumber = true,
  scrolloff = 8,
  updatetime = 50 -- faster completion (4000ms default)
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

----------------
-- nord theme --
----------------
-- vim.g.nord_contrast = true
-- vim.g.nord_borders = true
-- vim.g.nord_disable_background = true
-- vim.g.nord_italic = true
-- vim.g.nord_uniform_diff_background = true
-- vim.g.nord_enable_sidebar_background = true
-- vim.g.nord_bold = true
-- vim.g.nord_cursorline_transparent = false
-- require("nord").set()


-----------------
-- About noice --
-----------------
require("noice").setup(
  {
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
            { find = "%d fewer lines" },
            { find = "%d more lines" }
          }
        },
        opts = { skip = true }
      }
    }
  }
)

require("neo-tree").setup({
  window = { width = 30 },
  filesystem = {
    filtered_items = { visible = true },
    follow_current_file = { enabled = true },
  }
})

-- Настройка горячей клавиши Alt + 1
vim.keymap.set('n', '<A-1>', ':Neotree toggle left<CR>', { silent = true })


vim.filetype.add({
  extension = {
    zig = 'zig',
    zon = 'zig',     -- .zon файлы используют тот же синтаксис комментирования
  },
})

-- 2. Инициализируем Comment.nvim с хуком под стандарты Zig
require('Comment').setup({
  pre_hook = function(ctx)
    -- Если это файл Zig, принудительно задаем только строчные комментарии
    if vim.bo.filetype == 'zig' then
      return ctx.ctype == require('Comment.utils').ctype.linewise and '// %s' or nil
    end
  end,
})

require("which-key").setup({
  delay = 500,
  icons = {
    mapping = true
  },
  spec = {
    { "<leader>s",  desc = "Save file" },
    { "<leader>q",  desc = "Quit" },
    { "<leader>v",  desc = "Vertical split" },
    { "<leader>ca", desc = "Code action" },
    { "<leader>ci", desc = "Incoming calls" },
    { "<leader>co", desc = "Outgoing calls" },
    { "<leader>f",  desc = "Format file" },
    { "<leader>ff", desc = "Apply fixes" },
    { "<leader>p",  desc = "Find files" },
    { "<leader>g",  desc = "Live grep" },
    { "<leader>b",  desc = "Buffers" },
    { "<leader>r",  desc = "Recent files" },
    { "<leader>fw", desc = "Find word under cursor" },
    { "<leader>fs", desc = "Workspace symbols" },
    { "<leader>ls", desc = "Document symbols" },
    -- groups
    { "<leader>s",  group = "diagnostics" },
    { "<leader>sl", desc = "Show line diagnostics" },
    { "<leader>sc", desc = "Show cursor diagnostics" },
    { "<leader>sb", desc = "Show buffer diagnostics" },
  },
})

require("fzf-lua").setup({
  winopts = {
    height = 0.85,
    width = 0.80,
    preview = {
      layout = "vertical",
    }
  }
})

-- vim.cmd([[ colorscheme nord ]])
vim.cmd.colorscheme("dms")


-------------------
-- About lualine --
-------------------
require("lualine").setup(
  {
    options = {
      theme = "dms",
      globalstatus = true
    }
  }
)

----------------------
-- About bufferline --
----------------------
-- local highlights
-- highlights =
--     require("nord").bufferline.highlights(
--       {
--         italic = true,
--         bold = true
--       }
--     )
-- require("bufferline").setup(
--   {
--     highlights = highlights
--   }
-- )

----------------------
-- About treesitter --
----------------------

-- Настройка нового nvim-treesitter под NixOS
vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = function(event)
    local ft = vim.bo[event.buf].ft

    -- Проверяем, есть ли у Neovim скомпилированный парсер для этого языка (из Nix)
    local lang = vim.treesitter.language.get_lang(ft) or ft
    local has_parser = pcall(vim.treesitter.query.get, lang, "highlights")

    if has_parser then
      -- 1. Включаем нативную подсветку синтаксиса
      pcall(vim.treesitter.start, event.buf)

      -- 2. Включаем умные отступы из nvim-treesitter (вместо старого `indent = { enable = true }`)
      local ts_ok, _ = pcall(require, 'nvim-treesitter')
      if ts_ok then
        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      -- 3. Опционально: Включаем фолдинг (сворачивание кода) на базе Treesitter
      -- vim.wo.foldmethod = 'expr'
      -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
  end,
})

-- require('nvim-treesitter.configs').setup({
--   highlight = { enable = true },
--   indent    = { enable = true },
-- })

---------------
-- About cmp --
---------------
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end
local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

require("luasnip/loaders/from_vscode").lazy_load()

local kind_icons = {
  Text = "󰊄",
  Method = "",
  Function = "󰡱",
  Constructor = "",
  Field = "",
  Variable = "󱀍",
  Class = "",
  Interface = "",
  Module = "󰕳",
  Property = "",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = ""
}
-- find more here: https://www.nerdfonts.com/cheat-sheet
cmp.setup(
  {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body) -- For `luasnip` users.
      end
    },
    mapping = cmp.mapping.preset.insert(
      {
        ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
        ["<C-d>"] = cmp.mapping.scroll_docs(4),  -- Down
        -- C-b (back) C-f (forward) for snippet placeholder navigation.
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm(
          {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
          }
        ),
        ["<Tab>"] = cmp.mapping(
          function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end,
          { "i", "s" }
        ),
        ["<S-Tab>"] = cmp.mapping(
          function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
          { "i", "s" }
        )
      }
    ),
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
        vim_item.menu =
            ({
              path = "[Path]",
              nvim_lua = "[NVIM_LUA]",
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]"
            })[entry.source.name]
        return vim_item
      end
    },
    sources = {
      { name = "path" },
      { name = "nvim_lua" },
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" }
    },
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered()
    },
    experimental = {
      ghost_text = false,
      native_menu = false
    }
  }
)
cmp.setup.cmdline(
  ":",
  {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources(
      {
        { name = "path" }
      },
      {
        { name = "cmdline" }
      }
    )
  }
)

-----------------
-- LSP Support --
-----------------
-- Настраиваем параметры ZLS через новый встроенный механизм ядра Neovim
vim.lsp.config('zls', {
  cmd = { "zls" },
  settings = {
    zls = {
      enable_autofix = true,
      enable_snippets = true,
      warn_style = true,
      -- 1. Включаем поддержку подсказок со стороны сервера ZLS
      enable_inlay_hints = true,
      inlay_hints_show_variable_type_hints = true,
      inlay_hints_show_parameter_name_hints = true,
    },
  },
  -- 2. Включаем отображение подсказок в Neovim при подключении сервера к буферу
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
})

-- Активируем ZLS
vim.lsp.enable('zls')

-- Автокоманда для форматирования
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.zig", "*.zon" },
  callback = function(ev)
    vim.lsp.buf.format({ bufnr = ev.buf, async = false })
  end,
})


-------------------
-- About none-ls --
-------------------
-- format(async)
local async_formatting = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.lsp.buf_request(
    bufnr,
    "textDocument/formatting",
    vim.lsp.util.make_formatting_params({}),
    function(err, res, ctx)
      if err then
        local err_msg = type(err) == "string" and err or err.message
        -- you can modify the log message / level (or ignore it completely)
        vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
        return
      end

      -- don't apply results if buffer is unloaded or has been modified
      if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
        return
      end

      if res then
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
        vim.api.nvim_buf_call(
          bufnr,
          function()
            vim.cmd("silent noautocmd update")
          end
        )
      end
    end
  )
end
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local lsp_formatting = function(bufnr)
  vim.lsp.buf.format(
    {
      filter = function(client)
        -- apply whatever logic you want (in this example, we'll only use null-ls)
        return client.name == "null-ls"
      end,
      bufnr = bufnr
    }
  )
end
---------------------
-- About lspconfig --
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

require("null-ls").setup({
  sources = {
    require("null-ls").builtins.formatting.nixfmt,
    require("null-ls").builtins.formatting.black,
    require("null-ls").builtins.formatting.isort,
  },
  debug = false,
  on_attach = function(client, bufnr)
    -- ИСПРАВЛЕНО: заменили точку на двоеточие
    if client:supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", { -- BufWritePre лучше, чтобы файл сохранялся уже красивым
        group = augroup,
        buffer = bufnr,
        callback = function()
          -- Современный нативный способ асинхронного форматирования при сохранении
          vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(c)
              -- Форматируем только через none-ls (null-ls), чтобы не было конфликтов с другими LSP
              return c.name == "null-ls"
            end
          })
        end,
      })
    end
  end,
})
---------------------
-- local nvim_lsp = require("lspconfig")

-- Add additional capabilities supported by nvim-cmp
-- nvim hasn't added foldingRange to default capabilities, users must add it manually
local capabilities = require("cmp_nvim_lsp").default_capabilities()
--capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

--Change diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
vim.diagnostic.config(
  {
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = false
  }
)

local on_attach = function(bufnr)
  vim.api.nvim_create_autocmd(
    "CursorHold",
    {
      buffer = bufnr,
      callback = function()
        if vim.api.nvim_get_mode().mode ~= 'n' then
          return
        end

        if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then
          return
        end

        local opts = {
          focusable = false,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border = "rounded",
          source = "always",
          prefix = " ",
          scope = "line"
        }
        vim.diagnostic.open_float(bufnr, opts)
      end
    }
  )
end
vim.lsp.config.nixd =
{
  --on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }"
      },
      formatting = {
        command = { "nixfmt" }
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake "/home/dancho/Configurations").nixosConfigurations.nixos.options'
        },
        home_manager = {
          expr = [[
          (let
            flake = (builtins.getFlake "/home/dancho/Configurations");
          in flake.inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              {
                home.stateVersion = "24.05";
                home.username = "user";
                home.homeDirectory = "/home/user";
              }
              # Подключаем модуль из инпута dms вашего флейка
              flake.inputs.dms.homeModules.dank-material-shell
            ];
          }).options
        ]]
        }
      }
    }
  }
}
vim.lsp.enable("nixd")

vim.lsp.config.basedpyright = {
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true
      },
      inlay_hints_show_variable_type_hints = true,
      inlay_hints_show_parameter_name_hints = true,
      enable_inlay_hints = true,
    }
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
}
vim.lsp.enable("basedpyright")
vim.lsp.config.lua_ls = {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.expand('$VIMRUNTIME/lua/'),
          vim.fn.expand('$VIMRUNTIME/lua/lsp'),
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
}
vim.lsp.enable("lua_ls")

-------------------
-- About lspsaga --
-------------------
local colors, kind
colors = { normal_bg = "#3b4252" }
require("lspsaga").setup(
  {
    ui = {
      colors = colors,
      kind = kind,
      border = "single"
    },
    outline = {
      win_width = 25
    }
  }
)

-- Устанавливаем Leader на пробел
vim.g.mapleader = "\\"

-- Сохранить файл с помощью Leader + s
vim.api.nvim_set_keymap('n', '<Leader>s', ':w<CR>', { noremap = true, silent = true })

-- Закрыть текущий буфер с помощью Leader + q
vim.api.nvim_set_keymap('n', '<Leader>q', ':q<CR>', { noremap = true, silent = true })

-- Открыть новое окно с помощью Leader + v
vim.api.nvim_set_keymap('n', '<Leader>v', ':vsplit<CR>', { noremap = true, silent = true })

local keymap = vim.keymap.set

-- Lsp finder
-- Find the symbol definition, implementation, reference.
-- If there is no implementation, it will hide.
-- When you use action in finder like open, vsplit, then you can use <C-t> to jump back.
keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true, desc = "Lsp finder" })

-- Code action
keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true, desc = "Code action" })
keymap("v", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true, desc = "Code action" })

-- Rename
keymap("n", "gr", "<cmd>Lspsaga rename<CR>", { silent = true, desc = "Rename" })
-- Rename word in whole project
keymap("n", "gr", "<cmd>Lspsaga rename ++project<CR>", { silent = true, desc = "Rename in project" })

-- Peek definition
keymap("n", "gD", "<cmd>Lspsaga peek_definition<CR>", { silent = true, desc = "Peek definition" })

-- Go to definition
keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { silent = true, desc = "Go to definition" })

-- Show line diagnostics
keymap("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true, desc = "Show line diagnostics" })

-- Show cursor diagnostics
keymap("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true, desc = "Show cursor diagnostic" })

-- Show buffer diagnostics
keymap("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>", { silent = true, desc = "Show buffer diagnostic" })

-- Diagnostic jump prev
keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true, desc = "Diagnostic jump prev" })

-- Diagnostic jump next
keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true, desc = "Diagnostic jump next" })

-- Goto prev error
keymap(
  "n",
  "[E",
  function()
    require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end,
  { silent = true, desc = "Goto prev error" }
)

-- Goto next error
keymap(
  "n",
  "]E",
  function()
    require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
  end,
  { silent = true, desc = "Goto next error" }
)

-- Toggle outline
keymap("n", "ss", "<cmd>Lspsaga outline<CR>", { silent = true, desc = "Toggle outline" })

-- Hover doc
keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>", { silent = true, desc = "Hover doc" })

-- Incoming calls
keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>", { silent = true, desc = "Incoming calls" })

-- Outgoing calls
keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>", { silent = true, desc = "Outgoing calls" })

-- Float terminal
keymap("n", "<A-d>", "<cmd>Lspsaga term_toggle<CR>", { silent = true, desc = "Float terminal" })
keymap("t", "<A-d>", "<cmd>Lspsaga term_toggle<CR>", { silent = true, desc = "Float terminal" })
keymap("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, { silent = true, desc = "Format file via lsp" })

keymap("n", "<leader>p", "<cmd>FzfLua files<CR>", { silent = true, desc = "Find files" })
-- Поиск по содержимому (grep)
keymap("n", "<leader>g", "<cmd>FzfLua live_grep<CR>", { silent = true, desc = "Live grep" })
-- Поиск по открытым буферам
keymap("n", "<leader>b", "<cmd>FzfLua buffers<CR>", { silent = true, desc = "Buffers" })
-- Поиск по истории
keymap("n", "<leader>r", "<cmd>FzfLua oldfiles<CR>", { silent = true, desc = "Recent files" })
-- Поиск слова под курсором
keymap("n", "<leader>fw", "<cmd>FzfLua grep_cword<CR>", { silent = true, desc = "Find word under cursor" })
-- Поиск символов во всём проекте (функции, классы и т.д.)
keymap("n", "<leader>fs", "<cmd>FzfLua lsp_workspace_symbols<CR>", { silent = true, desc = "Workspace symbols" })
-- Поиск символов только в текущем файле
keymap("n", "<leader>ls", "<cmd>FzfLua lsp_document_symbols<CR>", { silent = true, desc = "Document symbols" })


vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name == 'nixd' then -- Или 'nil', в зависимости от LSP
      vim.keymap.set('n', '<leader>ff', vim.lsp.buf.code_action, {
        buffer = args.buf,
        desc = 'Apply available fixes'
      })
    end
  end
})

if not vim.g.dms_theme_watcher then
  vim.g.dms_theme_watcher = true

  local watcher = vim.uv.new_fs_event()
  local timer = vim.uv.new_timer()

  local theme_file = vim.fn.stdpath("config") .. "/colors/dms.lua"

  local function reload_theme()
    timer:stop()

    timer:start(
      200,
      0,
      vim.schedule_wrap(function()
        if vim.g.colors_name == "dms" then
          local base46 = require("base46")

          base46.theme_tables["dms"] = nil

          vim.cmd("colorscheme dms")

          vim.notify(
            "DMS theme reloaded",
            vim.log.levels.INFO
          )
        end
      end)
    )
  end

  watcher:start(theme_file, {}, reload_theme)
end
