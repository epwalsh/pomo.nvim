---@param data vim.api.keyset.create_user_command.command_args
return function(data)
  local log = require "pomo.log"
  if not (data.fargs and vim.list_contains({ 2, 3 }, #data.fargs)) then
    log.error "invalid number arguments, expected 2 or 3.\nUsage: TimerRepeat TIMELIMIT REPETITIONS [NAME]"
    return
  end

  local time_limit = require("pomo.util").parse_time(data.fargs[1])
  if not time_limit then
    log.error("invalid time limit '%s'", data.fargs[1])
    return
  end

  local repititions = tonumber(data.fargs[2], 10)
  if not repititions then
    log.error("invalid number of repetitions, expected number, got '%s'", data.fargs[2])
    return
  end

  require("pomo").start_timer(time_limit, { name = data.fargs[3], repeat_n = repititions })
end
