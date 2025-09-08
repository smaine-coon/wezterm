local wezterm = require 'wezterm'
local launch_menu = {}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    table.insert(launch_menu, {
        label = 'PowerShell',
        args = { 'powershell.exe', '-NoLogo' },
    })

    table.insert(launch_menu, {
        label = 'CMD',
        args = { 'cmd.exe' },
    })

    table.insert(launch_menu, {
        label = 'WSL: launch Ubuntu',
        args = { 'wsl.exe', '-d', 'Ubuntu' },
    })

    table.insert(launch_menu, {
        label = 'WSL: terminate Ubuntu',
        args = { 'wsl.exe', '--terminate', 'Ubuntu' },
    })

    table.insert(launch_menu, {
        label = 'WSL: launch docker-desktop',
        args = { 'wsl.exe', '-d', 'docker-desktop' },
    })

    table.insert(launch_menu, {
        label = 'WSL: terminate docker-desktop',
        args = { 'wsl.exe', '--terminate', 'docker-desktop' },
    })

end

return launch_menu