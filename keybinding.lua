local wezterm = require 'wezterm'
local act = wezterm.action

return {
    leader = { key = 'k', mods = 'CTRL', timeout_milliseconds = 1000 },

    keys = {
        -- work space
        { key = 'w', mods = 'SUPER', action = act.ShowLauncherArgs({ flags = 'WORKSPACES', title = 'Select workspace' }) },
        -- rename work space
        { key = '2', mods = 'SUPER', 
            action = act.PromptInputLine({ description = '(wezterm) Set workspace title:', 
            action = wezterm.action_callback(function(win, pane, line)
                if line then
                    wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
                end
            end),
        }),
        },
        -- work space menu
        {
            key = 'l', mods = 'SUPER',
            action = wezterm.action_callback (function (win, pane)
            -- create a list of workspace names
            local workspaces = {}
            for i, name in ipairs(wezterm.mux.get_workspace_names()) do
                table.insert(workspaces, {
                id = name,
                label = string.format('%d. %s', i, name),
                })
            end
            local current = wezterm.mux.get_active_workspace()
            -- Open the dropdown menu
            win:perform_action(act.InputSelector {
                action = wezterm.action_callback(function (_, _, id, label)
                if not id and not label then
                    wezterm.log_info 'Workspace selection canceled'
                else
                    win:perform_action(act.SwitchToWorkspace { name = id }, pane)
                end
                end),
                title = 'Select workspace',
                choices = workspaces,
                fuzzy = true,              
            }, pane)
            end),
        },
        -- tab
        { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
        { key = 'Tab', mods = 'SHIFT|CTRL', action = act.ActivateTabRelative(-1) },
        { key = '1', mods = 'CTRL', action = act.ActivateTab(0) },
        { key = '2', mods = 'CTRL', action = act.ActivateTab(1) },
        { key = '3', mods = 'CTRL', action = act.ActivateTab(2) },
        { key = '4', mods = 'CTRL', action = act.ActivateTab(3) },
        { key = '5', mods = 'CTRL', action = act.ActivateTab(4) },
        { key = '6', mods = 'CTRL', action = act.ActivateTab(5) },
        { key = '7', mods = 'CTRL', action = act.ActivateTab(6) },
        { key = '8', mods = 'CTRL', action = act.ActivateTab(7) },
        { key = '9', mods = 'CTRL', action = act.ActivateTab(-1) },
        -- current window
        { key = 'f', mods = 'Alt', action = act.ToggleFullScreen },
        { key = 'z', mods = 'Alt', action = act.TogglePaneZoomState },
        { key = 'v', mods = 'LEADER', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
        { key = 'h', mods = 'LEADER', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
        { key = 'c', mods = 'LEADER', action = act({ CloseCurrentPane = { confirm = true } }) },
        { key = 'c', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
        { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
        { key = 'l', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
        { key = 'l', mods = 'Alt', action = wezterm.action.ShowLauncher },
        { key = 'n', mods = 'Alt', action = act.Hide },
        { key = 't', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
        { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab{ confirm = true } },  
        { key = 'p', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
        { key = 'r', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration }, 
        -- activate a key table
        { key = 'x', mods = 'LEADER', action = act.ActivateCopyMode },
        { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable({ name = 'resize_pane', one_shot = false }) },
        { key = 'a', mods = 'LEADER', action = act.ActivateKeyTable({ name = 'activate_pane', timeout_milliseconds = 1000 }) },
    },

    key_tables = {
        copy_mode = {
            { key = 'Tab', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
            { key = 'Tab', mods = 'SHIFT', action = act.CopyMode 'MoveBackwardWord' },
            { key = 'Enter', mods = 'NONE', action = act.CopyMode 'MoveToStartOfNextLine' },
            { key = 'Escape', mods = 'NONE', action = act.Multiple{ 'ScrollToBottom', { CopyMode =  'Close' } } },
            { key = 'q', mods = 'NONE', action = act.Multiple{ 'ScrollToBottom', { CopyMode =  'Close' } } },
            { key = 'Space', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Cell' } },
            { key = 'v', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Line' } },
            { key = 'v', mods = 'CTRL', action = act.CopyMode{ SetSelectionMode =  'Block' } },
            { key = '4', mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
            { key = ',', mods = 'NONE', action = act.CopyMode 'JumpReverse' },
            { key = ';', mods = 'NONE', action = act.CopyMode 'JumpAgain' },
            { key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
            { key = 'f', mods = 'NONE', action = act.CopyMode{ JumpForward = { prev_char = false } } },
            { key = 't', mods = 'NONE', action = act.CopyMode{ JumpForward = { prev_char = true } } },
            { key = 'f', mods = 'SHIFT', action = act.CopyMode{ JumpBackward = { prev_char = false } } },
            { key = 't', mods = 'SHIFT', action = act.CopyMode{ JumpBackward = { prev_char = true } } },
            { key = 'g', mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
            { key = 'h', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportTop' },
            { key = 'l', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportBottom' },
            { key = 'm', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportMiddle' },
            { key = 'o', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEnd' },
            { key = 'o', mods = 'SHIFT', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
            { key = '^', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLineContent' },
            { key = 'b', mods = 'CTRL', action = act.CopyMode 'PageUp' },
            { key = 'f', mods = 'CTRL', action = act.CopyMode 'PageDown' },
            { key = 'd', mods = 'CTRL', action = act.CopyMode{ MoveByPage = (0.5) } },
            { key = 'u', mods = 'CTRL', action = act.CopyMode{ MoveByPage = (-0.5) } },
            { key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWordEnd' },
            { key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
            { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
            { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
            { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
            { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'MoveDown' },
            { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
            { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'MoveUp' },
            { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
            { key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },
            { key = 'y', mods = 'NONE', action = act.Multiple{ { CopyTo =  'ClipboardAndPrimarySelection' }, { Multiple = { 'ScrollToBottom', { CopyMode =  'Close' } } } } },
        },

        resize_pane = {
        { key = 'h', action = act.AdjustPaneSize({ 'Left', 1 }) },
        { key = 'l', action = act.AdjustPaneSize({ 'Right', 1 }) },
        { key = 'k', action = act.AdjustPaneSize({ 'Up', 1 }) },
        { key = 'j', action = act.AdjustPaneSize({ 'Down', 1 }) },
        { key = 'Escape', action = 'PopKeyTable' },
        { key = 'Enter', action = 'PopKeyTable' },
        },

        activate_pane = {
        { key = 'h', action = act.ActivatePaneDirection('Left') },
        { key = 'l', action = act.ActivatePaneDirection('Right') },
        { key = 'k', action = act.ActivatePaneDirection('Up') },
        { key = 'j', action = act.ActivatePaneDirection('Down') },
        },
    }
}
