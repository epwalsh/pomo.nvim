local log = require "pomo.log"
local pomo = require "pomo"

return function(data)
  local session_name = data.args
  if not session_name or session_name == "" then
    return log.error "Session name is required.\nUsage: TimerSession <session_name>"
  end

  local config = pomo.get_config()
  local session = config.sessions[session_name]
  if not session then
    return log.error("Session '%s' not found", session_name)
  end

  local function start_session(current_session, index)
    if index > #current_session then
      log.info("Session '%s' completed", session_name)
      return
    end

    local timer_config = current_session[index]
    local time_limit = require("pomo.util").parse_time(timer_config.duration)
    if not time_limit then
      log.error("Invalid time duration '%s' in session '%s'", timer_config.duration, session_name)
      return
    end

    local timer = pomo.start_timer(time_limit, timer_config.name)
    timer:start(function()
      start_session(current_session, index + 1)
    end)
  end

  start_session(session, 1)
end
