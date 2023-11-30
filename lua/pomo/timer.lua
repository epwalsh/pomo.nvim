local notifier = require "pomo.notifier"
local util = require "pomo.util"

---@class pomo.Timer
---@field id integer
---@field time_limit integer seconds
---@field name string|?
---@field timer uv_timer_t
---@field start_time integer|?
---@field notifiers pomo.Notifier[]
---@field config pomo.Config
---@field max_repetitions integer|?
---@field repetitions integer
local Timer = {}

---Initialize a `pomo.Timer`.
---@param id integer
---@param time_limit integer
---@param name string|?
---@param config pomo.Config
---@param repeat_n integer|? The number of times to repeat the timer
---@return pomo.Timer
Timer.new = function(id, time_limit, name, config, repeat_n)
  local self = setmetatable({}, {
    __index = Timer,
    ---@param self pomo.Timer
    ---@return string
    __tostring = function(self)
      ---@type string
      local time_str
      local time_left = self:time_remaining()
      if time_left ~= nil then
        time_str = util.format_time(time_left)
      else
        time_str = util.format_time(self.time_limit)
      end

      local repetitions_str = ""
      if self.max_repetitions ~= nil and self.max_repetitions > 0 then
        repetitions_str = string.format(" [%d/%d]", self.repetitions + 1, self.max_repetitions)
      end

      if self.name ~= nil then
        return string.format("#%d, %s: %s%s", self.id, self.name, time_str, repetitions_str)
      else
        return string.format("#%d: %s%s", self.id, time_str, repetitions_str)
      end
    end,
  })

  self.id = id
  self.time_limit = time_limit
  self.name = name
  self.config = config
  self.max_repetitions = repeat_n
  self.repetitions = 0
  self.timer = vim.loop.new_timer() ---@diagnostic disable-line: undefined-field

  self.notifiers = {}
  ---@type pomo.NotifierConfig[]
  local noti_configs = self.config.notifiers
  if self.name ~= nil and self.config.timers[self.name] ~= nil then
    noti_configs = self.config.timers[self.name]
  end
  for _, noti_opts in ipairs(noti_configs) do
    local noti = notifier.build(self, noti_opts)
    self.notifiers[#self.notifiers + 1] = noti
  end

  return self
end

---Get the time remaining (in seconds) on the timer.
---@return number|? seconds
Timer.time_remaining = function(self)
  if self.start_time == nil then
    return nil
  end

  local time_elapsed = (vim.loop.hrtime() - self.start_time) / 1000000000 ---@diagnostic disable-line: undefined-field
  return self.time_limit - time_elapsed
end

---Start the timer.
---@param timer_done function|? callback(timer)
---@return pomo.Timer
Timer.start = function(self, timer_done)
  self.start_time = vim.loop.hrtime() ---@diagnostic disable-line: undefined-field
  self.repetitions = 0
  for _, noti in ipairs(self.notifiers) do
    noti:start()
  end

  self.timer:start(
    1000,
    self.config.update_interval,
    vim.schedule_wrap(function()
      local time_left = assert(self:time_remaining())

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
          self.start_time = vim.loop.hrtime() ---@diagnostic disable-line: undefined-field
          for _, noti in ipairs(self.notifiers) do
            noti:start()
          end
        else
          self.timer:close()
          if timer_done ~= nil then
            timer_done(self)
          end
        end
      end
    end)
  )

  return self
end

---Stop the timer.
Timer.stop = function(self)
  self.timer:close()
  for _, noti in ipairs(self.notifiers) do
    noti:stop()
  end
end

---This is a class definition for the timer in `vim.loop` to help my language server.
---@class uv_timer_t
---@field start function
---@field close function

return Timer
