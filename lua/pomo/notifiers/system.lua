local log = require "pomo.log"
local util = require "pomo.util"

---A `pomo.Notifier` that sends a system notification when the timer is finished.
---@class pomo.SystemNotifier : pomo.Notifier
---@field notification any
---@field opts table
---@field timer pomo.Timer
local SystemNotifier = {}

SystemNotifier.supported_oss = { util.OS.Darwin, util.OS.Linux }

---@param timer pomo.Timer
---@param opts? table
---@return pomo.SystemNotifier notifier
function SystemNotifier.new(timer, opts)
  if not vim.tbl_contains(SystemNotifier.supported_oss, util.get_os()) then
    error(("SystemNotifier is not implemented for your OS (%s)"):format(util.get_os()))
  end

  local self = setmetatable({}, { __index = SystemNotifier })
  self.timer = timer
  self.notification = nil
  self.opts = opts and opts or {}
  return self
end

---@param time_left integer
function SystemNotifier:tick(time_left) end ---@diagnostic disable-line:unused-local

function SystemNotifier:start() end

function SystemNotifier:done()
  local repetitions_str = ""
  if self.timer.max_repetitions and self.timer.max_repetitions > 0 then
    repetitions_str = (" [%d/%d]"):format(self.timer.repetitions + 1, self.timer.max_repetitions)
  end

  if not vim.tbl_contains(util.OS, util.get_os()) then
    return log.error("SystemNotifier is not implemented for your OS (%s)", util.get_os())
  end

  -- macOS Notification
  if util.get_os() == util.OS.Darwin then
    os.execute(
      ([[osascript -e 'display notification "Timer done!" with title "Timer #%d%s%s%s" sound name "Ping"']]):format(
        self.timer.id,
        (self.timer.name and " (" .. self.timer.name .. "), " or ", "),
        util.format_time(self.timer.time_limit),
        repetitions_str
      )
    )
  -- Linux Notification
  elseif util.get_os() == util.OS.Linux then
    os.execute(
      ([[notify-send -u critical -i "appointment-soon" "Timer %d%s%s%s" "Timer done!"]]):format(
        self.timer.id,
        (self.timer.name and " (" .. self.timer.name .. "), " or ", "),
        util.format_time(self.timer.time_limit),
        repetitions_str
      )
    )
  -- Windows Notification
  elseif util.get_os() == util.OS.Windows then
    os.execute(
      ([[
        PowerShell -Command "Add-Type -AssemblyName System.Windows.Forms;
        $notify = New-Object System.Windows.Forms.NotifyIcon;
        $notify.Icon = [System.Drawing.SystemIcons]::Information;
        $notify.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info;
        $notify.BalloonTipText = 'Timer #%d, %s%s';
        $notify.BalloonTipTitle = 'Timer done!';
        $notify.Visible = $true;
        $notify.ShowBalloonTip(10000);"]]):format(
        self.timer.id,
        util.format_time(self.timer.time_limit),
        repetitions_str
      )
    )
  end
end

function SystemNotifier:stop() end

return SystemNotifier
