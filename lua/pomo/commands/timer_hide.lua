---@param data vim.api.keyset.create_user_command.command_args
return function(data)
  local timers = require("pomo.commands.util").get_timers_from_arg(data.args)
  if timers then
    for _, timer in ipairs(timers) do
      require("pomo").hide_timer(timer)
    end
  end
end
