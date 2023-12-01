---The abstract base class for notifiers. At a minimum each concrete implementation needs to provide
---the methods `self:tick()`, `self:start()`, `self:done()`, and `self:stop()`.
---Optionally they can also provide `self:hide()` and `self:show()` methods.
---See `pomo.DefaultNotifier` for an example.
---@class pomo.Notifier
local Notifier = {}

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

return Notifier
