---@enum pomo.Commands.CommandLookups
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

---@class pomo.Commands
---@field TimerHide fun(data: vim.api.keyset.create_user_command.command_args)
---@field TimerPause fun(data: vim.api.keyset.create_user_command.command_args)
---@field TimerRepeat fun(data: vim.api.keyset.create_user_command.command_args)
---@field TimerResume fun(data: vim.api.keyset.create_user_command.command_args)
---@field TimerSession fun(data: vim.api.keyset.create_user_command.command_args)
---@field TimerShow fun(data: vim.api.keyset.create_user_command.command_args)
---@field TimerStart fun(data: vim.api.keyset.create_user_command.command_args)
---@field TimerStop fun(data: vim.api.keyset.create_user_command.command_args)
local M = setmetatable({}, {
  ---@param t pomo.Commands
  ---@param k string|integer
  __index = function(t, k)
    if not command_lookups[k] then
      return
    end

    t[k] = require(command_lookups[k])
    return t[k]
  end,
})

function M.register_all()
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

  vim.api.nvim_create_user_command("TimerSession", M.TimerSession, {
    nargs = "?",
    complete = function()
      return vim.tbl_keys(require("pomo").get_config().sessions or {})
    end,
  })
end

return M
