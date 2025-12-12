local wezterm = require 'wezterm'
local act = wezterm.action

local function disable_window_decorations(window, interval)
  if interval then
    wezterm.sleep_ms(interval)
  end

  local overrides = window:get_config_overrides() or {}
  overrides.window_decorations = nil -- 'RESIZE'
  window:set_config_overrides(overrides)
end

wezterm.on('show-title-bar', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  overrides.window_decorations = 'TITLE | RESIZE'
  window:set_config_overrides(overrides)
  disable_window_decorations(window, 2500)
end)

wezterm.on('window-focus-changed', function(window, pane)
  if window:is_focused() then
    return
  end

  disable_window_decorations(window)
end)

return {
  leader = { key = "\\", mods = "CTRL", timeout_milliseconds = 1500 },

  mouse_bindings = {
    {
      event = { Down = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = act.EmitEvent 'show-title-bar',
    }
  },

  --[[
    key='a', mods='NONE'
    key='A', mods='SHIFT'
  ]]
  keys = {
    -- workspace
    {
      key = "o",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "(wezterm) Create new workspace:",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              act.SwitchToWorkspace({
                name = line,
              }),
              pane
            )
          end
        end),
      }),
    },
    {
      key = "s",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "(wezterm) Set workspace title:",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
          end
        end),
      }),
    },
    {
      key = "l",
      mods = "LEADER",
      action = act.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" }),
    },

    -- window
    { key = 'n', mods = 'LEADER', action = act.SpawnWindow },
    { key = 'm', mods = 'LEADER', action = act.Hide },

    -- tab
    { key = 't', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w', mods = 'LEADER', action = act.CloseCurrentTab{ confirm = true } },
    { key = 'Tab', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    { key = 'Tab', mods = 'SHIFT|LEADER', action = act.ActivateTabRelative(-1) },
    { key = "{", mods = "SHIFT|LEADER", action = act({ MoveTabRelative = -1 }) },
    { key = "}", mods = "SHIFT|LEADER", action = act({ MoveTabRelative = 1 }) },

    -- pane
    { key = 'v', mods = 'LEADER', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
    { key = 'h', mods = 'LEADER', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
    { key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },

    -- font
    { key = '(', mods = 'SHIFT|LEADER', action = act.ResetFontSize },
    { key = '+', mods = 'SHIFT|LEADER', action = act.IncreaseFontSize },
    { key = '-', mods = 'LEADER', action = act.DecreaseFontSize },

    -- copy, paste
    { key = 'c', mods = 'LEADER', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'LEADER', action = act.PasteFrom 'Clipboard' },

    -- misc
    { key = 'T', mods = 'SHIFT|LEADER', action = act.ToggleFullScreen },
    { key = 'Z', mods = 'SHIFT|LEADER', action = act.TogglePaneZoomState },
    { key = 'F', mods = 'SHIFT|LEADER', action = act.Search 'CurrentSelectionOrEmptyString' },
    { key = 'L', mods = 'SHIFT|LEADER', action = act.ShowDebugOverlay },
    { key = 'P', mods = 'SHIFT|LEADER', action = act.ActivateCommandPalette },
    { key = 'R', mods = 'SHIFT|LEADER', action = act.ReloadConfiguration },
    { key = 'X', mods = 'SHIFT|LEADER', action = act.ActivateCopyMode },
    {
      key = "a",
      mods = "LEADER",
      action = act.ActivateKeyTable({ name = "activate_pane", timeout_milliseconds = 1000 }),
    },
    {
      key = "r",
      mods = "LEADER",
      action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false })
    },
  },

  key_tables = {
    activate_pane = {
      { key = 'h', mods = 'NONE', action = act.ActivatePaneDirection 'Left' },
      { key = 'j', mods = 'NONE', action = act.ActivatePaneDirection 'Down' },
      { key = 'k', mods = 'NONE', action = act.ActivatePaneDirection 'Up' },
      { key = 'l', mods = 'NONE', action = act.ActivatePaneDirection 'Right' },
    },

    resize_pane = {
      { key = 'h', mods = 'NONE', action = act.AdjustPaneSize{ 'Left', 1 } },
      { key = 'j', mods = 'NONE', action = act.AdjustPaneSize{ 'Down', 1 } },
      { key = 'k', mods = 'NONE', action = act.AdjustPaneSize{ 'Up', 1 } },
      { key = 'l', mods = 'NONE', action = act.AdjustPaneSize{ 'Right', 1 } },
    },

    copy_mode = {
      -- movement
      { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
      { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
      { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
      { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
      { key = "f", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
      { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
      { key = "j", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
      { key = "k", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
      -- jump
      { key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
      { key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
      { key = "T", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
      { key = "F", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
      -- select
      { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
      { key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
      { key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
      -- copy
      { key = "y", mods = "NONE", action = act.CopyTo("Clipboard") },
      -- close
      {
        key = "Enter",
        mods = "NONE",
        action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
      },
      { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
      { key = "c", mods = "CTRL", action = act.CopyMode("Close") },
      { key = "q", mods = "NONE", action = act.CopyMode("Close") },
    },
  }
}
