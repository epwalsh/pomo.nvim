# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

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
