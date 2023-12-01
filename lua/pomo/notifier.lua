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
---Optionally they can also provide `self:hide()` and `self:show()` methods.
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

---Called to hide the timer's progress. Should have the opposite affect as `show()`.
Notifier.hide = function(self) end ---@diagnostic disable-line: unused-local

---Called to show the timer's progress. Should have the opposite affect as `hide()`.
Notifier.show = function(self) end ---@diagnostic disable-line: unused-local

---The default implementation of `pomo.Notifier`, uses `vim.notify` to display the timer.
---@class pomo.DefaultNotifier : pomo.Notifier
---@field timer pomo.Timer
---@field notification any
---@field opts table
---@field title_icon string
---@field text_icon string
---@field sticky boolean
---@field _last_text string|?
local DefaultNotifier = {}
M.DefaultNotifier = DefaultNotifier

---@param timer pomo.Timer
---@param opts table|?
---@return pomo.DefaultNotifier
DefaultNotifier.new = function(timer, opts)
  local self = setmetatable({}, { __index = DefaultNotifier })
  self.timer = timer
  self.notification = nil
  self.opts = opts and opts or {}
  self.title_icon = self.opts.title_icon and self.opts.title_icon or "󱎫"
  self.text_icon = self.opts.text_icon and self.opts.text_icon or "󰄉"
  self.sticky = self.opts.sticky ~= false
  self._last_text = nil
  return self
end

---@param text string|?
---@param level string|integer
---@param timeout boolean|integer
DefaultNotifier._update = function(self, text, level, timeout)
  local repetitions_str = ""
  if self.timer.max_repetitions ~= nil and self.timer.max_repetitions > 0 then
    repetitions_str = string.format(" [%d/%d]", self.timer.repetitions + 1, self.timer.max_repetitions)
  end

  ---@type string
  local title
  if self.timer.name ~= nil then
    title = string.format(
      "Timer #%d, %s, %s%s",
      self.timer.id,
      self.timer.name,
      util.format_time(self.timer.time_limit),
      repetitions_str
    )
  else
    title = string.format("Timer #%d, %s%s", self.timer.id, util.format_time(self.timer.time_limit), repetitions_str)
  end

  if text ~= nil then
    self._last_text = text
  elseif not self._last_text then
    return
  else
    text = self._last_text
  end

  assert(text)

  self.notification = vim.notify(text, level, {
    icon = self.title_icon,
    title = title,
    timeout = timeout,
    replace = self.sticky and self.notification or nil,
    hide_from_history = true,
  })
end

---@param time_left number
DefaultNotifier.tick = function(self, time_left)
  if self.sticky then
    self:_update(string.format(" %s  %s left...", self.text_icon, util.format_time(time_left)), "info", false)
  end
end

DefaultNotifier.start = function(self)
  ---@type integer|boolean
  local timeout = false
  if not self.sticky then
    timeout = 1000
  end
  self:_update(string.format(" %s  starting...", self.text_icon), "info", timeout)
end

DefaultNotifier.done = function(self)
  self:_update(string.format(" %s  timer done!", self.text_icon), "warn", 3000)
end

DefaultNotifier.stop = function(self)
  self:_update(string.format(" %s  stopping...", self.text_icon), "info", 1000)
end

DefaultNotifier.hide = function(self)
  self:_update(nil, "info", 100)
  self.sticky = false
end

DefaultNotifier.show = function(self)
  self.sticky = true
  local time_left = self.timer:time_remaining()
  if time_left ~= nil and time_left > 0 then
    self:tick(time_left)
  end
end

---A `pomo.Notifier` that sends a system notification when the timer is finished.
---@class pomo.SystemNotifier : pomo.Notifier
---@field timer pomo.Timer
---@field notification any
---@field opts table
local SystemNotifier = {}
M.SystemNotifier = SystemNotifier

SystemNotifier.supported_oss = { util.OS.Darwin }

---@param timer pomo.Timer
---@param opts table|?
---@return pomo.SystemNotifier
SystemNotifier.new = function(timer, opts)
  if not vim.tbl_contains(SystemNotifier.supported_oss, util.get_os()) then
    error(string.format("SystemNotifier is not implemented for your OS (%s)", util.get_os()))
  end

  local self = setmetatable({}, { __index = SystemNotifier })
  self.timer = timer
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
  local repetitions_str = ""
  if self.timer.max_repetitions ~= nil and self.timer.max_repetitions > 0 then
    repetitions_str = string.format(" [%d/%d]", self.timer.repetitions + 1, self.timer.max_repetitions)
  end

  if util.get_os() == util.OS.Darwin then
    os.execute(
      string.format(
        [[osascript -e 'display notification "Timer done!" with title "Timer #%d, %s%s" sound name "Ping"']],
        self.timer.id,
        util.format_time(self.timer.time_limit),
        repetitions_str
      )
    )
  else
    return log.error("SystemNotifier is not implemented for your OS (%s)", util.get_os())
  end
end

SystemNotifier.stop = function(self) ---@diagnostic disable-line: unused-local
end

---Construct a `pomo.Notifier` given a notifier name (`pomo.NotifierType`) or factory function.
---@param timer pomo.Timer
---@param opts pomo.NotifierConfig
---@return pomo.Notifier
M.build = function(timer, opts)
  if (opts.name == nil) == (opts.init == nil) then
    error "invalid notifier config, 'name' and 'init' are mutually exclusive"
  end

  if opts.init ~= nil then
    assert(opts.init)
    return opts.init(timer, opts)
  else
    assert(opts.name)
    if opts.name == NotifierType.Default then
      return DefaultNotifier.new(timer, opts.opts)
    elseif opts.name == NotifierType.System then
      return SystemNotifier.new(timer, opts.opts)
    else
      error(string.format("invalid notifier name '%s'", opts.name))
    end
  end
end

return M
