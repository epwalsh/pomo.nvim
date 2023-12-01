local module_lookups = {
  Default = "pomo.notifiers.default",
  System = "pomo.notifiers.system",
}

local M = setmetatable({}, {
  __index = function(t, k)
    local require_path = module_lookups[k]
    if not require_path then
      return
    end

    local mod = require(require_path)
    t[k] = mod

    return mod
  end,
})

---@enum pomo.NotifierType
local NotifierType = {
  Default = "Default",
  System = "System",
}

M.NotifierType = NotifierType

---Construct a `pomo.Notifier` given a notifier name (`pomo.NotifierType`) or factory function.
---@param timer pomo.Timer
---@param opts pomo.NotifierConfig
---@return pomo.Notifier
M.build = function(timer, opts)
  if (opts.name == nil) == (opts.init == nil) then
    error "invalid notifier config, 'name' and 'init' are mutually exclusive"
  end

  if opts.init ~= nil then
    assert(opts.init)
    return opts.init(timer, opts)
  else
    assert(opts.name)
    if opts.name == NotifierType.Default then
      return M.Default.new(timer, opts.opts)
    elseif opts.name == NotifierType.System then
      return M.System.new(timer, opts.opts)
    else
      error(string.format("invalid notifier name '%s'", opts.name))
    end
  end
end

return M
