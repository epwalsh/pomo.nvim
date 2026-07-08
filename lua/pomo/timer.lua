local util = require "pomo.util"

local now = vim.uv.now

---@class pomo.Timer
---@field config pomoOpts
---@field id integer
---@field max_repetitions? integer
---@field name? string
---@field notifiers pomo.Notifier[]
---@field paused boolean
---@field paused_at? integer milliseconds
---@field repetitions integer
---@field resumed_at? integer milliseconds
---@field start_time? integer milliseconds
---@field time_limit integer seconds
---@field time_paused integer milliseconds
---@field timer uv.uv_timer_t
local Timer = {}

---Initialize a `pomo.Timer`.
---@param id integer
---@param time_limit integer
---@param name? string
---@param config pomoOpts
---@param repeat_n? integer The number of times to repeat the timer
---@return pomo.Timer timer
function Timer.new(id, time_limit, name, config, repeat_n)
  local self = setmetatable({}, {
    __index = Timer,
    ---@param self pomo.Timer
    ---@return string str
    __tostring = function(self)
      local time_left = self:time_remaining()
      local time_str = util.format_time(time_left and time_left or self.time_limit)
      local repetitions_str = ""
      if self.max_repetitions and self.max_repetitions > 0 then
        repetitions_str = (" [%d/%d]"):format(self.repetitions + 1, self.max_repetitions)
      end

      local paused_str = ""
      if self.paused then
        paused_str = " (paused)"
      end
      if self.name then
        return ("#%d, %s: %s%s%s"):format(self.id, self.name, time_str, repetitions_str, paused_str)
      end
      return ("#%d: %s%s%s"):format(self.id, time_str, repetitions_str, paused_str)
    end,
  })

  self.id = id
  self.time_limit = time_limit
  self.name = name
  self.config = config
  self.max_repetitions = repeat_n
  self.repetitions = 0
  self.paused = false
  self.time_paused = 0
  self.timer = vim.uv.new_timer()

  self.notifiers = {}
  local noti_configs = self.config.notifiers ---@type pomo.NotifierConfig[]
  if self.name and self.config.timers[self.name] then
    noti_configs = self.config.timers[self.name]
  end
  for _, noti_opts in ipairs(noti_configs) do
    table.insert(self.notifiers, require("pomo.notifiers").build(self, noti_opts))
  end
  return self
end

---Get the time remaining in milliseconds on the timer.
---@return integer|? milliseconds
function Timer:time_remaining_ms()
  if not self.start_time then
    return
  end

  ---@type integer
  local reference_time
  if self.paused then
    assert(self.paused_at)
    reference_time = self.paused_at
  else
    reference_time = now()
  end

  local time_elapsed = reference_time - self.start_time - self.time_paused
  return math.max(self.time_limit * 1000 - time_elapsed, 0)
end

---Get the time remaining in seconds on the timer.
---@return integer|nil seconds
function Timer:time_remaining()
  local time_left = self:time_remaining_ms()
  if time_left then
    return math.floor(time_left / 1000)
  end
end

---Start the timer.
---@param timer_done? fun(timer: uv.uv_timer_t) callback(timer)
---@return pomo.Timer timer
function Timer:start(timer_done)
  self.start_time = now()
  self.paused = false
  self.repetitions = 0

  for _, noti in ipairs(self.notifiers) do
    noti:start()
  end

  self.timer:start(
    1000,
    self.config.update_interval,
    vim.schedule_wrap(function()
      local time_left = self:time_remaining()
      if not time_left then
        return
      end

      if time_left > 0 then
        for _, noti in ipairs(self.notifiers) do
          noti:tick(time_left)
        end
      else
        for _, noti in ipairs(self.notifiers) do
          noti:done()
        end

        if self.max_repetitions ~= nil and self.max_repetitions > 0 and self.repetitions + 1 < self.max_repetitions then
          self.repetitions = self.repetitions + 1
          self.start_time = now()
          for _, noti in ipairs(self.notifiers) do
            noti:start()
          end
        else
          self.timer:close()
          if timer_done then
            timer_done(self)
          end
        end
      end
    end)
  )

  return self
end

---Stop the timer.
function Timer:stop()
  self.timer:close()
  for _, noti in ipairs(self.notifiers) do
    noti:stop()
  end
end

---Pause the timer.
function Timer:pause()
  if self.start_time and not self.paused then
    self.paused_at = now()
    self.paused = true
  end
end

---Resume the timer.
function Timer:resume()
  if self.paused then
    assert(self.paused_at)
    local current_time = now()
    self.time_paused = self.time_paused + (current_time - self.paused_at)
    self.resumed_at = current_time
    self.paused_at = nil
    self.paused = false
  end
end

---Hide the timer's notifiers, if they support that.
function Timer:hide()
  for _, noti in ipairs(self.notifiers) do
    if noti.hide then
      noti:hide()
    end
  end
end

---Show the timer's notifiers, if they support that.
function Timer:show()
  for _, noti in ipairs(self.notifiers) do
    if noti.show then
      noti:show()
    end
  end
end

return Timer
