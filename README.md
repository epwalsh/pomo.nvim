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

### Commands

- `:TimerStart TIMELIMIT [NAME]` to start a new timer. For example, `:TimerStart 25m Work` to start a timer for 25 minutes called "Work".
- `:TimerStop [TIMERID]` to stop a running timer, e.g. `:TimerStop 1`.

## Setup

To setup pomo.nvim you just need to call `require("pomo").setup({ ... })` with the desired options. Here are some examples using different plugin managers. The full set of [configuration options](#configuration-options) are listed below.

### Using [`lazy.nvim`](https://github.com/folke/lazy.nvim)

```lua
return {
  "epwalsh/pomo.nvim",
  version = "*",  -- Recommended, use latest release instead of latest commit
  lazy = true,
  cmd = { "TimerStart", "TimerStop" },
  dependencies = {
    -- Optional, but highly recommended
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
    -- Optional, but highly recommended
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
  update_interval = 1000,
  -- Configure the notifiers to use for each timer that's created.
  notifiers = {
    -- The "Default" timer uses 'nvim-notify' to continuously display the timer
    {
      name = "Default",
      opts = {
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
    -- { init = function(timer_id, time_limit, name) ... end }
  },
}
```

## Defining custom notifiers

To define your own notifier you need to create a Lua `Notifier` class along with a factory `init` function to construct your notifier. Your `Notifier` class needs to have the following methods

- `Notifier.start(self)` - Called when the timer starts.
- `Notifier.tick(self, time_left)` - Called periodically (e.g. every second) while the timer is active. The `time_left` argument is the number of seconds left on the timer.
- `Notifier.done(self)` - Called when the timer finishes.
- `Notifier.stop(self)` - Called when the timer is stopped before finishing.

The factory `init` function takes 3 or 4 arguments, the `timer_id` (an integer), the `time_limit` seconds (an integer), the `name` assigned to the timer (a string or `nil`), and optionally a table of options from the `opts` field in the notifier's config.

For example, here's a simple notifier that just uses `print`:

```lua
local PrintNotifier = {}

PrintNotifier.new = function(timer_id, time_limit, name, opts)
  local self = setmetatable({}, { __index = PrintNotifier })
  self.timer_id = timer_id
  self.time_limit = time_limit
  self.name = name and name or "Countdown"
  self.opts = opts -- not used
  return self
end

PrintNotifier.start = function(self)
  print(string.format("Starting timer #%d, %s, for %ds", self.timer_id, self.name, self.time_limit))
end

PrintNotifier.tick = function(self, time_left)
  print(string.format("Timer #%d, %s, %ds remaining...", self.timer_id, self.name, time_left))
end

PrintNotifier.done = function(self)
  print(string.format("Timer #%d, %s, complete", self.timer_id, self.name))
end

PrintNotifier.stop = function(self) end
```

And then in the `notifiers` field of your pomo.nvim config, you'd add the following entry:

```lua
  { init = PrintNotifier.new, opts = {} }
```

## Contributing

Please see the [CONTRIBUTING](https://github.com/epwalsh/obsidian.nvim/blob/main/.github/CONTRIBUTING.md) guide from [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) before submitting a pull request, as this repository is set up and managed in the same way.

And if you're feeling especially generous I always appreciate some coffee funds! ❤️

[![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/epwalsh)
