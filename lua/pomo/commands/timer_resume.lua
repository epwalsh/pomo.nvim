local pomo = require "pomo"
local get_timer_from_arg = require("pomo.commands.util").get_timer_from_arg

return function(data)
  local timer = get_timer_from_arg(data.args)
  if timer then
    pomo.resume_timer(timer)
  end
end
