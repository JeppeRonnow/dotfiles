return {
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    opts = {
      colors = {
        bg = "#282A36",
        fg = "#F8F8F2",
        selection = "#44475A",
        comment = "#6272A4",
        red = "#FF5555",
        orange = "#FFB86C",
        yellow = "#F1FA8C",
        green = "#50fa7b",
        purple = "#BD93F9",
        cyan = "#8BE9FD",
        pink = "#FF79C6",
        bright_red = "#FF6E6E",
        bright_green = "#69FF94",
        bright_yellow = "#FFFFA5",
        bright_blue = "#D6ACFF",
        bright_magenta = "#FF92DF",
        bright_cyan = "#A4FFFF",
        bright_white = "#FFFFFF",
        menu = "#21222C",
        visual = "#3E4452",
        gutter_fg = "#4B5263",
        nontext = "#3B4048",
      },
      show_end_of_buffer = true,
      transparent_bg = true,
      lualine_bg_color = "#44475a",
      italic_comment = true,
    },
    config = function(_, opts)
      require("dracula").setup(opts)
      vim.cmd.colorscheme("dracula")

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
