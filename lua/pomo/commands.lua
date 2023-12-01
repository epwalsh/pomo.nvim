local pomo = require "pomo"
local log = require "pomo.log"
local util = require "pomo.util"

local M = {}

---@param arg string
---@return pomo.Timer|?
local function get_timer_from_arg(arg)
  ---@type pomo.Timer|?
  local timer
  if string.len(arg) > 0 then
    local timer_id = tonumber(arg)
    if timer_id == nil then
      log.error("invalid timer ID: '%s'", arg)
      return
    end

    timer = pomo.get_timer(timer_id)
    if not timer then
      log.error("timer #%d is not active", timer_id)
      return
    else
      return timer
    end
  else
    timer = pomo.get_latest()
    if not timer then
      log.error "there are no active timers"
      return
    else
      return timer
    end
  end
end

M.register_commands = function()
  vim.api.nvim_create_user_command("TimerStart", function(data)
    if data.fargs == nil or #data.fargs == 0 or #data.fargs > 2 then
      return log.error "invalid number arguments, expected 1 or 2.\nUsage: TimerStart TIMELIMIT [NAME]"
    end

    local time_limit = util.parse_time(data.fargs[1])
    if time_limit == nil then
      return log.error("invalid time limit '%s'", data.fargs[1])
    end

    local name = data.fargs[2]

    pomo.start_timer(time_limit, name)
  end, { nargs = "+" })

  vim.api.nvim_create_user_command("TimerStop", function(data)
    local timer = get_timer_from_arg(data.args)
    if timer and not pomo.stop_timer(timer) then
      return log.error "failed to stop timer"
    end
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("TimerRepeat", function(data)
    if data.fargs == nil or #data.fargs < 2 or #data.fargs > 3 then
      return log.error "invalid number arguments, expected 2 or 3.\nUsage: TimerRepeat TIMELIMIT REPETITIONS [NAME]"
    end

    local time_limit = util.parse_time(data.fargs[1])
    if time_limit == nil then
      return log.error("invalid time limit '%s'", data.fargs[1])
    end

    local repititions = tonumber(data.fargs[2])
    if repititions == nil then
      return log.error("invalid number of repetitions, expected number, got '%s'", data.fargs[2])
    end

    local name = data.fargs[3]

    pomo.start_timer(time_limit, name, repititions)
  end, { nargs = "+" })

  vim.api.nvim_create_user_command("TimerHide", function(data)
    local timer = get_timer_from_arg(data.args)
    if timer then
      pomo.hide_timer(timer)
    end
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("TimerShow", function(data)
    local timer = get_timer_from_arg(data.args)
    if timer then
      pomo.show_timer(timer)
    end
  end, { nargs = "?" })
end

return M
