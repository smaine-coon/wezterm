local wezterm = require("wezterm")

local os_name = wezterm.target_triple

local de_env = table.concat({
  os.getenv("XDG_CURRENT_DESKTOP"),
  os.getenv("XDG_SESSION_DESKTOP"),
  os.getenv("GDMSESSION"),
  os.getenv("DESKTOP_SESSION")
}, " "):lower()

local function detect_de()
  if de_env:match("gnome") then return "gnome" end
  if de_env:match("kde") or de_env:match("plasma") then return "kde" end

  return nil
end

local M = {}

M.shell = {
  wsl = { "bash" },
  windows = { "powershell" },
  macos = { "zsh" },
  linux = { "bash" }
}

M.os = {
  is_wsl = wezterm.running_under_wsl() and true or false,
  is_windows = string.find(os_name, "windows") ~= nil,
  is_macos = string.find(os_name, "darwin") ~= nil,
  is_linux = string.find(os_name, "linux") ~= nil,
  de = detect_de()
}

M.opts = {
  theme_file_path =  wezterm.config_dir .. "/wez_theme.txt",
  default_dark_colorscheme = 'Gruvbox Dark (Gogh)',
  default_light_colorscheme = 'Gruvbox (Gogh)'
}

return M