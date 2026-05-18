local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_schemes = {
	["My Cobalt 2"] = {
		background = "#193549",
		foreground = "#8ff586",
		cursor_bg = "#f0cc09",
		cursor_fg = "#fefff2",
		cursor_border = "#f0cc09",
		selection_bg = "#18354f",
		selection_fg = "#b5b5b5",
		ansi = { "#000000", "#ff0000", "#38de21", "#ffe50a", "#3aa5ff", "#ff005d", "#00bbbb", "#bbbbbb" },
		brights = { "#555555", "#f40e17", "#3bd01d", "#edc809", "#3aa5ff", "#ff55ff", "#6ae3fa", "#ffffff" },
	},
}
config.color_scheme = "My Cobalt 2"

config.font = wezterm.font_with_fallback({
	"Source Code Pro",
	{ family = "Miriam Mono CLM", weight = "DemiBold", scale = 1.1 },
})
config.font_size = 12.0

config.term = "wezterm"

config.enable_kitty_keyboard = true

config.audible_bell = "Disabled"

config.enable_tab_bar = false
config.window_decorations = "NONE"
config.window_close_confirmation = "NeverPrompt"

local function update_tabs_cache()
	wezterm.run_child_process({ os.getenv("SCRIPTS_PATH") .. "/wezterm-tabs-update.sh" })
end

wezterm.on("mux-tab-created", function(tab, mux_window)
	update_tabs_cache()
end)

wezterm.on("mux-tab-closed", function(window_id, tab_id)
	update_tabs_cache()
end)

wezterm.on("format-tab-title", function(tab)
	local process = tab.active_pane.foreground_process_name
	local name = process:match("([^/]+)$") or process
	if name == "yazi" then
		return "File browser"
	elseif name == "ticker" then
		return "Stock market"
	end
	return tab.active_pane.title
end)

config.keys = {
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local text = pane:get_lines_as_text(10000)
			local tmp = os.tmpname() .. ".sh"
			local f = io.open(tmp, "w")
			f:write(text)
			f:close()
			window:perform_action(
				wezterm.action.SpawnCommandInNewTab({
					args = { "nvim", "-R", "-c", "set buftype=nofile | set noswapfile | normal G", tmp },
				}),
				pane
			)
		end),
	},
	{ key = "c", mods = "CTRL", action = wezterm.action.CopyTo("Clipboard") },
	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.SendString("\x03") },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ShowTabNavigator },
}

return config
