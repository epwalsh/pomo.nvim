local module_lookups = {
  Default = "pomo.notifiers.default",
  System = "pomo.notifiers.system",
}

---@class pomo.Notifiers
---@field Default pomo.DefaultNotifier
---@field System pomo.SystemNotifier
local M = setmetatable({}, {
  ---@param t pomo.Notifiers
  ---@param k string|integer
  __index = function(t, k)
    if not module_lookups[k] then
      return
    end

    t[k] = require(module_lookups[k])
    return t[k]
  end,
})

---@enum pomo.NotifierType
M.NotifierType = {
  Default = "Default",
  System = "System",
}

---Construct a `pomo.Notifier` given a notifier name (`pomo.NotifierType`) or factory function.
---@param timer pomo.Timer
---@param opts pomo.NotifierConfig
---@return pomo.Notifier|? notifier
function M.build(timer, opts)
  if not (opts.name or opts.init) then
    error "invalid notifier config, 'name' and 'init' are mutually exclusive"
  end

  if opts.init then
    assert(opts.init)
    return opts.init(timer.id, timer.time_limit, timer.name, opts)
  end
  assert(opts.name)
  if opts.name == M.NotifierType.Default then
    return M.Default.new(timer, opts.opts)
  end
  if opts.name == M.NotifierType.System then
    return M.System.new(timer, opts.opts)
  end
  error(("invalid notifier name '%s'"):format(opts.name))
end

return M
