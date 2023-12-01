local log = require "pomo.log"
local util = require "pomo.util"

---A `pomo.Notifier` that sends a system notification when the timer is finished.
---@class pomo.SystemNotifier : pomo.Notifier
---@field timer pomo.Timer
---@field notification any
---@field opts table
local SystemNotifier = {}

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

return SystemNotifier
