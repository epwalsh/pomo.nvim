local NotifierType = require("pomo.notifiers").NotifierType

local Config = {}

---@class pomo.Config
---@field update_interval integer
---@field notifiers pomo.NotifierConfig[]
---@field timers table<string, pomo.NotifierConfig[]>
---@field sessions table<string, pomo.SessionConfig[]>  -- Add sessions field

---@class pomo.NotifierConfig
---@field name pomo.NotifierType|?
---@field init function|? function(timer_id, time_limit, name, opts)
---@field opts table|?

---@class pomo.SessionConfig  -- Define session config
---@field name string
---@field duration string

---@return pomo.Config
Config.default = function()
  return {
    update_interval = 1000,
    notifiers = {
      { name = NotifierType.Default },
    },
    timers = {},
    sessions = {}, -- Initialize sessions
  }
end

---@param opts table|pomo.Config
---@return pomo.Config
Config.normalize = function(opts)
  return vim.tbl_extend("force", Config.default(), opts)
end

return Config
