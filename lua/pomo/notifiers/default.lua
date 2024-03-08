local util = require "pomo.util"

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

  local ok, notify = pcall(require, "notify")
  if not ok then
    ---@diagnostic disable-next-line: cast-local-type
    notify = vim.notify
  end

  local notification = notify(text, level, {
    icon = self.title_icon,
    title = title,
    timeout = timeout,
    replace = self.notification,
    hide_from_history = true,
  })

  if self.sticky then
    self.notification = notification
  else
    self.notification = nil
  end
end

---@param time_left number
DefaultNotifier.tick = function(self, time_left)
  if self.sticky then
    self:_update(
      string.format(
        " %s  %s left...%s",
        self.text_icon,
        util.format_time(time_left),
        self.timer.paused and " (paused)" or ""
      ),
      vim.log.levels.INFO,
      false
    )
  end
end

DefaultNotifier.start = function(self)
  ---@type integer|boolean
  local timeout = false
  if not self.sticky then
    timeout = 1000
  end
  self:_update(string.format(" %s  starting...", self.text_icon), vim.log.levels.INFO, timeout)
end

DefaultNotifier.done = function(self)
  self:_update(string.format(" %s  timer done!", self.text_icon), vim.log.levels.WARN, 3000)
end

DefaultNotifier.stop = function(self)
  self:_update(string.format(" %s  stopping...", self.text_icon), vim.log.levels.INFO, 1000)
end

DefaultNotifier.hide = function(self)
  self.sticky = false
  self:_update(nil, vim.log.levels.INFO, 100)
end

DefaultNotifier.show = function(self)
  self.sticky = true
  local time_left = self.timer:time_remaining()
  if time_left ~= nil and time_left > 0 then
    self:tick(time_left)
  end
end

return DefaultNotifier
