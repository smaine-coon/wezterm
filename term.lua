local wezterm = require("wezterm")

local env = require("env")

local function build_cmd(shell, de)
  local cmd = nil

  if de == "gnome" then
    cmd = [[gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null]]
  elseif de == "kde" then
    cmd = [[kreadconfig5 --file kdeglobals --group "General" --key "ColorScheme" 2>/dev/null]]
  end

  if shell == "fish" and cmd then
    cmd = cmd:gsub("2>%s*/dev/null", "^/dev/null")
  end

  return cmd
end

local function get_de_appearance(shell, cmd)
  if not cmd then
    return nil
  end

  local success, stdout = wezterm.run_child_process({
    shell, "-c", cmd
  })

  if not success then
    return nil
  end

  local out = (stdout or ""):gsub("\n", "")

  return out
end

local M = {}

function M.get_appearance()
 if env.os.is_windows or env.os.is_macos then
    local appearance = wezterm.gui and wezterm.gui.get_appearance() or "Dark"
    appearance = appearance:lower()
    return appearance:find("dark") and "dark" or "light"
  elseif env.os.is_wsl then
    local shell = env.shell.wsl[1]
    local cmd = build_cmd(shell, env.os.de)
    local appearance =  get_de_appearance(shell, cmd) or "dark"
    appearance = appearance:lower()
    return appearance:find("dark") and "dark" or "light"
  elseif env.os.is_linux then
    local shell = env.shell.linux[1]
    local cmd = build_cmd(shell, env.os.de)
    local appearance =  get_de_appearance(shell, cmd) or "dark"
    appearance = appearance:lower()
    return appearance:find("dark") and "dark" or "light"
  else
    return "dark"
  end
end

function M.load_theme_file()
  local N = {}

  local f = io.open(env.opts.theme_file_path, "r")

  if  not f then
    N.dark_scheme = env.opts.default_dark_colorscheme
    N.light_scheme = env.opts.default_light_colorscheme
    return N
  end

  local dark_scheme = f:read("*l")
  local light_scheme = f:read("*l")

  f:close()

  if dark_scheme and #dark_scheme > 0 then
    N.dark_scheme = dark_scheme
  end
  if light_scheme and #light_scheme > 0 then
    N.light_scheme = light_scheme
  end

  return N
end

function M.save_theme_file(colorscheme)
  local appearance = M.get_appearance()

  local f = io.open(env.opts.theme_file_path, "r")

  local lines = {"", ""}

  if f then
    for i = 1, 2 do
      lines[i] = f:read("*l") or ""
    end
    
    f:close()
  end

  if appearance == "light" then
    lines[2] = colorscheme
  else
    lines[1] = colorscheme
  end

  f = io.open(env.opts.theme_file_path, "w")

  if f then
    for _, line in ipairs(lines) do
        f:write(line .. "\n")
    end

    f:close()
  else
    wezterm.log_error("Error: Failed to open theme file for writing: " .. env.opts.theme_file_path)
  end
end

function M.set_colorscheme()
  local appearance = M.get_appearance()

  local theme_ls = M.load_theme_file()

  if appearance == "light" then
    return theme_ls.light_scheme
  else
    return theme_ls.dark_scheme
  end
end


return M