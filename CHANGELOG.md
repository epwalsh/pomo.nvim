# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Added `:TimerSession <session_name>` command to create and manage Pomodoro like sessions.
- Added Windows support for System notifications.

### Changed

- Changed the arguments of `pomo.start_timer()` to accept a table of options.

## [v0.6.0](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.6.0) - 2024-04-02

### Added

- Added Telescope integration (#20).

## [v0.5.0](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.5.0) - 2024-03-27

### Added

- Added Linux support for System notifications.

## [v0.4.5](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.4.5) - 2024-03-08

### Fixed

- Fixed another bug with default notifier when `sticky=true`.

## [v0.4.4](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.4.4) - 2024-03-07

### Fixed

- Fixed bug with default notifier and `vim.notify` when timer starts as hidden and then you use `:TimerShow`.

## [v0.4.3](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.4.3) - 2024-01-07

### Fixed

- Make it compatible with `mini.notify` plugin.

## [v0.4.2](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.4.2) - 2023-12-27

### Added

- You can now pass `-1` as the `TIMERID` to apply a command to all active timers.

### Fixed

- Automatically use `nvim-notify` when available.

## [v0.4.1](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.4.1) - 2023-12-01

### Fixed

- Ensure stopped timers are removed from the timer store.

## [v0.4.0](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.4.0) - 2023-12-01

### Added

- Added `pomo.get_all_timers()` function.
- Added `sticky` option to "Default" notifier.
- Added ability to show/hide a timer's notifiers, if they support that, via the commands and functions:
  - `:TimerShow` / `pomo.show_timer()`
  - `:TimerHide` / `pomo.hide_timer()`
- Made the "Default" timer hide-able, which has the same affect as the `sticky` option.
- Added ability to pause/resume timers via the commands and functions:
  - `:TimerPause` / `pomo.pause_timer()`
  - `:TimerResume` / `pomo.resume_timer()`

### Changed

- `pomo.start_timer(...)` now returns a `pomo.Timer` instead of an integer timer ID.
- `pomo.stop_timer(...)` now takes a `pomo.Timer` or an integer timer ID.

## [v0.3.0](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.3.0) - 2023-11-30

### Added

- Added support for repeat timers via `:TimerRepeat`.
- Added `config.timers` option for overriding the notifiers for specific timer names.

## [v0.2.0](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.2.0) - 2023-11-30

### Added

- Added `Timer` and `TimerStore` abstractions.
- Added `pomo.get_latest()` and `pomo.get_first_to_finish()` functions.

### Changed

- The argument to `:StopTimer` is now optional when there is only one active timer.

## [v0.1.0](https://github.com/epwalsh/pomo.nvim/releases/tag/v0.1.0) - 2023-11-29

### Added

- Added initial features.
