---@param data vim.api.keyset.create_user_command.command_args
return function(data)
  local log = require "pomo.log"
  if not (data.fargs and vim.list_contains({ 1, 2 }, #data.fargs)) then
    log.error "invalid number arguments, expected 1 or 2.\nUsage: TimerStart TIMELIMIT [NAME]"
    return
  end

  local time_limit = require("pomo.util").parse_time(data.fargs[1])
  if not time_limit then
    log.error("invalid time limit '%s'", data.fargs[1])
    return
  end

  require("pomo").start_timer(time_limit, data.fargs[2])
end
