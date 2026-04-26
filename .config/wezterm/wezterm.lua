local wezterm = require("wezterm")
local config = wezterm.config_builder()

local green = "#8ff586"
local light_blue = "#3aa5ff"
local cobalt2_bg = "#193549"

local scheme = wezterm.color.get_builtin_schemes()["Cobalt 2 (Gogh)"]
scheme.foreground = green
scheme.background = cobalt2_bg
scheme.ansi[5] = light_blue -- blue -> light blue
scheme.brights[5] = light_blue

config.color_schemes = { ["My Cobalt 2"] = scheme }
config.color_scheme = "My Cobalt 2"

config.font = wezterm.font_with_fallback({
	"Source Code Pro",
	{ family = "Miriam Mono CLM", weight = "DemiBold", scale = 1.1 },
})
config.font_size = 12.0

config.term = "wezterm"

config.enable_kitty_keyboard = true

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
