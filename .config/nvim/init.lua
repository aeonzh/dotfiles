local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate"
    },
    { "nvim-treesitter/nvim-treesitter-context" },

    { "sindrets/diffview.nvim" },

    { dir = vim.fn.system({ "brew", "--prefix" }):gsub("%s+$", "") .. "/opt/fzf" },
    { "ibhagwan/fzf-lua" },
    { "junegunn/vim-peekaboo" },

})

vim.cmd([[ source $HOME/.vim/vimrc ]])

vim.lsp.enable({ 'luals', 'gopls', 'ruby-lsp', 'ts-ls' })

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        local autocmd = vim.api.nvim_create_autocmd

        if client:supports_method('textDocument/completion') then
            local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            autocmd({ 'TextChangedI' }, {
                buffer = args.buf,
                callback = function()
                    vim.lsp.completion.get()
                end
            })
            client.server_capabilities.completionProvider.triggerCharacters = chars
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end

        if client:supports_method('textDocument/formatting') then
            autocmd('BufWritePre', {
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                end,
            })
        end

        if client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
    end,
})
