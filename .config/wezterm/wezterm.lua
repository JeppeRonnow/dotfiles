local wezterm = require("wezterm")
local config = {}

config.color_scheme = "Dracula"
config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.enable_tab_bar = false

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    config.default_prog = { "powershell.exe", "-NoLogo" }
    config.launch_menu = {
        {
            label = "WSL SSH",
            args = { "ssh", "wsl" },
        },
        {
            label = "WSL",
            args = { "wsl.exe" },
        },
        {
            label = "PowerShell",
            args = { "powershell.exe", "-NoLogo" },
        },
        {
            label = "CMD",
            args = { "cmd.exe" },
        },
    }
end

config.keys = {
    {
        key = "F11",
        action = wezterm.action.ToggleFullScreen,
    },
    {
        key = "l",
        mods = "ALT",
        action = wezterm.action.ShowLauncher,
    }
}

return config
