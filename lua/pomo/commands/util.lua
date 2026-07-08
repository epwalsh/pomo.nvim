local log = require "pomo.log"
local pomo = require "pomo"

---@class pomo.Commands.Util
local M = {}

---@param arg string
---@return pomo.Timer[]|? timers
function M.get_timers_from_arg(arg)
  local timers = {} ---@type pomo.Timer[]
  if arg ~= "" then
    -- Parse the argument to a timer ID.
    local timer_id = tonumber(arg, 10)
    if not timer_id then
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
      end
      table.insert(timers, timer)
    end
  else
    local timer = pomo.get_latest()
    if not timer then
      log.error "there are no active timers"
      return
    end
    table.insert(timers, timer)
  end

  return timers
end

return M
