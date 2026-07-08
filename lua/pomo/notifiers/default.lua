local util = require "pomo.util"

---The default implementation of `pomo.Notifier`, uses `vim.notify` to display the timer.
---@class pomo.DefaultNotifier : pomo.Notifier
---@field _last_text? string
---@field notification any
---@field opts table
---@field sticky boolean
---@field text_icon string
---@field timer pomo.Timer
---@field title_icon string
local DefaultNotifier = {}

---@param timer pomo.Timer
---@param opts? table
---@return pomo.DefaultNotifier notifier
function DefaultNotifier.new(timer, opts)
  local self = setmetatable({}, { __index = DefaultNotifier })
  self.timer = timer
  self.notification = nil
  self.opts = opts or {}
  self.title_icon = self.opts.title_icon and self.opts.title_icon or "󱎫"
  self.text_icon = self.opts.text_icon and self.opts.text_icon or "󰄉"
  self.sticky = self.opts.sticky ~= false
  self._last_text = nil
  return self
end

---@param text? string
---@param level string|integer
---@param timeout boolean|integer
function DefaultNotifier:_update(text, level, timeout)
  local repetitions_str = ""
  if self.timer.max_repetitions and self.timer.max_repetitions > 0 then
    repetitions_str = (" [%d/%d]"):format(self.timer.repetitions + 1, self.timer.max_repetitions)
  end

  local title ---@type string
  if self.timer.name then
    title = ("Timer #%d, %s, %s%s"):format(
      self.timer.id,
      self.timer.name,
      util.format_time(self.timer.time_limit),
      repetitions_str
    )
  else
    title = ("Timer #%d, %s%s"):format(self.timer.id, util.format_time(self.timer.time_limit), repetitions_str)
  end

  if not (text or self._last_text) then
    return
  end
  if text then
    self._last_text = text
  else
    text = self._last_text
  end

  assert(text)

  local ok, notif = pcall(require, "notify")
  local notify = not (ok and notif) and vim.notify or notif

  local notification = notify(text, level, {
    icon = self.title_icon,
    title = title,
    timeout = timeout,
    replace = self.notification,
    hide_from_history = true,
  })

  self.notification = self.sticky and notification or nil
end

---@param time_left integer
function DefaultNotifier:tick(time_left)
  if not self.sticky then
    return
  end
  self:_update(
    (" %s  %s left...%s"):format(self.text_icon, util.format_time(time_left), self.timer.paused and " (paused)" or ""),
    vim.log.levels.INFO,
    false
  )
end

function DefaultNotifier:start()
  self:_update((" %s  starting..."):format(self.text_icon), vim.log.levels.INFO, self.sticky and false or 2000)
end

function DefaultNotifier:done()
  self:_update((" %s  timer done!"):format(self.text_icon), vim.log.levels.WARN, 3000)
end

function DefaultNotifier:stop()
  self:_update((" %s  stopping..."):format(self.text_icon), vim.log.levels.INFO, 1000)
end

function DefaultNotifier:hide()
  self.sticky = false
  self:_update(nil, vim.log.levels.INFO, 100)
end

function DefaultNotifier:show()
  self.sticky = true
  local time_left = self.timer:time_remaining()
  if time_left and time_left > 0 then
    self:tick(time_left)
  end
end

return DefaultNotifier
