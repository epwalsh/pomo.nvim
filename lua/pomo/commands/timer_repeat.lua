local log = require "pomo.log"
local pomo = require "pomo"
local util = require "pomo.util"

return function(data)
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
end
