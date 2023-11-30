local util = require "pomo.util"

describe("util.format_time()", function()
  it("should format seconds", function()
    assert.equals("3s", util.format_time(3))
  end)
end)
