local log = require "pomo.log"
local pomo = require "pomo"

local M = {}

---@param arg string
---@return pomo.Timer[]|?
M.get_timers_from_arg = function(arg)
  ---@type pomo.Timer[]
  local timers = {}

  if string.len(arg) > 0 then
    -- Parse the argument to a timer ID.
    local timer_id = tonumber(arg)
    if timer_id == nil then
      log.error("invalid timer ID: '%s'", arg)
      return
    end

    if timer_id < 0 then
      timers = pomo.get_all_timers()
    else
      local timer = pomo.get_timer(timer_id)
      if not timer then
        log.error("timer #%d is not active", timer_id)
        return
      else
        timers[#timers + 1] = timer
      end
    end
  else
    local timer = pomo.get_latest()
    if not timer then
      log.error "there are no active timers"
      return
    else
      timers[#timers + 1] = timer
    end
  end

  return timers
end

return M
