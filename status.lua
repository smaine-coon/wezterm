local wezterm = require 'wezterm'

local bg_color = '#011627'
local fg_color = '#79429F'

local icon_battery = wezterm.nerdfonts.md_battery_50
local icon_battery_charging = wezterm.nerdfonts.md_battery_charging_50
local icon_clock = wezterm.nerdfonts.fa_clock
local icon_keyboard = wezterm.nerdfonts.fa_keyboard

local function addElement(elems, icon, str)
    table.insert(elems, { Background = { Color = bg_color } })
    table.insert(elems, { Foreground = { Color = fg_color } })
    table.insert(elems, { Text = icon .. '  ' .. str .. ' '})
end

local function getBattery(elems)
    local bat_icon = ''
    local bat_level = ''
    for _, b in ipairs(wezterm.battery_info()) do
        if b.state == 'Charging' then
            bat_icon = icon_battery_charging
        elseif b.state == 'Discharging' then
            bat_icon = icon_battery
        elseif b.state == 'Full' then
            bat_icon = icon_battery
        end
        bat_level = string.format('%.0f%%', b.state_of_charge * 100)
        addElement(elems, bat_icon, bat_level)
    end
end

local function getDateTime(elems)
    local date = wezterm.strftime '%a %b %-d'
    local time = wezterm.strftime '%H:%M'
    addElement(elems, icon_clock , date)
    addElement(elems, '', time)
end

local function getKeyboard(elems, window)
    if window:leader_is_active() then
        addElement(elems, icon_keyboard, 'LEADER')
        return
    end

    local key_table = window:active_key_table()
    local status = ''

    if key_table == 'copy_mode' then
        status = 'CopyMode'
    elseif key_table == 'resize_pane' then
        status = 'ResizePane'
    elseif key_table == 'activate_pane' then
        status = 'ActivatePane'
    else
        status = 'Normal'
    end

    addElement(elems, icon_keyboard, status)
end

wezterm.on('update-status', function(window, pane)
    local elems = {}
    
    getKeyboard(elems, window)
    getBattery(elems)
    getDateTime(elems)

    window:set_right_status(wezterm.format(elems))
end)