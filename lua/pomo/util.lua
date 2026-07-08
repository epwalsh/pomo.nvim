---@class pomo.Util
local M = {}

---@enum pomo.OS
M.OS = {
  Darwin = "Darwin",
  Linux = "Linux",
  Windows = "Windows",
  Wsl = "Wsl",
}

---Get the running operating system.
---Reference https://vi.stackexchange.com/a/2577/33116
---@return pomo.OS os
function M.get_os()
  if vim.fn.has "win32" == 1 then
    return M.OS.Windows
  end

  local this_os = tostring(io.popen("uname"):read()) --[[@as pomo.OS]]
  if this_os == "Linux" and vim.fn.readfile("/proc/version")[1]:lower():match "microsoft" then
    this_os = M.OS.Wsl
  end
  return this_os
end

---Format a time in seconds into a human-readable string.
---@param time_left integer seconds
---@return string formatted_time
function M.format_time(time_left)
  if time_left <= 60 then
    return ("%ds"):format(time_left)
  end
  if time_left <= 300 then
    return os.date(math.fmod(time_left, 60) == 0 and "%Mm" or "%Mm %Ss", time_left)
  end
  if time_left < 3600 then
    return os.date("%Mm", time_left)
  end
  return os.date(math.fmod(time_left, 3600) == 0 and "%Hh" or "%Hh %Mm", time_left)
end

---Parse a time string into seconds.
---@param s string
---@return integer|? time
function M.parse_time(s)
  local time = 0 ---@type integer

  -- Hours.
  for _, pattern in ipairs { "([%d%.]+)%s*hours", "([%d%.]+)%s*hour", "([%d%.]+)%s*hr", "([%d%.]+)%s*h" } do
    local _, _, hours_str = s:find(pattern)
    if hours_str then
      time = time + tonumber(hours_str, 10) * 60 * 60
      break
    end
  end

  -- Minutes.
  for _, pattern in ipairs { "([%d%.]+)%s*minutes", "([%d%.]+)%s*minute", "([%d%.]+)%s*min", "([%d%.]+)%s*m" } do
    local _, _, minutes_str = s:find(pattern)
    if minutes_str then
      time = time + tonumber(minutes_str, 10) * 60
      break
    end
  end

  -- Seconds.
  for _, pattern in ipairs { "([%d%.]+)%s*seconds", "([%d%.]+)%s*second", "([%d%.]+)%s*sec", "([%d%.]+)%s*s" } do
    local _, _, seconds_str = s:find(pattern)
    if seconds_str then
      time = time + tonumber(seconds_str, 10)
      break
    end
  end

  return time <= 0 and tonumber(s, 10) or time -- default to seconds
end

return M
