return {
  {
    "Alexis12119/nightly.nvim",
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        comments = { italic = true },
        functions = {},
        keywords = {},
        variables = {},
      },
      highlights = {},
    },
    config = function(_, opts)
      require("nightly").setup(opts)
      vim.cmd.colorscheme("nightly")

      -- Make Telescope and other floating windows transparent
      local highlights = {
        -- Telescope
        TelescopeNormal = { bg = "NONE" },
        TelescopeBorder = { bg = "NONE" },
        TelescopePromptNormal = { bg = "NONE" },
        TelescopePromptBorder = { bg = "NONE" },
        TelescopePromptTitle = { bg = "NONE" },
        TelescopePreviewTitle = { bg = "NONE" },
        TelescopeResultsTitle = { bg = "NONE" },
        TelescopePreviewBorder = { bg = "NONE" },
        TelescopeResultsBorder = { bg = "NONE" },
        -- Float and Popup menus
        NormalFloat = { bg = "NONE" },
        FloatBorder = { bg = "NONE" },
        Pmenu = { bg = "NONE" },
        PmenuSbar = { bg = "NONE" },
        PmenuThumb = { bg = "NONE" },
        -- WhichKey (if you use it)
        WhichKeyFloat = { bg = "NONE" },
        -- LSP floating windows
        LspInfoBorder = { bg = "NONE" },
        -- Notify (if you use nvim-notify)
        NotifyBackground = { bg = "NONE" },
      }

      for group, colors in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, colors)
      end
    end,
  },
}
