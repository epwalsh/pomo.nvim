local util = require "pomo.util"
local log = require "pomo.log"

local M = {}

---@enum pomo.NotifierType
local NotifierType = {
  Default = "Default",
  System = "System",
}
M.NotifierType = NotifierType

---The abstract base class for notifiers. At a minimum each concrete implementation needs to provide
---the methods `self:tick()`, `self:start()`, `self:done()`, and `self:stop()`.
---See `pomo.DefaultNotifier` for an example.
---@class pomo.Notifier
local Notifier = {}
M.Notifier = Notifier

---Called periodically (e.g. every second) while the timer is active.
---@param time_left number
Notifier.tick = function(self, time_left) ---@diagnostic disable-line: unused-local
  error "not implemented"
end

---Called when the timer starts.
Notifier.start = function(self) ---@diagnostic disable-line: unused-local
  error "not implemented"
end

---Called when the timer finishes.
Notifier.done = function(self) ---@diagnostic disable-line: unused-local
  error "not implemented"
end

---Called when the timer is stopped before finishing.
Notifier.stop = function(self) ---@diagnostic disable-line: unused-local
  error "not implemented"
end

---The default implementation of `pomo.Notifier`, uses `vim.notify` to display the timer.
---@class pomo.DefaultNotifier : pomo.Notifier
---@field timer_id integer
---@field time_limit integer
---@field name string|?
---@field notification any
---@field opts table
---@field title_icon string
---@field text_icon string
DefaultNotifier = {}
M.DefaultNotifier = DefaultNotifier

---@param timer_id integer
---@param time_limit integer
---@param name string|?
---@param opts table|?
---@return pomo.DefaultNotifier
DefaultNotifier.new = function(timer_id, time_limit, name, opts)
  local self = setmetatable({}, { __index = DefaultNotifier })
  self.timer_id = timer_id
  self.time_limit = time_limit
  self.name = name
  self.notification = nil
  self.opts = opts and opts or {}
  self.title_icon = self.opts.title_icon and self.opts.title_icon or "󱎫"
  self.text_icon = self.opts.text_icon and self.opts.text_icon or "󰄉"
  return self
end

---@param text string
---@param level string|integer
---@param timeout boolean|integer
DefaultNotifier._update = function(self, text, level, timeout)
  ---@type string
  local title
  if self.name ~= nil then
    title = string.format("Timer #%d, %s, %s", self.timer_id, self.name, util.format_time(self.time_limit))
  else
    title = string.format("Timer #%d, %s", self.timer_id, util.format_time(self.time_limit))
  end
  self.notification = vim.notify(text, level, {
    icon = self.title_icon,
    title = title,
    timeout = timeout,
    replace = self.notification,
    hide_from_history = true,
  })
end

---@param time_left number
DefaultNotifier.tick = function(self, time_left)
  self:_update(string.format(" %s  %s left...", self.text_icon, util.format_time(time_left)), "info", false)
end

DefaultNotifier.start = function(self)
  self:_update(string.format(" %s  starting...", self.text_icon), "info", false)
end

DefaultNotifier.done = function(self)
  self:_update(string.format(" %s  timer done!", self.text_icon), "warn", 3000)
end

DefaultNotifier.stop = function(self)
  self:_update(string.format(" %s  stopping...", self.text_icon), "info", 1000)
end

---A `pomo.Notifier` that sends a system notification when the timer is finished.
---@class pomo.SystemNotifier : pomo.Notifier
---@field timer_id integer
---@field time_limit integer
---@field name string|?
---@field notification any
---@field opts table
SystemNotifier = {}
M.SystemNotifier = SystemNotifier

SystemNotifier.supported_oss = { util.OS.Darwin }

---@param timer_id integer
---@param time_limit integer
---@param name string|?
---@param opts table|?
---@return pomo.SystemNotifier
SystemNotifier.new = function(timer_id, time_limit, name, opts)
  if not vim.tbl_contains(SystemNotifier.supported_oss, util.get_os()) then
    error(string.format("SystemNotifier is not implemented for your OS (%s)", util.get_os()))
  end

  local self = setmetatable({}, { __index = SystemNotifier })
  self.timer_id = timer_id
  self.time_limit = time_limit
  self.name = name
  self.notification = nil
  self.opts = opts and opts or {}
  return self
end

---@param time_left number
SystemNotifier.tick = function(self, time_left) ---@diagnostic disable-line: unused-local
end

SystemNotifier.start = function(self) ---@diagnostic disable-line: unused-local
end

SystemNotifier.done = function(self) ---@diagnostic disable-line: unused-local
  if util.get_os() == util.OS.Darwin then
    os.execute(
      string.format(
        [[osascript -e 'display notification "Timer done!" with title "Timer #%d, %s" sound name "Ping"']],
        self.timer_id,
        util.format_time(self.time_limit)
      )
    )
  else
    return log.error("SystemNotifier is not implemented for your OS (%s)", util.get_os())
  end
end

SystemNotifier.stop = function(self) ---@diagnostic disable-line: unused-local
end

---Construct a `pomo.Notifier` given a notifier name (`pomo.NotifierType`) or factory function.
---@param opts pomo.NotifierConfig
---@param timer_id integer
---@param time_limit integer
---@param name string|?
---@return pomo.Notifier
M.build = function(opts, timer_id, time_limit, name)
  if (opts.name == nil) == (opts.init == nil) then
    error "invalid notifier config, 'name' and 'init' are mutually exclusive"
  end

  if opts.init ~= nil then
    assert(opts.init)
    return opts.init(timer_id, time_limit, name, opts)
  else
    assert(opts.name)
    if opts.name == NotifierType.Default then
      return DefaultNotifier.new(timer_id, time_limit, name, opts.opts)
    elseif opts.name == NotifierType.System then
      return SystemNotifier.new(timer_id, time_limit, name, opts.opts)
    else
      error(string.format("invalid notifier name '%s'", opts.name))
    end
  end
end

return M
