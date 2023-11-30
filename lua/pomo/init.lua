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
---@param time_limit integer seconds
---@param name string|?
---@return integer time_id
M.start_timer = function(time_limit, name)
  local timer_id = timers:first_available_id()
  local timer = Timer.new(timer_id, time_limit, name, M.get_config())
  timers:store(timer)

  timer:start(function(t)
    timers:remove(t)
  end)

  return timer_id
end

---Stop a timer.
---@param timer_id integer|?
---@return boolean
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

---Get a timer and its notifiers.
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

return M
