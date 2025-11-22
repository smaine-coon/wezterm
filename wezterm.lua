local wezterm = require("wezterm")

local env = require("env")
local term = require("term")

local config = wezterm.config_builder()

-- config
config.automatically_reload_config = true

config.front_end = "OpenGL"

config.animation_fps = 60
config.max_fps = 60

config.use_ime = true

-- window
wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()

    local current_appearance = term.get_appearance()

    local function poll_appearance()
      local new_appearance = term.get_appearance()

      if new_appearance ~= current_appearance then
        current_appearance = new_appearance

        local scheme = term.set_colorscheme()

        local overrides = window:get_config_overrides() or {}
        overrides.color_scheme = scheme

        window:set_config_overrides(overrides)

        wezterm.log_info("Theme switched to" .. scheme)
      end

      wezterm.time.call_after(10.0, poll_appearance)
    end

    wezterm.time.call_after(10.0, poll_appearance)
end)

local function disable_window_decorations(window, interval)
  if interval then
    wezterm.sleep_ms(interval)
  end

  local overrides = window:get_config_overrides() or {}
  overrides.window_decorations = nil

  window:set_config_overrides(overrides)
end

config.color_scheme = term.set_colorscheme()

config.window_background_opacity = 0.85

config.window_decorations = "RESIZE"

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- keybindings
config.disable_default_key_bindings = true
config.keys = require("keybindings").keys
config.key_tables = require("keybindings").key_tables
config.leader = require("keybindings").leader
config.mouse_bindings = require('keybindings').mouse_bindings

-- terminal
if env.os.is_wsl then
  config.default_prog = env.shell.wsl
elseif env.os.is_windows then
  config.default_prog = env.shell.windows
elseif env.os.is_macos then
  config.default_prog = env.shell.macos
elseif env.os.is_linux then
  config.default_prog = env.shell.linux
end

-- font
local s_font_size = 11.0
local l_font_size = 13.0
config.font_size = s_font_size

if env.os.is_windows then
  config.font = wezterm.font_with_fallback {
    "Firge35Nerd Console",
    "Consolas",
    "Courier New",
    "monospace"
  }
end

-- dpi
local DPI_THRESHOLD = 150

local prev_dpi = 0

wezterm.on('window-focus-changed', function(window, pane)
  local dpi = window:get_dimensions().dpi

  if dpi == prev_dpi then
    return
  end

  local overrides = window:get_config_overrides() or {}
  overrides.font_size = dpi >= DPI_THRESHOLD and l_font_size or s_font_size

  window:set_config_overrides(overrides)

  prev_dpi = dpi

  disable_window_decorations(window, 1000)
end)

-- title
wezterm.on('show-title-bar', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  overrides.window_decorations = 'TITLE | RESIZE'

  window:set_config_overrides(overrides)

  disable_window_decorations(window, 3000)
end)

-- tab
local tab_left_decoration = wezterm.nerdfonts.pl_right_hard_divider
local tab_right_decoration = wezterm.nerdfonts.pl_left_hard_divider

local tab_bg_color = { "#282828", "#665c54", "#fbf1c7", "#bdae93" }
local tab_fg_color = { "#fbf1c7", "#bdae93", "#282828", "#665c54" }

local tab_decoration_bg_color = "none"
local tab_decoration_fg_color = tab_bg_color

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

local function base_name(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local index = tab.is_active and 1 or 2

  local appearance = term.get_appearance()
  if appearance == "light" then
    index = index + 2
  end

  return {
    { Background = { Color = tab_decoration_bg_color } },
    { Foreground = { Color = tab_decoration_fg_color[index] } },
    { Text = tab_left_decoration },
    { Background = { Color = tab_bg_color[index] } },
    { Foreground = { Color = tab_fg_color[index] } },
    { Text = base_name(tab.active_pane.foreground_process_name) },
    { Background = { Color = tab_decoration_bg_color } },
    { Foreground = { Color = tab_decoration_fg_color[index] } },
    { Text = tab_right_decoration },
  }
end)

-- status
local icon_bat = wezterm.nerdfonts.fa_battery_3
local icon_calendar = wezterm.nerdfonts.cod_calendar
local icon_clock = wezterm.nerdfonts.fa_clock

local status_left_decoration = wezterm.nerdfonts.pl_right_hard_divider
local status_right_decoration = wezterm.nerdfonts.pl_left_hard_divider

local status_bg_color = { "#282828", "#665c54", "#fbf1c7", "#bdae93" }
local status_fg_color = { "#fbf1c7", "#bdae93", "#282828", "#665c54" }

local status_decoration_bg_color = "none"
local status_decoration_fg_color = status_bg_color

local function add_element(elems, index, icon, info)
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

local function get_battery_level(elems, index)
  for _, b in ipairs(wezterm.battery_info()) do
    add_element(elems, index, icon_bat, string.format("%.0f%%", b.state_of_charge * 100))
  end
end

local function get_keyboard(elems, index, window)
  local key_table_name = window:active_key_table()

  if key_table_name then
    add_element(elems, index, "", key_table_name)
  else
    add_element(elems, index, "", "?" )
  end

  if window:leader_is_active() then
    add_element(elems, index + 1, "", "LEADER")
  else
    add_element(elems, index, "", "LEADER")
  end

  if window:composition_status() then
    add_element(elems, index + 1, "", "IME")
  else
    add_element(elems, index, "", "IME")
  end
end

local function get_date(elems, index)
  local date = wezterm.strftime "%a %b %-d"

  add_element(elems, index, icon_calendar, date)
end

local function get_time(elems, index)
  local time = wezterm.strftime "%H:%M"

  add_element(elems, index, icon_clock, time)
end

wezterm.on("update-status", function(window, pane)
  local index = 1

  local appearance = term.get_appearance()
  if appearance == "light" then
    index = index + 2
  end

  local elems = {}

  table.insert(elems, { Background = { Color = status_decoration_bg_color } })
  table.insert(elems, { Foreground = { Color = status_decoration_fg_color[index] } })
  table.insert(elems, { Text = status_left_decoration })

  get_keyboard(elems, index, window)
  get_battery_level(elems, index)
  get_date(elems, index)
  get_time(elems, index)

  table.insert(elems, { Background = { Color = status_decoration_bg_color } })
  table.insert(elems, { Foreground = { Color = status_decoration_fg_color[index] } })
  table.insert(elems, { Text = status_right_decoration })

  window:set_right_status(wezterm.format(elems))
end)

return config