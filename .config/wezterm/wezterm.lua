local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local green      = '#8ff586'
local light_blue = '#3aa5ff'
local cobalt2_bg = '#193549'

local scheme = wezterm.color.get_builtin_schemes()['Cobalt 2 (Gogh)']
scheme.foreground = green
scheme.background = cobalt2_bg
scheme.ansi[5]    = light_blue  -- blue -> light blue
scheme.brights[5] = light_blue

config.color_schemes = { ['My Cobalt 2'] = scheme }
config.color_scheme = 'My Cobalt 2'

config.font = wezterm.font 'Source Code Pro'
config.font_size = 12.0

config.term = "wezterm"

config.enable_tab_bar = false
config.window_decorations = 'NONE'
config.window_close_confirmation = 'NeverPrompt'

return config
