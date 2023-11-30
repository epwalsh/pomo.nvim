local log = require "pomo.log"
local notifier = require "pomo.notifier"
local config = require "pomo.config"

local M = {}

---Setup pomo.nvim.
---@param opts table|pomo.Config
M.setup = function(opts)
  M._config = config.normalize(opts)

  vim.api.nvim_create_user_command("TimerStart", function(data)
    if data.fargs == nil or #data.fargs == 0 or #data.fargs > 2 then
      return log.error "Invalid arguments.\nUsage: TimerStart TIMELIMIT [NAME]"
    end

    local time_arg = string.lower(data.fargs[1])
    local name = data.fargs[2]

    ---@type number|?
    local time_limit
    if vim.endswith(time_arg, "m") then
      time_limit = tonumber(string.sub(time_arg, 1, -2)) * 60
    elseif vim.endswith(time_arg, "h") then
      time_limit = tonumber(string.sub(time_arg, 1, -2)) * 3600
    elseif vim.endswith(time_arg, "s") then
      time_limit = tonumber(string.sub(time_arg, 1, -2))
    else
      time_limit = tonumber(time_arg)
    end

    if time_limit == nil then
      return log.error("invalid time limit '%s'", time_arg)
    end

    M.start_timer(time_limit, name)
  end, { nargs = "+" })

  vim.api.nvim_create_user_command("TimerStop", function(data)
    local timer_id = tonumber(data.args)
    if timer_id == nil then
      return log.error("invalid timer ID '%s'", data.args)
    else
      M.stop_timer(timer_id)
    end
  end, { nargs = 1 })
end

---@return pomo.Config
M.config = function()
  if M._config == nil then
    error "pomo.nvim has not been setup yet, did you forget to call 'require('pomo').setup({})'?"
  else
    return M._config
  end
end

---@class uv_timer_t
---@field start function
---@field close function

---@class pomo.CachedTimer
---@field timer uv_timer_t
---@field notifiers pomo.Notifier[]

---@type table<integer, pomo.CachedTimer>
M._timers = {}

---@param time_limit integer seconds
---@param name string|?
---@return integer time_id
M.start_timer = function(time_limit, name)
  local start_time = vim.loop.hrtime() ---@diagnostic disable-line: undefined-field
  ---@type uv_timer_t
  local timer = assert(vim.loop.new_timer()) ---@diagnostic disable-line: undefined-field
  local timer_id = vim.tbl_count(M._timers) + 1

  ---@type pomo.Notifier[]
  local notifiers = {}
  for _, noti_opts in ipairs(M.config().notifiers) do
    local noti = notifier.build(noti_opts, timer_id, time_limit, name)
    notifiers[#notifiers + 1] = noti
  end

  M._timers[timer_id] = { timer = timer, notifiers = notifiers }

  for _, noti in ipairs(notifiers) do
    noti:start()
  end

  timer:start(
    M.config().update_interval,
    M.config().update_interval,
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
        M._timers[timer_id] = nil
      end
    end)
  )

  return timer_id
end

---@param timer_id integer
---@return boolean
M.stop_timer = function(timer_id)
  if M._timers[timer_id] ~= nil then
    M._timers[timer_id].timer:close()
    for _, noti in ipairs(M._timers[timer_id].notifiers) do
      noti:stop()
    end
    M._timers[timer_id] = nil
    return true
  else
    return false
  end
end

return M
