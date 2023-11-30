local M = {}

---@enum pomo.OS
M.OS = {
  Linux = "Linux",
  Wsl = "Wsl",
  Windows = "Windows",
  Darwin = "Darwin",
}

---Get the running operating system.
---Reference https://vi.stackexchange.com/a/2577/33116
---@return pomo.OS
M.get_os = function()
  if vim.fn.has "win32" == 1 then
    return M.OS.Windows
  end

  local this_os = tostring(io.popen("uname"):read())
  if this_os == "Linux" and vim.fn.readfile("/proc/version")[1]:lower():match "microsoft" then
    this_os = M.OS.Wsl
  end
  return this_os
end

---Format a time in seconds into a human-readable string.
---@param time_left number seconds
---@return string
M.format_time = function(time_left)
  if time_left <= 60 then
    return string.format("%ds", time_left)
  elseif time_left <= 300 then
    if math.fmod(time_left, 60) == 0 then
      return os.date("%Mm", time_left) ---@diagnostic disable-line: return-type-mismatch
    else
      return os.date("%Mm %Ss", time_left) ---@diagnostic disable-line: return-type-mismatch
    end
  elseif time_left < 3600 then
    return os.date("%Mm", time_left) ---@diagnostic disable-line: return-type-mismatch
  else
    if math.fmod(time_left, 3600) == 0 then
      return os.date("%Hh", time_left) ---@diagnostic disable-line: return-type-mismatch
    else
      return os.date("%Hh %Mm", time_left) ---@diagnostic disable-line: return-type-mismatch
    end
  end
end

---Parse a time string into seconds.
---@param s string
---@return number|?
M.parse_time = function(s)
  ---@type number
  local time = 0

  -- Hours.
  for _, pattern in ipairs { "([%d%.]+)%s*hours", "([%d%.]+)%s*hour", "([%d%.]+)%s*hr", "([%d%.]+)%s*h" } do
    local _, _, hours_str = string.find(s, pattern)
    if hours_str ~= nil then
      time = time + tonumber(hours_str) * 60 * 60
      break
    end
  end

  -- Minutes.
  for _, pattern in ipairs { "([%d%.]+)%s*minutes", "([%d%.]+)%s*minute", "([%d%.]+)%s*min", "([%d%.]+)%s*m" } do
    local _, _, minutes_str = string.find(s, pattern)
    if minutes_str ~= nil then
      time = time + tonumber(minutes_str) * 60
      break
    end
  end

  -- Seconds.
  for _, pattern in ipairs { "([%d%.]+)%s*seconds", "([%d%.]+)%s*second", "([%d%.]+)%s*sec", "([%d%.]+)%s*s" } do
    local _, _, seconds_str = string.find(s, pattern)
    if seconds_str ~= nil then
      time = time + tonumber(seconds_str)
      break
    end
  end

  if time <= 0 then
    return tonumber(s) -- default to seconds
  else
    return time
  end
end

return M
