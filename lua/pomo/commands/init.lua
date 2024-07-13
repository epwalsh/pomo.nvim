local command_lookups = {
  TimerStart = "pomo.commands.timer_start",
  TimerStop = "pomo.commands.timer_stop",
  TimerRepeat = "pomo.commands.timer_repeat",
  TimerHide = "pomo.commands.timer_hide",
  TimerShow = "pomo.commands.timer_show",
  TimerPause = "pomo.commands.timer_pause",
  TimerResume = "pomo.commands.timer_resume",
  TimerSession = "pomo.commands.timer_session",
}

local M = setmetatable({}, {
  __index = function(t, k)
    local require_path = command_lookups[k]
    if not require_path then
      return
    end

    local mod = require(require_path)
    t[k] = mod

    return mod
  end,
})

M.register_all = function()
  vim.api.nvim_create_user_command("TimerStart", function(data)
    return M.TimerStart(data)
  end, { nargs = "+" })

  vim.api.nvim_create_user_command("TimerStop", function(data)
    return M.TimerStop(data)
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("TimerRepeat", function(data)
    return M.TimerRepeat(data)
  end, { nargs = "+" })

  vim.api.nvim_create_user_command("TimerHide", function(data)
    return M.TimerHide(data)
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("TimerShow", function(data)
    return M.TimerShow(data)
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("TimerPause", function(data)
    return M.TimerPause(data)
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("TimerResume", function(data)
    return M.TimerResume(data)
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("TimerSession", function(data)
    return M.TimerSession(data)
  end, { nargs = 1 })
end

return M
