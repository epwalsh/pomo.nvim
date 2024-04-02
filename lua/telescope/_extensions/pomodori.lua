local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local utils = require "telescope.previewers.utils"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local pomo = require "pomo"
local themes = require "telescope.themes"

local pomodori_timers = nil
local options = {}

local get_timer = function(bufnr)
  local selection = action_state.get_selected_entry(bufnr)
  if selection ~= nil and selection.value ~= nil and selection.value.id ~= nil then
    return selection.value
  end
  return nil
end

local refresh = function(bufnr)
  actions.close(bufnr)
  if pomodori_timers ~= nil then
    pomodori_timers(options)
  end
end

local pause_timer = function(bufnr)
  local timer = get_timer(bufnr)
  if timer ~= nil then
    pomo.pause_timer(timer)
  end
  refresh(bufnr)
end

local resume_timer = function(bufnr)
  local timer = get_timer(bufnr)
  if timer ~= nil then
    pomo.resume_timer(timer)
  end
  refresh(bufnr)
end

local hide_timer = function(bufnr)
  local timer = get_timer(bufnr)
  if timer ~= nil then
    pomo.hide_timer(timer)
  end
  refresh(bufnr)
end

local view_timer = function(bufnr)
  local timer = get_timer(bufnr)
  if timer ~= nil then
    pomo.show_timer(timer)
  end
  refresh(bufnr)
end

local stop_timer = function(bufnr)
  local timer = get_timer(bufnr)
  if timer == nil then
    return
  end
  local confirm = vim.fn.input(string.format("Stop timer %s? [y/n]: ", tostring(timer)))
  if string.sub(string.lower(confirm), 0, 1) == "y" then
    pomo.stop_timer(timer)
    refresh(bufnr)
    return
  end
  print "Didn't stop timer"
end

local close = function(bufnr)
  actions.close(bufnr)
end

pomodori_timers = function(opts)
  options = opts
    or themes.get_dropdown {
      layout_strategy = "horizontal",
      layout_config = {
        width = 80,
        preview_width = 16,
      },
    }
  local timers = {}
  for _, timer in pairs(pomo.get_all_timers()) do
    local key = tostring(timer)
    local _, _, h = key:find "([%d]+)h"
    local _, _, m = key:find "([%d]+)m"
    local _, _, s = key:find "([%d]+)s"
    h = h or "00"
    m = m or "00"
    s = s or "00"

    table.insert(timers, {
      value = timer,
      display = key,
      ordinal = 1 .. h .. m .. s .. key,
    })
  end

  table.sort(timers, function(a, b)
    return a.ordinal < b.ordinal
  end)

  pickers
    .new(options, {
      prompt_title = "Pomodori Timers",
      finder = finders.new_table {
        results = timers,
        entry_maker = function(entry)
          return entry
        end,
      },
      sorter = conf.generic_sorter(options),
      previewer = previewers.new_buffer_previewer {
        title = "Key Map Info",
        define_preview = function(self, _, _)
          local buf = self.state.bufnr
          utils.highlighter(buf, "markdown")
          vim.api.nvim_buf_set_option(buf, "modifiable", true)
          vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
          vim.api.nvim_buf_set_lines(buf, 0, -1, true, {
            "",
            "   <C-p> Pause",
            "   <C-r> Resume  ",
            "",
            "   <C-h> Hide",
            "   <C-v> View",
            "",
            "   <C-s> Stop",
            "",
            "   <Esc> Close",
            " <Enter> Close",
          })
          vim.api.nvim_buf_set_option(buf, "modifiable", false)
        end,
      },
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          close(prompt_bufnr)
        end)

        map("n", "<C-p>", pause_timer)
        map("i", "<C-p>", pause_timer)

        map("n", "<C-r>", resume_timer)
        map("i", "<C-r>", resume_timer)

        map("n", "<C-h>", hide_timer)
        map("i", "<C-h>", hide_timer)

        map("n", "<C-v>", view_timer)
        map("i", "<C-v>", view_timer)

        map("n", "<C-s>", stop_timer)
        map("i", "<C-s>", stop_timer)

        map("n", "<esc>", close)
        map("i", "<esc>", close)
        return true
      end,
    })
    :find()
end

return require("telescope").register_extension {
  exports = {
    timers = function()
      pomodori_timers()
    end,
  },
}
