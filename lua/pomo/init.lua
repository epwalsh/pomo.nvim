local TimerStore = require "pomo.timer_store"

---@class pomo
local M = {}

local timers = TimerStore.new()

---Setup pomo.nvim.
---@param opts? pomoOpts
function M.setup(opts)
  local Config = require "pomo.config"
  local commands = require "pomo.commands"

  -- Normalize and store config.
  M._config = Config.normalize(opts or {})

  -- Register commands.
  commands.register_all()
end

---Start a new timer.
---@param time_limit integer The time limit, in seconds.
---@param opts? string|{ name?: string, repeat_n?: integer, cfg?: pomoOpts, timer_done: function }
---@return pomo.Timer timer
function M.start_timer(time_limit, opts)
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
---@param timer? integer|pomo.Timer
---@return boolean success If the timer was stopped.
function M.stop_timer(timer)
  if timer and type(timer) ~= "table" and type(timer) ~= "number" then
    error("unexpected type for 'timer', got '" .. type(timer) .. "'")
  end
  if not timer or type(timer) == "number" then
    timer = timers:pop(timer)
  elseif type(timer) == "table" then
    timer = timers:pop(timer.id)
  end

  if not timer then
    return false
  end
  timer:stop()
  return true
end

---@param timer? integer|pomo.Timer
---@return pomo.Timer|? timer
local function get_or_latest(timer)
  if timer == nil then
    return M.get_latest()
  end
  if type(timer) == "number" then
    return M.get_timer(timer)
  end
  if type(timer) == "table" then
    return timer
  end
  error("unexpected type for 'timer' parameter '" .. type(timer) .. "'")
end

---Pause a timer.
---@param timer? integer|pomo.Timer
---@return boolean success
function M.pause_timer(timer)
  timer = get_or_latest(timer)
  if not timer then
    return false
  end
  timer:pause()
  return true
end

---Resume a timer.
---@param timer? integer|pomo.Timer
---@return boolean success
function M.resume_timer(timer)
  timer = get_or_latest(timer)
  if not timer then
    return false
  end
  timer:resume()
  return true
end

---Hide a timer's notifiers (if they support that). If no timer ID is given, the latest timer is used.
---@param timer? integer|pomo.Timer
---@return boolean success
function M.hide_timer(timer)
  timer = get_or_latest(timer)
  if not timer then
    return false
  end
  timer:hide()
  return true
end

---Show a timer's notifiers (if they support that). If no timer or ID is given, the latest timer is used.
---@param timer? integer|pomo.Timer
---@return boolean success
function M.show_timer(timer)
  timer = get_or_latest(timer)
  if not timer then
    return false
  end
  timer:show()
  return true
end

---Get the config.
---@return pomoOpts config
function M.get_config()
  if not M._config then
    error "pomo.nvim has not been setup yet, did you forget to call 'require('pomo').setup({})'?"
  end
  return M._config
end

---Get a timer by its ID.
---@param timer_id integer
---@return pomo.Timer|? timer
function M.get_timer(timer_id)
  return timers:get(timer_id)
end

---Get the number of currently active timers.
---@return integer timers
function M.num_active_timers()
  return timers:len()
end

---Get the latest timer (last one added/started) out of all active timers.
---@return pomo.Timer|? timer
function M.get_latest()
  return timers:get_latest()
end

---Get the first timer to finish next (minimum time remaining) out of all active timers.
---@return pomo.Timer|? timer
function M.get_first_to_finish()
  return timers:get_first_to_finish()
end

---Get a list of all active timers.
---@return pomo.Timer[] timers
function M.get_all_timers()
  return timers:get_all()
end

return M
