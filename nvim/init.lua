-- Устанавливаем Leader на пробел
vim.g.mapleader = " "

-- Сохранить файл с помощью Leader + s
vim.api.nvim_set_keymap('n', '<Leader>s', ':w<CR>', { noremap = true, silent = true })

-- Закрыть текущий буфер с помощью Leader + q
vim.api.nvim_set_keymap('n', '<Leader>q', ':q<CR>', { noremap = true, silent = true })

-- Открыть новое окно с помощью Leader + v
vim.api.nvim_set_keymap('n', '<Leader>v', ':vsplit<CR>', { noremap = true, silent = true })

