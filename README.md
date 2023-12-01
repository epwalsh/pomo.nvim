<h1 align="center">pomo.nvim</h1>
<div><h4 align="center"><a href="#setup">Setup</a> · <a href="#configuration-options">Configure</a> · <a href="#contributing">Contribute</a></h4></div>
<div align="center"><a href="https://github.com/epwalsh/pomo.nvim/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/epwalsh/pomo.nvim?style=for-the-badge&logo=starship&logoColor=D9E0EE&labelColor=302D41&&color=d9b3ff&include_prerelease&sort=semver" /></a> <a href="https://github.com/epwalsh/pomo.nvim/pulse"><img alt="Last commit" src="https://img.shields.io/github/last-commit/epwalsh/pomo.nvim?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=302D41&color=9fdf9f"/></a> <a href="https://github.com/neovim/neovim/releases/latest"><img alt="Latest Neovim" src="https://img.shields.io/github/v/release/neovim/neovim?style=for-the-badge&logo=neovim&logoColor=D9E0EE&label=Neovim&labelColor=302D41&color=99d6ff&sort=semver" /></a> <a href="http://www.lua.org/"><img alt="Made with Lua" src="https://img.shields.io/badge/Built%20with%20Lua-grey?style=for-the-badge&logo=lua&logoColor=D9E0EE&label=Lua&labelColor=302D41&color=b3b3ff"></a></div>
<hr>

A simple, customizable [pomodoro](https://en.wikipedia.org/wiki/Pomodoro_Technique) timer for Neovim, written in Lua.

[![demo-gif](https://github.com/epwalsh/pomo.nvim/assets/8812459/e987203c-6e00-4e04-9012-2a1202953dab)](https://github.com/epwalsh/pomo.nvim/assets/8812459/e987203c-6e00-4e04-9012-2a1202953dab)

## Features

- 🪶 Lightweight and asynchronous
- 💻 Written in Lua
- ⚙️ Easily customizable and extendable
- ⏱️ Run multiple concurrent timers and repeat timers
- ➕ Integrate with [nvim-notify](https://github.com/rcarriga/nvim-notify), [lualine](#lualinenvim), and more

### Commands

- `:TimerStart TIMELIMIT [NAME]` to start a new timer.

  The time limit can be specified in hours, minutes, seconds, or a combination of those, and *shouldn't include any spaces*. For example:

  - `:TimerStart 25m Work` to start a timer for 25 minutes called "Work".
  - `:TimerStart 10s` to start a timer for 10 seconds.
  - `:TimerStart 1h30m` to start a timer for an hour and a half.

  pomo.nvim will recognize multiple forms of the time units, such as "m", "min", "minute", or "minutes" for minutes.

- `:TimerStop [TIMERID]` to stop a running timer, e.g. `:TimerStop 1`. If no ID is given, the latest timer is stopped.

- `:TimerRepeat TIMELIMIT REPETITIONS [NAME]` to start a repeat timer, e.g. `:TimerRepeat 10s 2` to repeat a 10 second timer twice.

## Setup

To setup pomo.nvim you just need to call `require("pomo").setup({ ... })` with the desired options. Here are some examples using different plugin managers. The full set of [configuration options](#configuration-options) are listed below.

### Using [`lazy.nvim`](https://github.com/folke/lazy.nvim)

```lua
return {
  "epwalsh/pomo.nvim",
  version = "*",  -- Recommended, use latest release instead of latest commit
  lazy = true,
  cmd = { "TimerStart", "TimerStop", "TimerRepeat" },
  dependencies = {
    -- Optional, but highly recommended if you want to use the "Default" timer
    "rcarriga/nvim-notify",
  },
  opts = {
    -- See below for full list of options 👇
  },
}
```

### Using [`packer.nvim`](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "epwalsh/pomo.nvim",
  tag = "*",  -- Recommended, use latest release instead of latest commit
  requires = {
    -- Optional, but highly recommended if you want to use the "Default" timer
    "rcarriga/nvim-notify",
  },
  config = function()
    require("pomo").setup({
      -- See below for full list of options 👇
    })
  end,
})
```

## Configuration options

This is a complete list of all of the options that can be passed to `require("pomo").setup()`. The values represent reasonable defaults, but please read each option carefully and customize it to your needs:

```lua
{
  -- How often the notifiers are updated.
  update_interval = 1000,

  -- Configure the notifiers to use for each timer that's created.
  notifiers = {
    -- The "Default" timer uses 'nvim-notify' to continuously display the timer
    {
      name = "Default",
      opts = {
        sticky = true,  -- set to false if you don't want to see the timer the whole time
        title_icon = "󱎫",
        text_icon = "󰄉",
        -- Replace the above with these if you don't have a patched font:
        -- title_icon = "⏳",
        -- text_icon = "⏱️",
      },
    },

    -- The "System" notifier sends a system notification when the timer is finished.
    -- Currently this is only available on MacOS.
    { name = "System" },

    -- You can also define custom notifiers by providing an "init" function instead of a name.
    -- See "Defining custom notifiers" below for an example 👇
    -- { init = function(timer) ... end }
  },

  -- Override the notifiers for specific timer names.
  timers = {
    -- For example, use only the "System" notifier when you create a timer called "Break"
    Break = {
      { name = "System" },
    },
  },
}
```

## Defining custom notifiers

To define your own notifier you need to create a Lua `Notifier` class along with a factory `init` function to construct your notifier. Your `Notifier` class needs to have the following methods

- `Notifier.start(self)` - Called when the timer starts.
- `Notifier.tick(self, time_left)` - Called periodically (e.g. every second) while the timer is active. The `time_left` argument is the number of seconds left on the timer.
- `Notifier.done(self)` - Called when the timer finishes.
- `Notifier.stop(self)` - Called when the timer is stopped before finishing.

The factory `init` function takes 1 or 2 arguments, the `timer` (a `pomo.Timer`) and optionally a table of options from the `opts` field in the notifier's config.

For example, here's a simple notifier that just uses `print`:

```lua
local PrintNotifier = {}

PrintNotifier.new = function(timer, opts)
  local self = setmetatable({}, { __index = PrintNotifier })
  self.timer = timer
  self.opts = opts -- not used
  return self
end

PrintNotifier.start = function(self)
  print(string.format("Starting timer #%d, %s, for %ds", self.timer.id, self.timer.name, self.timer.time_limit))
end

PrintNotifier.tick = function(self, time_left)
  print(string.format("Timer #%d, %s, %ds remaining...", self.timer.id, self.timer.name, time_left))
end

PrintNotifier.done = function(self)
  print(string.format("Timer #%d, %s, complete", self.timer.id, self.timer.name))
end

PrintNotifier.stop = function(self) end
```

And then in the `notifiers` field of your pomo.nvim config, you'd add the following entry:

```lua
  { init = PrintNotifier.new, opts = {} }
```

## Integrations

### [nvim-notify](https://github.com/rcarriga/nvim-notify)

The "Default" notifier integrates seamlessly with `nvim-notify`, you just need to have `nvim-notify` installed.

### [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)

pomo.nvim can easily be added to a section in your `lualine`. For example, this would extend the defaults for section X to include the next timer to finish (min time remaining):

```lua
require("lualine").setup {
  sections = {
    lualine_x = {
      function()
        local ok, pomo = pcall(require, "pomo")
        if not ok then
          return ""
        end

        local timer = pomo.get_first_to_finish()
        if timer == nil then
          return ""
        end

        return "󰄉 " .. tostring(timer)
      end,
      "encoding",
      "fileformat",
      "filetype",
    },
  },
}
```

[![lualine screenshot](https://github.com/epwalsh/pomo.nvim/assets/8812459/ff2beac8-a26f-421a-a5a6-cbeca73bfcf2)](https://github.com/epwalsh/pomo.nvim/assets/8812459/ff2beac8-a26f-421a-a5a6-cbeca73bfcf2)


## Contributing

Please see the [CONTRIBUTING](https://github.com/epwalsh/obsidian.nvim/blob/main/.github/CONTRIBUTING.md) guide from [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) before submitting a pull request, as this repository is set up and managed in the same way.

And if you're feeling especially generous I always appreciate some coffee funds! ❤️

[![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/epwalsh)
