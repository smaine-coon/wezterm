local wezterm = require("wezterm")

local M = {}

M.base_name = function(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

M.detect_os = function()
  local os_name = wezterm.target_triple

  if wezterm.running_under_wsl() then
    return "wsl"
  elseif string.find(os_name, "windows") ~= nil then
    return "windows"
  elseif string.find(os_name, "darwin") ~= nil then
    return "macos"
  elseif string.find(os_name, "linux") ~= nil then
    return "linux"
  else
    return "unknown"
  end
end

M.get_system_appearance = function()
  local os_name = M.detect_os()

  if os_name == "windows" or os_name == "macos" then
    local appearance = wezterm.gui and wezterm.gui.get_appearance() or "Dark"
    if appearance:find("Dark") then
      return "Dark"
    else
      return "Light"
    end
  elseif os_name == "linux" or os_name == "wsl" then
    local success, stdout = wezterm.run_child_process({
      "bash",
      "-c",
      [[
      if command -v gsettings >/dev/null 2>&1; then
        gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null
      elif command -v kreadconfig5 >/dev/null 2>&1; then
        kreadconfig5 --file kdeglobals --group "General" --key "ColorScheme" 2>/dev/null
      else
        echo "unknown"
      fi
      ]],
    })
    local out = ((stdout or ""):gsub("\n","")):lower()
    if out:find("dark") then
      return "Dark"
    else
      return "Light"
    end
  else
    return "Dark"
  end
end

M.load_theme = function()
  local theme_file =  wezterm.config_dir .. "/wez_theme.txt"

  local default_dark_scheme = 'Gruvbox Dark (Gogh)'
  local default_light_scheme = 'Gruvbox (Gogh)'

  local N = {}

  N.dark_scheme = default_dark_scheme
  N.light_scheme = default_light_scheme

  local f = io.open(theme_file, "r")

  if f then
    local dark_scheme = f:read("*l")
    local light_scheme = f:read("*l")
    
    f:close()

    if dark_scheme and #dark_scheme > 0 then
      N.dark_scheme = dark_scheme
    end
    if light_scheme and #light_scheme > 0 then
      N.light_scheme = light_scheme
    end
  end

  return N
end

M.save_theme = function(appearance, theme)
  local theme_file =  wezterm.config_dir .. "/wez_theme.txt"

  local f = io.open(theme_file, "r")

  local lines = {"", ""}

  if f then
    for i = 1, 2 do
      lines[i] = f:read("*l") or ""
    end
    
    f:close()
  end

  if appearance == "Light" then
    lines[2] = theme
  else
    lines[1] = theme
  end

  f = io.open(theme_file, "w")

  if f then
    for _, line in ipairs(lines) do
        f:write(line .. "\n")
    end

    f:close()
  else
    wezterm.log_error("Error: Failed to open theme file for writing: " .. theme_file)
  end
end

M.set_appearance = function(appearance)
  local N = M.load_theme()

  if appearance == "Light" then
    return N.light_scheme
  else
    return N.dark_scheme
  end
end

return M