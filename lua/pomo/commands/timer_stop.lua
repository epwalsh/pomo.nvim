---@param data vim.api.keyset.create_user_command.command_args
return function(data)
  local timers = require("pomo.commands.util").get_timers_from_arg(data.args)
  if timers then
    for _, timer in ipairs(timers) do
      if not require("pomo").stop_timer(timer) then
        require("pomo.log").error("failed to stop timer #%s", timer.id)
      end
    end
  end
end
