local lsp_zero = require('lsp-zero')
local lspconfig = require('lspconfig')

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({ buffer = bufnr })
end)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { 'lua_ls', 'gopls', 'terraformls', 'yamlls', 'helm_ls', 'ruby_ls' },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
    },
})

lsp_zero.format_on_save({
    format_opts = {
        async = false,
        timeout_ms = 10000,
    },
    servers = {
        ['terraformls'] = { 'terraform', 'terraform-vars' },
        ['lua_ls'] = { 'lua' },
        ['gopls'] = { 'go' },
    }
})

lspconfig.lua_ls.setup {}
lspconfig.terraformls.setup {}
lspconfig.yamlls.setup {
    settings = {
        yaml = {
            schemas = {
                -- ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.28.8-standalone-strict/all.json"] = "/templates/*.yaml"
                ["https://raw.githubusercontent.com/CircleCI-Public/circleci-yaml-language-server/main/schema.json"] = "/.circleci/config.yml"
            },
        },
    }
}
lspconfig.helm_ls.setup {
    settings = {
        ['helm-ls'] = {
            yamlls = {
                path = "yaml-language-server",
            }
        }
    }
}
