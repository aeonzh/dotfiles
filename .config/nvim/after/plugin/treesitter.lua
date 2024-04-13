require("nvim-treesitter.configs").setup {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "yaml", "terraform", "helm", "ruby", "javascript", "go" },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}
vim.treesitter.language.register('yaml', { 'circleci-yaml' })
