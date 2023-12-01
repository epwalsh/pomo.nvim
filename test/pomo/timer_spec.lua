local Timer = require "pomo.timer"
local config = require "pomo.config"

describe("Timer", function()
  it("should pause and resume properly", function()
    -- Start a 10s timer.
    local timer = Timer.new(1, 10, "Test", config.default()):start()

    -- Give the timer a moment to tick.
    vim.wait(100)

    -- Pause it.
    timer:pause()

    local time_left = timer:time_remaining_ms()

    -- Wait and check that time left hasn't changed.
    vim.wait(100)
    assert.equals(timer:time_remaining_ms(), time_left)

    -- Resume it.
    timer:resume()
    assert(not timer.paused)

    -- Wait and check that time left is decreasing again.
    vim.wait(100)
    assert(timer:time_remaining_ms() < time_left)

    -- Pause again.
    timer:pause()

    time_left = timer:time_remaining_ms()

    -- Wait and check that time left hasn't changed.
    vim.wait(100)
    assert.equals(timer:time_remaining_ms(), time_left)

    -- Resume again.
    timer:resume()

    -- Wait and check that time left is decreasing again.
    vim.wait(100)
    assert(timer:time_remaining_ms() < time_left)

    -- At this point the timer as been running for ~ 100 + 100 + 100 = 300 milliseconds,
    -- so there should still be over ~9.7 seconds left.
    assert(timer:time_remaining_ms() > 9500)
  end)
end)
