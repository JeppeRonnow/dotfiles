-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls",
                  "clangd",
                  "jedi_language_server",
                  "cmake_language_server"
  }
local nvlsp = require "nvchad.configs.lspconfig"


vim.diagnostic.config({
  virtual_text = false,  -- Disable inline diagnostics
  signs = true,          -- Keep signs in the sign column
  underline = true,      -- Keep underlines for errors
  update_in_insert = false,
})



-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,

    handlers = {
  ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
    if not result or not result.diagnostics then
      return
    end

    -- Filter diagnostics if needed
    local filtered = {}
    for _, diagnostic in ipairs(result.diagnostics) do
      if not diagnostic.message:match("Unused label") then
        table.insert(filtered, diagnostic)
      end
    end
    result.diagnostics = filtered

    -- Disable virtual text (inline diagnostics)
    config = config or {}
    config.virtual_text = false

    return vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
  end,
},

  }
end
-- configuring single server, example: typescript
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }
