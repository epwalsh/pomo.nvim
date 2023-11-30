local notifier = require "pomo.notifier"

---@class pomo.Timer
---@field id integer
---@field time_limit integer seconds
---@field name string|?
---@field timer uv_timer_t
---@field start_time integer|?
---@field notifiers pomo.Notifier[]
---@field config pomo.Config
local Timer = {}

---Initialize a `pomo.Timer`.
---@param id integer
---@param time_limit integer
---@param name string|?
---@param config pomo.Config
---@return pomo.Timer
Timer.new = function(id, time_limit, name, config)
  local self = setmetatable({}, { __index = Timer })
  self.id = id
  self.time_limit = time_limit
  self.name = name
  self.config = config
  self.timer = vim.loop.new_timer() ---@diagnostic disable-line: undefined-field
  self.notifiers = {}
  for _, noti_opts in ipairs(self.config.notifiers) do
    local noti = notifier.build(noti_opts, self.id, self.time_limit, self.name)
    self.notifiers[#self.notifiers + 1] = noti
  end
  return self
end

---Get the time remaining on the timer.
---@return number|?
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
        self.timer:close()

        for _, noti in ipairs(self.notifiers) do
          noti:done()
        end

        if timer_done ~= nil then
          timer_done(self)
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

---This is a class definition for the timer in `vim.loop`.
---@class uv_timer_t
---@field start function
---@field close function

return Timer
