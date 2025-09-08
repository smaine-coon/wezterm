local wezterm = require 'wezterm'

-- window title
local function baseName(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on('format-window-title', function(tab)
    return baseName(tab.active_pane.foreground_process_name)
end)

-- tab title
local bg_color = {'#00a381', '#212121'}
local fg_color = {'#000000', '#235689'}

local icon_left_circle = wezterm.nerdfonts.ple_left_half_circle_thick
local icon_right_circle = wezterm.nerdfonts.ple_right_half_circle_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local index = tab.is_active and 1 or 2
    local zoomed = tab.active_pane.is_zoomed and 'Z: ' or ' '

    local title = baseName(tab.active_pane.title)

    return {
        { Background = { Color = 'none' } },
        { Foreground = { Color = bg_color[index] } },
        { Text = icon_left_circle },

        { Background = { Color = bg_color[index] } },
        { Foreground = { Color = fg_color[index] } },
        { Text = zoomed },

        { Background = { Color = bg_color[index] } },
        { Foreground = { Color = fg_color[index] } },
        { Text = title },

        { Background = { Color = 'none' } },
        { Foreground = { Color = bg_color[index] } },
        { Text = icon_right_circle },
    }
end)