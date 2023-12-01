local NotifierType = require("pomo.notifiers").NotifierType

local Config = {}

---@class pomo.Config
---@field update_interval integer
---@field notifiers pomo.NotifierConfig[]
---@field timers table<string, pomo.NotifierConfig[]>

---@class pomo.NotifierConfig
---@field name pomo.NotifierType|?
---@field init function|? function(timer_id, time_limit, name, opts)
---@field opts table|?

---@return pomo.Config
Config.default = function()
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
Config.normalize = function(opts)
  return vim.tbl_extend("force", Config.default(), opts)
end

return Config
