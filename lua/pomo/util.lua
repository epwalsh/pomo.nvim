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

return M
