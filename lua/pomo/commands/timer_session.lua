---@param data vim.api.keyset.create_user_command.command_args
return function(data)
  local pomo = require "pomo"
  local log = require "pomo.log"
  local config = pomo.get_config()

  local session_name ---@type string
  if data.args and data.args ~= "" then
    session_name = data.args
  elseif config.sessions and #vim.tbl_keys(config.sessions) == 1 then
    session_name = vim.tbl_keys(config.sessions)[1]
  else
    log.error "Please provide a session name.\nUsage: TimerSession <session_name>"
    return
  end

  local session = config.sessions[session_name]
  if not session then
    log.error("Session '%s' not found", session_name)
    return
  end

  ---@param current_session pomo.SessionConfig[]
  ---@param index integer
  local function start_session(current_session, index)
    if index > #current_session then
      log.info("Session '%s' completed", session_name)
      return
    end

    local time_limit = require("pomo.util").parse_time(current_session[index].duration)
    if not time_limit then
      log.error("Invalid time duration '%s' in session '%s'", current_session[index].duration, session_name)
      return
    end

    pomo.start_timer(time_limit, {
      name = current_session[index].name,
      timer_done = function()
        start_session(current_session, index + 1)
      end,
    })
  end

  start_session(session, 1)
end
