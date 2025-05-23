-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Solarized Dark'
config.window_background_opacity = 0.9
config.font = wezterm.font('Fira Code')
config.font_size = 14.0
-- and finally, return the configuration to wezterm
return config
