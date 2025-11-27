return {
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    opts = {
      colors = {
        bg = "#121212",
        fg = "#f8f8f2",
        selection = "#1a1a1a",
        comment = "#4a4a4a",
        red = "#fc3c3f",
        orange = "#ff6600",
        yellow = "#f9ee8b",
        green = "#3db85f",
        purple = "#ff6600",
        cyan = "#3db85f",
        pink = "#fc3c3f",
        bright_red = "#ff8080",
        bright_green = "#5cd682",
        bright_yellow = "#fcf4b0",
        bright_blue = "#ff9944",
        bright_magenta = "#ff6f72",
        bright_cyan = "#5cd682",
        bright_white = "#ffffff",
        menu = "#1a1a1a",
        visual = "#1a1a1a",
        gutter_fg = "#4a4a4a",
        nontext = "#4a4a4a",
      },
      show_end_of_buffer = true,
      transparent_bg = true,
      lualine_bg_color = "#1a1a1a",
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
