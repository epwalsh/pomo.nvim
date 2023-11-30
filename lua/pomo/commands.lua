local pomo = require "pomo"
local log = require "pomo.log"

local M = {}

M.register_commands = function()
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

    pomo.start_timer(time_limit, name)
  end, { nargs = "+" })

  vim.api.nvim_create_user_command("TimerStop", function(data)
    ---@type integer|?
    local timer_id
    if string.len(data.args) > 0 then
      timer_id = tonumber(data.args)

      if timer_id == nil then
        return log.error("invalid timer ID: '%s'", data.args)
      elseif not pomo.get_timer(timer_id) then
        return log.error("timer #%d is not active", timer_id)
      end
    elseif pomo.num_active_timers() == 0 then
      return log.error "there are no active timers"
    end

    if not pomo.stop_timer(timer_id) then
      return log.error "failed to stop timer"
    end
  end, { nargs = "?" })
end

return M
