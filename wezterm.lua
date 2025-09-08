local wezterm = require 'wezterm'
require 'format'
require 'status'

local config = {}

config.automatically_reload_config = true

config.default_prog = { 'powershell.exe', '-Nologo' }

config.launch_menu = require('launchmenu')

config.use_ime = true

config.disable_default_key_bindings = true
config.keys = require('keybinding').keys
config.key_tables = require('keybinding').key_tables
config.leader = require('keybinding').leader

config.color_scheme = 'Night Owl (Gogh)'
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.85
config.window_frame = {
    inactive_titlebar_bg = '#011627',
    active_titlebar_bg = '#011627',
}

config.use_fancy_tab_bar = true
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.colors = {
  tab_bar = {
    inactive_tab_edge = 'none',
  },
}

config.font = wezterm.font_with_fallback { 'Firge35Nerd Console', 'Consolas', 'Courier New', 'monospace' }
config.font_size = 11.5
config.front_end = 'OpenGL'

config.status_update_interval = 1000

config.hide_mouse_cursor_when_typing = true

return config