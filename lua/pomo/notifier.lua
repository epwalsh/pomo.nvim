---The abstract base class for notifiers. At a minimum each concrete implementation needs to provide
---the methods `self:tick()`, `self:start()`, `self:done()`, and `self:stop()`.
---Optionally they can also provide `self:hide()` and `self:show()` methods.
---See `pomo.DefaultNotifier` for an example.
---@class pomo.Notifier
local Notifier = {}

---Called periodically (e.g. every second) while the timer is active.
---@param _ integer
function Notifier:tick(_)
  error "not implemented"
end

---Called when the timer starts.
function Notifier:start()
  error "not implemented"
end

---Called when the timer finishes.
function Notifier:done()
  error "not implemented"
end

---Called when the timer is stopped before finishing.
function Notifier:stop()
  error "not implemented"
end

---Called to hide the timer's progress. Should have the opposite affect as `show()`.
function Notifier:hide() end

---Called to show the timer's progress. Should have the opposite affect as `hide()`.
function Notifier.show() end

return Notifier
