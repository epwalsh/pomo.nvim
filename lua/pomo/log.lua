local M = {}

---@param msg string
---@param level integer
M._log = function(msg, level, ...)
  msg = string.format(msg, ...)
  vim.schedule(function()
    vim.notify(msg, level)
  end)
end

---@param msg string
M.debug = function(msg, ...)
  M._log(msg, vim.log.levels.DEBUG, ...)
end

---@param msg string
M.info = function(msg, ...)
  M._log(msg, vim.log.levels.INFO, ...)
end

---@param msg string
M.warn = function(msg, ...)
  M._log(msg, vim.log.levels.WARN, ...)
end

---@param msg string
M.error = function(msg, ...)
  M._log(msg, vim.log.levels.ERROR, ...)
end

return M
