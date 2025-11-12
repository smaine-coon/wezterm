local wezterm = require("wezterm")

local utils = require("utils")

local act = wezterm.action

local function choose_theme(appearance, window, pane)
  local dark_themes = {
    "Gruvbox Dark (Gogh)",
    "tokyonight_moon",
  }

  local light_themes = {
    "Gruvbox (Gogh)",
    "tokyonight_day"
  }

  local ls = nil

  if appearance == "Dark" then
    ls = dark_themes
  else
    ls = light_themes
  end

  window:perform_action(
    act.InputSelector({
      title = appearance .. "Theme",
      description = "Select a " .. appearance .. " theme",
      choices = (function()
        local current = utils.set_appearance(appearance)
        local list = {
          { label = string.format("Current: %s", current), id = "__current__" },
        }
        for _, name in ipairs(ls) do
          table.insert(list, { label = name, id = name })
        end
        return list
      end)(),
      action = wezterm.action_callback(function(win, _, id_)
        if id_ and id_ ~= "__current__" then
          utils.save_theme(appearance, id_)
          wezterm.log_info("Saved " .. appearance .. " theme: " .. id_)
        end
      end),
    }),
    pane
  )
end

local function choose_both_themes(window, pane)
  choose_theme(utils.get_system_appearance(), window, pane)
end

return {
  leader = { key = "\\", mods="CTRL", timeout_milliseconds = 2000},

  keys = {
    -- change color scheme
    {
      key = "p",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        choose_both_themes(window, pane)
      end),
    },
    -- tab
    { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
    { key = "}", mods = "SHIFT|CTRL", action = act({ MoveTabRelative = 1 }) },
    { key = "{", mods = "SHIFT|CTRL", action = act({ MoveTabRelative = -1 }) },
    { key = "t", mods = "SHIFT|CTRL", action = act({ SpawnTab = "CurrentPaneDomain" }) },
    { key = "w", mods = "SHIFT|CTRL", action = act({ CloseCurrentTab = { confirm = true } }) },
    -- window
    { key = "f", mods = "ALT", action = act.ToggleFullScreen },
    -- pane
    { key = "z", mods = "SHIFT|CTRL", action = act.TogglePaneZoomState },
    { key = "v", mods = "SHIFT|CTRL", action = act.SplitVertical({ domain =  "CurrentPaneDomain" }) },
    { key = "h", mods = "SHIFT|CTRL", action = act.SplitHorizontal({ domain =  "CurrentPaneDomain" }) },
    { key = "x", mods = "SHIFT|CTRL", action = act({ CloseCurrentPane = { confirm = true } }) },
    -- workspace
    {
      key = "w",
      mods = "LEADER",
      action = act.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" })
    },
    {
      key = "t",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "(wezterm) Set workspace title:",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
          end
        end),
      })
    },
    {
      key = "c",
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
    -- font
    { key = ")", mods = "SHIFT|CTRL", action = act.ResetFontSize },
    { key = "+", mods = "SHIFT|CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "SHIFT|CTRL", action = act.DecreaseFontSize },
    -- keytable
    {
      key = "a",
      mods = "LEADER",
      action = act.ActivateKeyTable({ name = "activate_pane", timeout_milliseconds = 1000 })
    },
    {
      key = "r",
      mods = "LEADER",
      action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false })
    },
    { key = "x", mods = "LEADER", action = act.ActivateCopyMode },
    -- others
    { key = "l", mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
    { key = "p", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
    { key = "r", mods = "SHIFT|CTRL", action = act.ReloadConfiguration },
    { key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
  },

  key_tables = {
    activate_pane = {
      { key = "h", mods = "NONE", action = act.ActivatePaneDirection("Left") },
      { key = "l", mods = "NONE", action = act.ActivatePaneDirection("Right") },
      { key = "k", mods = "NONE", action = act.ActivatePaneDirection("Up") },
      { key = "j", mods = "NONE", action = act.ActivatePaneDirection("Down") },
    },
    resize_pane = {
      { key = "h", mods = "NONE", action = act.AdjustPaneSize({ "Left", 1 }) },
      { key = "l", mods = "NONE", action = act.AdjustPaneSize({ "Right", 1 }) },
      { key = "k", mods = "NONE", action = act.AdjustPaneSize({ "Up", 1 }) },
      { key = "j", mods = "NONE", action = act.AdjustPaneSize({ "Down", 1 }) },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
      { key = "Enter", mods = "NONE", action = "PopKeyTable" },
    },
    copy_mode = {
      -- movement
      { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
      { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
      { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
      { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
      { key = "Tab", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
      { key = "Tab", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
      -- scroll
      { key = "d", mods = "NONE", action = act.CopyMode{ MoveByPage = (0.5) } },
      { key = "u", mods = "NONE", action = act.CopyMode{ MoveByPage = (-0.5) } },
      -- jump
      { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
      { key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
      { key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
      { key = "t", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
      { key = "f", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
      -- copy
      { key = "y", mods = "NONE", action = act.CopyTo("Clipboard") },
      -- close
      { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
      { key = "q", mods = "NONE", action = act.CopyMode("Close") },
    },
  }
}
