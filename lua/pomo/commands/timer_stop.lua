local log = require "pomo.log"
local pomo = require "pomo"
local get_timer_from_arg = require("pomo.commands.util").get_timer_from_arg

return function(data)
  local timer = get_timer_from_arg(data.args)
  if timer and not pomo.stop_timer(timer) then
    return log.error "failed to stop timer"
  end
end
