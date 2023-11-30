local NotifierType = require("pomo.notifier").NotifierType
local M = {}

---@class pomo.Config
---@field update_interval integer
---@field notifiers pomo.NotifierConfig[]
---@field timers table<string, pomo.NotifierConfig[]>

---@class pomo.NotifierConfig
---@field name pomo.NotifierType|?
---@field init function|? function(timer_id, time_limit, name, opts)
---@field opts table|?

---@return pomo.Config
M.default = function()
  return {
    update_interval = 1000,
    notifiers = {
      { name = NotifierType.Default },
    },
    timers = {},
  }
end

---@param opts table|pomo.Config
---@return pomo.Config
M.normalize = function(opts)
  return vim.tbl_extend("force", M.default(), opts)
end

return M
