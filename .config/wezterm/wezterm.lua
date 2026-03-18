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

config.keys = {
	{ key = "c", mods = "CTRL", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.SendString("\x03") },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ShowTabNavigator },
}

return config
