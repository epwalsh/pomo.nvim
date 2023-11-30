local notifier = require "pomo.notifier"
local config = require "pomo.config"

local M = {}

---@class uv_timer_t
---@field start function
---@field close function

---@class pomo.CachedTimer
---@field timer uv_timer_t
---@field notifiers pomo.Notifier[]

---@type table<integer, pomo.CachedTimer>
M._timers = {}

---@return integer
local function make_timer_id()
  for i = 1, #M._timers do
    if M._timers[i] == nil then
      return i
    end
  end
  return #M._timers + 1
end

---@param timer_id integer
---@param timer uv_timer_t
---@param notifiers pomo.Notifier[]
local function store_timer(timer_id, timer, notifiers)
  M._timers[timer_id] = {
    timer = timer,
    notifiers = notifiers,
  }
end

---@param timer_id integer
local function remove_timer(timer_id)
  M._timers[timer_id] = nil
end

---@param timer_id integer|?
---@return uv_timer_t|?, pomo.Notifier[]|?
local function pop_timer(timer_id)
  if timer_id == nil then
    if M.num_active_timers() == 1 then
      return pop_timer(#M._timers)
    else
      return nil
    end
  else
    local timer, notifiers = M.get_timer(timer_id)
    if timer ~= nil then
      remove_timer(timer_id)
    end

    return timer, notifiers
  end
end

---Get a timer and its notifiers.
---@param timer_id integer
---@return uv_timer_t|?, pomo.Notifier[]|?
M.get_timer = function(timer_id)
  local timer_cache = M._timers[timer_id]
  if timer_cache ~= nil then
    return timer_cache.timer, timer_cache.notifiers
  else
    return nil
  end
end

---Get the number of currently active timers.
---@return integer
M.num_active_timers = function()
  return vim.tbl_count(M._timers)
end

---Start a new timer.
---@param time_limit integer seconds
---@param name string|?
---@return integer time_id
M.start_timer = function(time_limit, name)
  local start_time = vim.loop.hrtime() ---@diagnostic disable-line: undefined-field
  ---@type uv_timer_t
  local timer = assert(vim.loop.new_timer()) ---@diagnostic disable-line: undefined-field
  local timer_id = make_timer_id()

  ---@type pomo.Notifier[]
  local notifiers = {}
  for _, noti_opts in ipairs(M.get_config().notifiers) do
    local noti = notifier.build(noti_opts, timer_id, time_limit, name)
    notifiers[#notifiers + 1] = noti
  end

  store_timer(timer_id, timer, notifiers)

  for _, noti in ipairs(notifiers) do
    noti:start()
  end

  timer:start(
    M.get_config().update_interval,
    M.get_config().update_interval,
    vim.schedule_wrap(function()
      local time_elapsed = (vim.loop.hrtime() - start_time) / 1000000000 ---@diagnostic disable-line: undefined-field
      local time_left = time_limit - time_elapsed

      if time_left > 0 then
        for _, noti in ipairs(notifiers) do
          noti:tick(time_left)
        end
      else
        timer:close()
        for _, noti in ipairs(notifiers) do
          noti:done()
        end
        remove_timer(timer_id)
      end
    end)
  )

  return timer_id
end

---Stop a timer.
---@param timer_id integer|?
---@return boolean
M.stop_timer = function(timer_id)
  local timer, notifiers = pop_timer(timer_id)
  if timer ~= nil and notifiers ~= nil then
    timer:close()
    for _, noti in ipairs(notifiers) do
      noti:stop()
    end
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

---Setup pomo.nvim.
---@param opts table|pomo.Config
M.setup = function(opts)
  M._config = config.normalize(opts)
  require("pomo.commands").register_commands()
end

return M
