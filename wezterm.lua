local wezterm = require('wezterm')

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
  config:set_strict_mode(true)
end

return config