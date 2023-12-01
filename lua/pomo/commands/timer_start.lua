local log = require "pomo.log"
local pomo = require "pomo"
local util = require "pomo.util"

return function(data)
  if data.fargs == nil or #data.fargs == 0 or #data.fargs > 2 then
    return log.error "invalid number arguments, expected 1 or 2.\nUsage: TimerStart TIMELIMIT [NAME]"
  end

  local time_limit = util.parse_time(data.fargs[1])
  if time_limit == nil then
    return log.error("invalid time limit '%s'", data.fargs[1])
  end

  local name = data.fargs[2]

  pomo.start_timer(time_limit, name)
end
