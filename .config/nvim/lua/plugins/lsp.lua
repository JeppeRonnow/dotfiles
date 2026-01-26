return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Clang LSP for C/C++
        clangd = {
          keys = {
            { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_dir = function(fname, bufnr)
            -- Ensure fname is a string, not a number
            if type(fname) == "number" then
              fname = vim.api.nvim_buf_get_name(fname)
            end
            if not fname or fname == "" then
              return nil
            end

            local util = require("lspconfig.util")
            return util.root_pattern(
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname) or util.root_pattern("compile_commands.json", "compile_flags.txt")(fname) or util.find_git_ancestor(
              fname
            )
          end,
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        -- Python LSP
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
      },
    },
  },
  -- Ensure mason installs the LSP servers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "pyright",
      },
    },
  },
}
