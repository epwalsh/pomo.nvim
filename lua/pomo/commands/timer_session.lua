local log = require "pomo.log"
local pomo = require "pomo"

return function(data)
  local config = pomo.get_config()

  ---@type string
  local session_name
  if data.args and string.len(data.args) > 0 then
    session_name = data.args
  elseif config.sessions and #vim.tbl_keys(config.sessions) == 1 then
    session_name = vim.tbl_keys(config.sessions)[1]
  else
    return log.error "Please provide a session name.\nUsage: TimerSession <session_name>"
  end

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

    pomo.start_timer(time_limit, {
      name = timer_config.name,
      timer_done = function()
        start_session(current_session, index + 1)
      end,
    })
  end

  start_session(session, 1)
end
