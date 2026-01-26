return {
  "uhs-robert/oasis.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("oasis").setup(               -- (see Configuration below for all customization options)
      { transparent = true })
    vim.cmd.colorscheme("oasis-midnight") -- After setup, apply theme (or a any style like "oasis-night")
  end
}
