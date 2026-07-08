---@param msg string
---@param level integer
local function _log(msg, level, ...)
  msg = msg:format(...)
  vim.schedule(function()
    vim.notify(msg, level)
  end)
end

---@class pomo.Log
local M = {}

---@param msg string
function M.debug(msg, ...)
  _log(msg, vim.log.levels.DEBUG, ...)
end

---@param msg string
function M.info(msg, ...)
  _log(msg, vim.log.levels.INFO, ...)
end

---@param msg string
function M.warn(msg, ...)
  _log(msg, vim.log.levels.WARN, ...)
end

---@param msg string
function M.error(msg, ...)
  _log(msg, vim.log.levels.ERROR, ...)
end

return M
