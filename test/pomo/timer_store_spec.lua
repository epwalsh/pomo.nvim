local TimerStore = require "pomo.timer_store"
local Timer = require "pomo.timer"
local config = require("pomo.config").default()

describe("TimerStore", function()
  it("should correctly bookkeep timers", function()
    local timers = TimerStore.new()

    assert.equals(0, timers:len())
    assert.equals(1, timers:first_available_id())

    -- Add a timer.
    timers:store(Timer.new(1, 8, "Test 1", config):start())

    assert.equals(1, timers:len())
    assert.equals(2, timers:first_available_id())

    vim.wait(50)

    -- Add another.
    timers:store(Timer.new(2, 10, "Test 2", config):start())

    assert.equals(2, timers:len())
    assert.equals(3, timers:first_available_id())
    assert.equals(2, #timers:get_all())

    -- Get the latest.
    assert.equals(2, timers:get_latest().id)

    -- Get the first to finish.
    assert.equals(1, timers:get_first_to_finish().id)

    -- Remove the first timer.
    assert.equals(1, timers:pop(1).id)

    assert.equals(1, timers:len())
    -- Now ID # 1 should be available.
    assert.equals(1, timers:first_available_id())

    -- Remove the last one.
    assert.equals(2, timers:pop().id)
  end)
end)
