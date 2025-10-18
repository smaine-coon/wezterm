local wezterm = require("wezterm")

local base_name = function(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local detect_os = function()
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

return {
  base_name = base_name,
  detect_os = detect_os,
}