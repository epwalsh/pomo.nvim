local log = require "pomo.log"
local pomo = require "pomo"
local get_timers_from_arg = require("pomo.commands.util").get_timers_from_arg

return function(data)
  local timers = get_timers_from_arg(data.args)
  if timers then
    for _, timer in ipairs(timers) do
      if not pomo.stop_timer(timer) then
        log.error("failed to stop timer #%s", timer.id)
      end
    end
  end
end
