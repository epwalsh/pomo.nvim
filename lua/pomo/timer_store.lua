---This class is used to store all active timers.
---@class pomo.TimerStore
---@field timers pomo.Timer[]
local TimerStore = {}

---Initialize a new `pomo.TimerStore`.
---@return pomo.TimerStore
TimerStore.new = function()
  local self = setmetatable({}, { __index = TimerStore })
  self.timers = {}
  return self
end

---Get the first available ID for a new timer.
---@return integer
TimerStore.first_available_id = function(self)
  for i = 1, #self.timers do
    if self.timers[i] == nil then
      return i
    end
  end
  return #self.timers + 1
end

---Get the number of timers currently stored.
---@return integer
TimerStore.len = function(self)
  return vim.tbl_count(self.timers)
end

---Store a new timer.
---@param timer pomo.Timer
TimerStore.store = function(self, timer)
  assert(self.timers[timer.id] == nil)
  self.timers[timer.id] = timer
end

---Remove a timer from the store.
---@param timer integer|pomo.Timer
TimerStore.remove = function(self, timer)
  ---@type integer
  local timer_id
  if type(timer) == "number" then
    timer_id = timer
  else
    timer_id = timer.id
  end

  self.timers[timer_id] = nil
end

---Get a timer from the store by its ID.
---@param timer_id integer
---@return pomo.Timer|?
TimerStore.get = function(self, timer_id)
  return self.timers[timer_id]
end

---Pop a timer from the store.
---@param timer_id integer|?
---@return pomo.Timer|?
TimerStore.pop = function(self, timer_id)
  if timer_id == nil then
    if self:len() == 1 then
      -- note that the `#` operator always returns the highest non-nil index in an array,
      -- not necessarily its length, which is why this works.
      return self:pop(#self.timers)
    else
      -- TODO: stop oldest timer?
      return nil
    end
  else
    local timer = self:get(timer_id)
    if timer ~= nil then
      self:remove(timer)
    end
    return timer
  end
end

return TimerStore
