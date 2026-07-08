---This class is used to store all active timers.
---@class pomo.TimerStore
---@field timers pomo.Timer[]
local TimerStore = {}

---Initialize a new `pomo.TimerStore`.
---@return pomo.TimerStore timer_store
function TimerStore.new()
  return setmetatable({ timers = {} }, { __index = TimerStore })
end

---Get the first available ID for a new timer.
---@return integer id
function TimerStore:first_available_id()
  for i = 1, #self.timers do
    if not self.timers[i] then
      return i
    end
  end
  return #self.timers + 1
end

---Get the number of timers currently stored.
---@return integer timers
function TimerStore:len()
  return vim.tbl_count(self.timers)
end

---Check if the timer store is empty.
---@return boolean empty
function TimerStore:is_empty()
  return self:len() == 0
end

---Store a new timer.
---@param timer pomo.Timer
function TimerStore:store(timer)
  assert(self.timers[timer.id] == nil)
  self.timers[timer.id] = timer
end

---Remove a timer from the store.
---@param timer integer|pomo.Timer
function TimerStore:remove(timer)
  self.timers[type(timer) == "number" and timer or timer.id] = nil
end

---Get a timer from the store by its ID.
---@param timer_id integer
---@return pomo.Timer|? timer
function TimerStore:get(timer_id)
  return self.timers[timer_id]
end

---Get the latest timer (last one started).
---@return pomo.Timer|? latest
function TimerStore:get_latest()
  local latest_timer = nil ---@type pomo.Timer|nil
  local latest_start_time = nil ---@type integer|nil
  for _, t in pairs(self.timers) do
    if not (latest_timer and latest_start_time and t.start_time) or t.start_time > latest_start_time then
      latest_timer = t
      latest_start_time = t.start_time
    end
  end

  return latest_timer
end

---Get the first timer to finish next (minimum time remaining) out of all active timers.
---@return pomo.Timer|? first_to_finish
function TimerStore:get_first_to_finish()
  local min_timer = nil ---@type pomo.Timer|nil
  local min_time_left = nil ---@type integer|nil
  for _, t in pairs(self.timers) do
    local time_left = t:time_remaining()
    if time_left and not min_time_left or time_left < min_time_left then
      min_timer = t
      min_time_left = time_left
    end
  end

  return min_timer
end

---Get a list of all active timers.
---@return pomo.Timer[] all_timers
function TimerStore:get_all()
  return vim.tbl_values(self.timers)
end

---Pop a timer from the store. If no ID is given, the latest timer is popped.
---@param timer_id? integer
---@return pomo.Timer|? popped_timer
function TimerStore:pop(timer_id)
  if not timer_id then
    if self:len() == 1 then
      -- note that the `#` operator always returns the highest non-nil index in an array,
      -- not necessarily its length, which is why this works.
      return self:pop(#self.timers)
    end
    local latest_timer = self:get_latest()
    if latest_timer then
      return self:pop(latest_timer.id)
    end
    return
  end

  local timer = self:get(timer_id)
  if timer then
    self:remove(timer)
  end
  return timer
end

return TimerStore
