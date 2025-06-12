vim.api.nvim_create_augroup("AutoFormat", {})

vim.api.nvim_create_autocmd(
    "BufWritePost",
    {
        pattern = "*.nix",
        group = "AutoFormat",
        callback = function()
            vim.cmd("!nixfmt %")            
            vim.cmd("edit")
        end,
    }
)
