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
    { "romainl/vim-cool" },
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

    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspStart" },
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "williamboman/mason-lspconfig.nvim" },
        },
        config = function()
            local lsp_zero = require("lsp-zero")
            local lspconfig = require("lspconfig")
            lsp_zero.extend_lspconfig()
            lsp_zero.on_attach(function(_, bufnr)
                lsp_zero.default_keymaps({ buffer = bufnr })
            end
            )

            require("mason").setup({})
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "gopls", "terraformls", "yamlls", "helm_ls", "ruby_ls" },
                handlers = {
                    lsp_zero.default_setup,
                    lua_ls = function()
                        local lua_opts = lsp_zero.nvim_lua_ls()
                        require("lspconfig").lua_ls.setup(lua_opts)
                    end,
                },
            })

            lsp_zero.format_on_save({
                format_opts = {
                    async = false,
                    timeout_ms = 10000,
                },
                servers = {
                    ["terraformls"] = { "terraform", "terraform-vars" },
                    ["lua_ls"] = { "lua" },
                    ["gopls"] = { "go" },
                }
            })

            lspconfig.lua_ls.setup {}
            lspconfig.gopls.setup {}
            lspconfig.terraformls.setup {}
            lspconfig.yamlls.setup {
                settings = {
                    yaml = {
                        schemas = {
                            ["https://json.schemastore.org/circleciconfig.json"] = { "/.circleci/config.yml", "/.circleci/config.yaml" },
                        },
                    },
                }
            }
            lspconfig.helm_ls.setup {
                settings = {
                    ["helm-ls"] = {
                        yamlls = {
                            path = "yaml-language-server",
                            schemas = {
                                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.28.8-standalone-strict/all.json"] = "/templates/*.yaml",
                            }
                        }
                    }
                }
            }
            lspconfig.ruby_ls.setup {}

            -- Custom Servers
            local configs = require("lspconfig.configs")

            -- CircleCI
            if not configs.cci then
                local cci = "circleci-yaml-language-server"
                local cci_pkg_path = require("mason-core.package").get_install_path(
                    require("mason-registry.").get_package(cci))
                -- Get auth token from CircleCI CLI config file
                function get_auth_token()
                    local cli_config_filepath = os.getenv("HOME") .. "/.circleci/cli.yml"
                    local cli_config_file = io.open(cli_config_filepath, "r")
                    if not cli_config_file then return nil end
                    cli_config_file:close()

                    for line in io.lines(cli_config_filepath) do
                        for token in line:gmatch("token: (.*)") do
                            return token
                        end
                    end
                end

                configs.cci = {
                    default_config = {
                        cmd = { cci, "--schema", cci_pkg_path .. "/schema.json", "--stdio" },
                        on_attach = lsp_zero.default_keymaps({ buffer = bufnr }),
                        on_init = function(client, results)
                            client.request('workspace/executeCommand', {
                                command = "setToken",
                                arguments = { get_auth_token() }
                            })
                        end,
                        root_dir = lspconfig.util.find_git_ancestor,
                        filetypes = { "circleci-yaml" },
                        settings = {}
                    },
                }
            end
            lspconfig.cci.setup {}
        end
    },
    {
        "VonHeikemen/lsp-zero.nvim",
        lazy = true,
        config = false,
        init = function()
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end
    },
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = true
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            { "L3MON4D3/LuaSnip" },
        },
        config = function()
            local lsp_zero = require("lsp-zero")
            lsp_zero.extend_cmp()

            local cmp = require("cmp")
            local cmp_action = lsp_zero.cmp_action()

            cmp.setup({
                preselect = "item",
                completion = {
                    completeopt = "menu,menuone,noinsert"
                },
                sources = {
                    { name = "nvim_lsp" },
                },
                formatting = lsp_zero.cmp_format({ details = true }),
                mapping = cmp.mapping.preset.insert({
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp_action.luasnip_supertab(),
                    ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
                }),
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
            })
        end
    },

    { "sindrets/diffview.nvim" },

    { "saadparwaiz1/cmp_luasnip" },

    { dir = "/opt/homebrew/opt/fzf" },
    { "junegunn/fzf.vim" },
    { "junegunn/vim-peekaboo" },
    {
        "junegunn/goyo.vim",
        ft = "markdown"
    },

    {
        "plasticboy/vim-markdown",
        ft = "markdown"
    },
    {
        "towolf/vim-helm",
        ft = "helm"
    },
})

vim.cmd([[
    source $HOME/.vim/vimrc
]])
