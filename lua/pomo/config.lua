local NotifierType = require("pomo.notifiers").NotifierType

---@class pomo.Config
local Config = {}

---@class pomoOpts
---@field update_interval integer
---@field notifiers pomo.NotifierConfig[]
---@field timers table<string, pomo.NotifierConfig[]>
---@field sessions table<string, pomo.SessionConfig[]>  -- Add sessions field

---@class pomo.NotifierConfig
---@field name? pomo.NotifierType
---@field init? fun(timer_id: integer, time_limit: integer, name: string, opts: table): notifier: pomo.Notifier function(timer_id, time_limit, name, opts)
---@field opts? table

---@class pomo.SessionConfig  -- Define session config
---@field name string
---@field duration string

---@return pomoOpts config
function Config.default()
  return {
    update_interval = 1000,
    notifiers = { { name = NotifierType.Default } },
    timers = {},
    sessions = {}, -- Initialize sessions
  }
end

---@param opts? pomoOpts
---@return pomoOpts config
function Config.normalize(opts)
  return vim.tbl_extend("force", Config.default(), opts or {})
end

return Config
