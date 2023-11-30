local Timer = require "pomo.timer"
local TimerStore = require "pomo.timer_store"
local config = require "pomo.config"

local M = {}

local timers = TimerStore.new()

---Setup pomo.nvim.
---@param opts table|pomo.Config
M.setup = function(opts)
  M._config = config.normalize(opts)
  require("pomo.commands").register_commands()
end

---Start a new timer.
---@param time_limit integer The time limit, in seconds.
---@param name string|? A name for the timer. Does not have to be unique.
---@param repeat_n integer|? The number of the times to repeat the timer.
---@param cfg pomo.Config|? Override the config.
---@return integer timer_id The ID of the timer created.
M.start_timer = function(time_limit, name, repeat_n, cfg)
  cfg = cfg and cfg or M.get_config()
  local timer_id = timers:first_available_id()
  local timer = Timer.new(timer_id, time_limit, name, cfg, repeat_n)

  timers:store(timer)

  timer:start(function(t)
    timers:remove(t)
  end)

  return timer_id
end

---Stop a timer. If no ID is given, the latest timer is stopped.
---@param timer_id integer|?
---@return boolean success If the timer was stopped.
M.stop_timer = function(timer_id)
  local timer = timers:pop(timer_id)
  if timer ~= nil then
    timer:stop()
    return true
  else
    return false
  end
end

---Get the config.
---@return pomo.Config
M.get_config = function()
  if M._config == nil then
    error "pomo.nvim has not been setup yet, did you forget to call 'require('pomo').setup({})'?"
  else
    return M._config
  end
end

---Get a timer by its ID.
---@param timer_id integer
---@return pomo.Timer|?
M.get_timer = function(timer_id)
  return timers:get(timer_id)
end

---Get the number of currently active timers.
---@return integer
M.num_active_timers = function()
  return timers:len()
end

---Get the latest timer (last one added/started) out of all active timers.
---@return pomo.Timer|?
M.get_latest = function()
  return timers:get_latest()
end

---Get the first timer to finish next (minimum time remaining) out of all active timers.
---@return pomo.Timer|?
M.get_first_to_finish = function()
  return timers:get_first_to_finish()
end

---Get a list of all active timers.
---@return pomo.Timer[]
M.get_all_timers = function()
  return timers:get_all()
end

return M
