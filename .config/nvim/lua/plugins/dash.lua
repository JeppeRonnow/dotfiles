return {
	"nvimdev/dashboard-nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = function()
		local logo = [[
                 :^^^~~~!!!!!!!!!!!~ .~~~~~~~: .!!!!!!!: 75YYJ?7!^:        
                7&@@@@@@@@@@@@@@@@@! 7YYYYYY?  7YYYYYY? ^@@@@@@@@@&BJ^     
               ?@@@@@@@@@@@@@@@@@@5 ~YJJJJJJ: ^YJJJJJJ: G@@@@@@@@@@@@@Y    
              ?@@@@@@@@@@@@@@@@@@#..JJJJJJY~ .JYJJJJY! J@@@@@@@@@@@@@@@5   
             7@@@@@@@@@@@@@@@@@@@~ 7YJJJJY?  7YJJJJY? .5YJYP#@@@@@@@@@@@:  
             JYJJ?????????&@@@@@Y ~YJJJJJJ: ^YJJJJJJ:       .B@@@@@@@@@@~  
                         ~@@@@@B .JJJJJJY~ .JJJJJJY~         B@@@@@@@@@&:  
                         G@@@@@~ 7YJJJJY7  7YJJJJY?         Y@@@@@@@@@@J   
                        !@@@@@Y ~YJJJJJJ: ~YJJJJJJ:      .!G@@@@@@@@@@5    
                        B@@@@B .JJJJJJY~ .JJJJJJY~ 7YY5PB&@@@@@@@@@@&?     
          :~7          J@@@@@~ 7YJJJJY7  7YJJJJY? ~@@@@@@@@@@@@@@@#J:      
     .~?5B&@B         ~@@@@@J ~YJJJJJJ. ~YJJJJJJ. B@@@@@@@@@@@&BY!.        
  .?P#@@@@@@#        ^&@@@@B .JJJJJJY~ .JJJJJJY~ J@@@@@@@@@@&!:            
  .#@@@@@@@@@J      7&@@@@@^ ?YJJJJY7  7YJJJJY7  :5@@@@@@@@@@Y             
   !@@@@@@@@@@G?!7YB@@@@@@J ~YJJJJJJ. ~YJJJJJJ.   .G@@@@@@@@@@7            
    7&@@@@@@@@@@@@@@@@@@@B :JJJJJJY^ :JJJJJJY~     :#@@@@@@@@@@~           
     ^P@@@@@@@@@@@@@@@@@@^ ?YJJJJY7  7YJJJJY7       ^&@@@@@@@@@#:          
       ^YB@@@@@@@@@@@@&B7 !YYYYYYJ. ~YYYYYYJ.        ~&@@@&&&&&@P          
          :!?JY55YY?7~:   ~~~~~~~:  ^~~^^^^:          :^^::::::::          
		]]

		logo = string.rep("\n", 2) .. logo .. "\n\n"

		local opts = {
			theme = "doom",
			hide = {
				statusline = false,
			},
			config = {
				header = vim.split(logo, "\n"),
				-- stylua: ignore
				center = {
					{ action = "Telescope find_files",                         desc = " Find File",       icon = " ", key = "f" },
					{ action = "ene | startinsert",                            desc = " New File",        icon = " ", key = "n" },
					{ action = "Telescope oldfiles",                           desc = " Recent Files",    icon = " ", key = "r" },
					{ action = "Telescope live_grep",                          desc = " Find Text",       icon = " ", key = "g" },
					{ action = "e " .. vim.fn.stdpath("config") .. "/init.lua", desc = " Config",         icon = " ", key = "c" },
					{ action = "Lazy",                                         desc = " Lazy",            icon = "󰒲 ", key = "l" },
					{ action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",          icon = " ", key = "q" },
				},
				footer = function()
					local stats = require("lazy").stats()
					local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
					return { "Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
				end,
			},
		}

		for _, button in ipairs(opts.config.center) do
			button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
			button.key_format = "  %s"
		end

		-- open dashboard after closing lazy
		if vim.o.filetype == "lazy" then
			vim.api.nvim_create_autocmd("WinClosed", {
				pattern = tostring(vim.api.nvim_get_current_win()),
				once = true,
				callback = function()
					vim.schedule(function()
						vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
					end)
				end,
			})
		end

		return opts
	end,
}
