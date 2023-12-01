local log = require "pomo.log"
local pomo = require "pomo"

local M = {}

---@param arg string
---@return pomo.Timer|?
M.get_timer_from_arg = function(arg)
  ---@type pomo.Timer|?
  local timer
  if string.len(arg) > 0 then
    local timer_id = tonumber(arg)
    if timer_id == nil then
      log.error("invalid timer ID: '%s'", arg)
      return
    end

    timer = pomo.get_timer(timer_id)
    if not timer then
      log.error("timer #%d is not active", timer_id)
      return
    else
      return timer
    end
  else
    timer = pomo.get_latest()
    if not timer then
      log.error "there are no active timers"
      return
    else
      return timer
    end
  end
end

return M
