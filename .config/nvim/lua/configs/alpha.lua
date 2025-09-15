local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Header
dashboard.section.header.val = {
"                 :^^^~~~!!!!!!!!!!!~ .~~~~~~~: .!!!!!!!: 75YYJ?7!^:        ",
"                7&@@@@@@@@@@@@@@@@@! 7YYYYYY?  7YYYYYY? ^@@@@@@@@@&BJ^     ",
"               ?@@@@@@@@@@@@@@@@@@5 ~YJJJJJJ: ^YJJJJJJ: G@@@@@@@@@@@@@Y    ",
"              ?@@@@@@@@@@@@@@@@@@#..JJJJJJY~ .JYJJJJY! J@@@@@@@@@@@@@@@5   ",
"             7@@@@@@@@@@@@@@@@@@@~ 7YJJJJY?  7YJJJJY? .5YJYP#@@@@@@@@@@@:  ",
"             JYJJ?????????&@@@@@Y ~YJJJJJJ: ^YJJJJJJ:       .B@@@@@@@@@@~  ",
"                         ~@@@@@B .JJJJJJY~ .JJJJJJY~         B@@@@@@@@@&:  ",
"                         G@@@@@~ 7YJJJJY7  7YJJJJY?         Y@@@@@@@@@@J   ",
"                        !@@@@@Y ~YJJJJJJ: ~YJJJJJJ:      .!G@@@@@@@@@@5    ",
"                        B@@@@B .JJJJJJY~ .JJJJJJY~ 7YY5PB&@@@@@@@@@@&?     ",
"          :~7          J@@@@@~ 7YJJJJY7  7YJJJJY? ~@@@@@@@@@@@@@@@#J:      ",
"     .~?5B&@B         ~@@@@@J ~YJJJJJJ. ~YJJJJJJ. B@@@@@@@@@@@&BY!.        ",
"  .?P#@@@@@@#        ^&@@@@B .JJJJJJY~ .JJJJJJY~ J@@@@@@@@@@&!:            ",
"  .#@@@@@@@@@J      7&@@@@@^ ?YJJJJY7  7YJJJJY7  :5@@@@@@@@@@Y             ",
"   !@@@@@@@@@@G?!7YB@@@@@@J ~YJJJJJJ. ~YJJJJJJ.   .G@@@@@@@@@@7            ",
"    7&@@@@@@@@@@@@@@@@@@@B :JJJJJJY^ :JJJJJJY~     :#@@@@@@@@@@~           ",
"     ^P@@@@@@@@@@@@@@@@@@^ ?YJJJJY7  7YJJJJY7       ^&@@@@@@@@@#:          ",
"       ^YB@@@@@@@@@@@@&B7 !YYYYYYJ. ~YYYYYYJ.        ~&@@@&&&&&@P          ",
"          :!?JY55YY?7~:   ~~~~~~~:  ^~~^^^^:          :^^::::::::          ",
      }

-- Buttons
dashboard.section.buttons.val = {
    dashboard.button("e", "📂 New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("f", "🔍 Find file", ":Telescope find_files<CR>"),
    dashboard.button("r", "📜 Recent files", ":Telescope oldfiles<CR>"),
    dashboard.button("q", "❌ Quit", ":qa<CR>"),
}

-- Footer
dashboard.section.footer.val = {
    "@JeppeRonnow"
}

-- SHIFT LAYOUT DOWN WITH PADDING
dashboard.opts.layout = {
    { type = "padding", val = 8 },  -- Add padding at the top to shift everything down
    dashboard.section.header,
    { type = "padding", val = 4 },  -- Space between header and buttons
    dashboard.section.buttons,
    { type = "padding", val = 3 },  -- Space between buttons and footer
    dashboard.section.footer,
}

-- Layout
alpha.setup(dashboard.opts)

-- Auto-load Alpha on startup
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            require("alpha").start()
        end
    end,
})

-- AUTOLOAD ALPHA ON STARTUP
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    callback = function()
        if vim.fn.argc() == 0 then
            require("alpha").start()
        end
    end,
})
