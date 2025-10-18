local wezterm = require("wezterm")

local utils = require("utils")

local config = wezterm.config_builder()
local mux = wezterm.mux

config.automatically_reload_config = true

config.front_end = "OpenGL"

config.animation_fps = 60
config.max_fps = 60

config.use_ime = true

-- window
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

config.window_background_opacity = 0.85

config.window_decorations = "RESIZE"

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

wezterm.on("format-window-title", function(tab)
  return utils.base_name(tab.active_pane.foreground_process_name)
end)

-- tab
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = true

config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

local tab_left_decoration = wezterm.nerdfonts.pl_right_hard_divider
local tab_right_decoration = wezterm.nerdfonts.pl_left_hard_divider

local tab_bg_color = { "#282828", "#665c54" }
local tab_fg_color = { "#fbf1c7", "#bdae93" }

local tab_decoration_bg_color = "none"
local tab_decoration_fg_color = tab_bg_color

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local index = tab.is_active and 1 or 2

  return {
    { Background = { Color = tab_decoration_bg_color } },
    { Foreground = { Color = tab_decoration_fg_color[index] } },
    { Text = tab_left_decoration },
    { Background = { Color = tab_bg_color[index] } },
    { Foreground = { Color = tab_fg_color[index] } },
    { Text = utils.base_name(tab.active_pane.foreground_process_name) },
    { Background = { Color = tab_decoration_bg_color } },
    { Foreground = { Color = tab_decoration_fg_color[index] } },
    { Text = tab_right_decoration },
  }
end)

-- colorscheme
config.color_scheme = "Gruvbox Dark (Gogh)"

-- terminal
if utils.detect_os() == "windows" then
  config.default_prog = { "powershell" }
end

-- fonts
local s_font_size = 10.0
local l_font_size = 12.0
config.font_size = l_font_size

if utils.detect_os() == "windows" then
  config.font = wezterm.font_with_fallback {
    "Firge35Nerd Console",
    "Consolas",
    "Courier New",
    "monospace"
  }
end

-- keybindings
config.disable_default_key_bindings = true
config.keys = require("keybindings").keys
config.key_tables = require("keybindings").key_tables
config.leader = require("keybindings").leader

-- status
local icon_bat = wezterm.nerdfonts.fa_battery_3
local icon_calendar = wezterm.nerdfonts.cod_calendar
local icon_clock = wezterm.nerdfonts.fa_clock

local status_left_decoration = wezterm.nerdfonts.pl_right_hard_divider
local status_right_decoration = wezterm.nerdfonts.pl_left_hard_divider

local status_bg_color = { "#282828", "#665c54" }
local status_fg_color = { "#fbf1c7", "#bdae93" }

local status_decoration_bg_color = "none"
local status_decoration_fg_color = status_bg_color

local function add_element(elems, info_table, color_index)
  local index = color_index or 1

  local icon = info_table[1]
  local info = info_table[2]

  if icon == nil or info == nil then
    return
  end

  table.insert(elems, { Background = { Color = status_bg_color[index] } })
  table.insert(elems, { Foreground = { Color = status_fg_color[index] } })
  if #icon > 0 then
    table.insert(elems, { Text = " " .. icon .. "  " .. info .. " " })
  else
    table.insert(elems, { Text = " " .. icon .. info .. " " })
  end
end

local function get_battery_level(elems, window)
  for _, b in ipairs(wezterm.battery_info()) do
    add_element(elems, { icon_bat, string.format("%.0f%%", b.state_of_charge * 100) }, nil)
  end
end

local function get_date(elems)
  local date = wezterm.strftime "%a %b %-d"

  add_element(elems, { icon_calendar, date }, nil)
end

local function get_time(elems)
  local time = wezterm.strftime "%H:%M"

  add_element(elems, { icon_clock, time }, nil)
end

local function get_keyboard(elems, window)
  local key_table_name = window:active_key_table()

  if key_table_name then
    add_element(elems, { "", key_table_name})
  else
    add_element(elems, { "", "?" }, 1)
  end

  if window:leader_is_active() then
    add_element(elems, { "", "LEADER" }, 2)
  else
    add_element(elems, { "", "LEADER" }, 1)
  end

  if window:composition_status() then
    add_element(elems, { "", "IME" }, 2)
  else
    add_element(elems, { "", "IME" }, 1)
  end
end

local function update_status(window, pane)
  local elems = {}

  table.insert(elems, { Background = { Color = status_decoration_bg_color } })
  table.insert(elems, { Foreground = { Color = status_decoration_fg_color[1] } })
  table.insert(elems, { Text = status_left_decoration })

  get_keyboard(elems, window)
  get_battery_level(elems, window)
  get_date(elems)
  get_time(elems)

  table.insert(elems, { Background = { Color = status_decoration_bg_color } })
  table.insert(elems, { Foreground = { Color = status_decoration_fg_color[1] } })
  table.insert(elems, { Text = status_right_decoration })

  window:set_right_status(wezterm.format(elems))
end

-- dpi
local DPI_THRESHOLD = 150

local prev_dpi = 0

wezterm.on("trigger-dpi", function(window, dpi)
  local overrides = window:get_config_overrides() or {}
  overrides.font_size = dpi >= DPI_THRESHOLD and s_font_size or nil

  window:set_config_overrides(overrides)
end)

-- update
wezterm.on("update-status", function(window, pane)
  update_status(window, pane)

  local dpi = window:get_dimensions().dpi

  if dpi == prev_dpi then
    return
  end

  wezterm.emit("trigger-dpi", window, dpi)

  prev_dpi = dpi
end)

return config