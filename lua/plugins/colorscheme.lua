local function get_background_scheme()
  local os = vim.loop.os_uname().sysname

  if os == "Windows_NT" then
    -- Windows: AppsUseLightTheme = 0 means dark mode
    local handle = io.popen(
      "powershell -NoProfile -Command \"(Get-ItemProperty 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize).AppsUseLightTheme\""
    )
    local result = handle:read("*a")
    handle:close()

    if result:match("0") then
      return "dark"
    else
      return "light"
    end
  elseif os == "Linux" then
    -- Linux GNOME/GTK setting
    local handle = io.popen(
      "gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null"
    )
    local result = handle:read("*a")
    handle:close()

    if result:match("prefer%-dark") then
      return "dark"
    else
      return "light"
    end
  end
end

local scheme = get_background_scheme

if scheme == "dark" then
  return {
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "catppuccin-macchiato",
      },
    },
  }
else
  return {
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "catppuccin-latte",
      },
    },
  }
end
