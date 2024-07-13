local pomo = require "pomo"
local config = require "pomo.config"
local Timer = require "pomo.timer"

-- Mock the log module to avoid printing during tests.
local log = require "pomo.log"
log.error = function() end
log.info = function() end

-- Mock the Timer:start method to call the done callback immediately for testing.
Timer.start = function(self, done)
  self.start_time = vim.loop.now()
  done(self)
end

describe("PomoSession", function()
  before_each(function()
    -- Reset pomo configuration before each test.
    pomo.setup {
      sessions = {
        test_session = {
          { name = "Work", duration = "1s" },
          { name = "Break", duration = "1s" },
        },
      },
    }
  end)

  it("should run a session with multiple timers", function()
    local session_ran = false
    local logs = {}

    -- Override Timer.new to track timer creation.
    local original_new = Timer.new
    Timer.new = function(id, time_limit, name, cfg, repeat_n)
      local timer = original_new(id, time_limit, name, cfg, repeat_n)
      timer.start = function(self, done)
        done(self)
      end
      return timer
    end

    -- Capture the log info to verify session completion.
    log.info = function(msg)
      table.insert(logs, msg)
      if msg:match "Session 'test_session' completed" then
        session_ran = true
      end
    end

    -- Run the PomoSession command.
    local PomoSession = require "pomo.commands.timer_session"
    PomoSession { args = "test_session" }

    -- Verify that the session ran and completed.
    assert(session_ran, "Session did not complete")
    assert(#logs > 0, "No log messages captured")
    for _, log_msg in ipairs(logs) do
      print(log_msg)
    end
  end)
end)
