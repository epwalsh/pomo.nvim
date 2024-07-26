local TimerStore = require "pomo.timer_store"

local M = {}

local timers = TimerStore.new()

---Setup pomo.nvim.
---@param opts table|pomo.Config
M.setup = function(opts)
  local Config = require "pomo.config"
  local commands = require "pomo.commands"

  -- Normalize and store config.
  M._config = Config.normalize(opts)

  -- Register commands.
  commands.register_all()
end

---Start a new timer.
---@param time_limit integer The time limit, in seconds.
---@param opts string|{ name: string|?, repeat_n: integer|?, cfg: pomo.Config|?, timer_done: fun() }|?
---@return pomo.Timer timer
M.start_timer = function(time_limit, opts)
  local Timer = require "pomo.timer"

  opts = opts or {}
  if type(opts) == "string" then
    opts = { name = opts }
  end

  local cfg = opts.cfg or M.get_config()
  local timer_id = timers:first_available_id()
  local timer = Timer.new(timer_id, time_limit, opts.name, cfg, opts.repeat_n)

  timers:store(timer)

  timer:start(function(t)
    timers:remove(t)
    if opts.timer_done then
      opts.timer_done()
    end
  end)

  return timer
end

---Stop a timer. If no timer or ID is given, the latest timer is stopped.
---@param timer integer|pomo.Timer|?
---@return boolean success If the timer was stopped.
M.stop_timer = function(timer)
  if timer == nil or type(timer) == "number" then
    timer = timers:pop(timer)
  elseif type(timer) == "table" then
    timer = timers:pop(timer.id)
  else
    error("unexpected type for 'timer', got '" .. type(timer) .. "'")
  end

  if not timer then
    return false
  else
    timer:stop()
    return true
  end
end

---@param timer integer|pomo.Timer|?
---@return pomo.Timer|?
local function get_or_latest(timer)
  if timer == nil then
    return M.get_latest()
  elseif type(timer) == "number" then
    return M.get(timer)
  elseif type(timer) == "table" then
    return timer
  else
    error("unexpected type for 'timer' parameter '" .. type(timer) .. "'")
  end
end

---Pause a timer.
---@param timer integer|pomo.Timer|?
---@return boolean success
M.pause_timer = function(timer)
  timer = get_or_latest(timer)
  if not timer then
    return false
  else
    timer:pause()
    return true
  end
end

---Resume a timer.
---@param timer integer|pomo.Timer|?
---@return boolean success
M.resume_timer = function(timer)
  timer = get_or_latest(timer)
  if not timer then
    return false
  else
    timer:resume()
    return true
  end
end

---Hide a timer's notifiers (if they support that). If no timer ID is given, the latest timer is used.
---@param timer integer|pomo.Timer|?
---@return boolean success
M.hide_timer = function(timer)
  timer = get_or_latest(timer)
  if not timer then
    return false
  else
    timer:hide()
    return true
  end
end

---Show a timer's notifiers (if they support that). If no timer or ID is given, the latest timer is used.
---@param timer integer|pomo.Timer?
---@return boolean success
M.show_timer = function(timer)
  timer = get_or_latest(timer)
  if not timer then
    return false
  else
    timer:show()
    return true
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
