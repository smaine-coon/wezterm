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
    local out = (stdout or ""):lower()
    if out:find("dark") then
      return "Dark"
    else
      return "Light"
    end
  else
    return "Dark"
  end
end

M.set_appearance = function(appearance)
  if appearance == "Light" then
    return 'Gruvbox (Gogh)'
  else
    return 'Gruvbox Dark (Gogh)'
  end
end

return M