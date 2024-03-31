local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local pomo = require("pomo")
local themes = require("telescope.themes")

local pomodori_timers = nil
local options = {}

local get_timer = function(bufnr)
  local timer = action_state.get_selected_entry(bufnr)
  if timer ~= nil and timer.value ~= nil and timer.value.id ~= nil then
    return timer.value
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
  local confirm = vim.fn.input(
    string.format("Stop timer %s? [y/n]: ", tostring(timer))
  )
  if string.sub(string.lower(confirm), 0, 1) == "y" then
    if timer ~= nil then
      pomo.stop_timer(timer)
    end
    refresh(bufnr)
  end
  print("Didn't stop timer")
end


-- our picker function: colors
pomodori_timers = function(opts)
  options = opts or themes.get_dropdown()

  local timers = {}
  for _,timer in pairs(pomo.get_all_timers()) do
    table.insert(timers, timer)
  end

  table.sort(timers, function(a,b) return a.ord < b.ord end)

  pickers.new(options, {
    prompt_title = "Pomodori Timers",
    finder = finders.new_table {
      results = timers,
      entry_maker = function(entry)
        local key = tostring(timer)
        local _,_,h = key:find("([%d]+)h")
        local _,_,m = key:find("([%d]+)m")
        local _,_,s = key:find("([%d]+)s")
        h = h or "00"
        m = m or "00"
        s = s or "00"

        entry.value = entry
        entry.display = key
        entry.ordinal = 1 .. h .. m .. s
        return entry
      end
    },
    sorter = conf.generic_sorter(options),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
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

      return true
    end,
  }):find()
  print ("Mapping: [ <C-p> Pause | <C-r> Resume | <C-h> Hide | <C-v> Show/View | <C-S> Stop | <Esc>/<Enter> Close ]")
end


return require("telescope").register_extension(
  {
    exports = {
      timers = pomodori_timers,
    }
  }
)
