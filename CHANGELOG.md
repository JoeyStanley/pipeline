# Changelog

All notable changes to Pipeline are documented here, newest first.

## 2026-07-30 (v0.6)

### Added
- Preliquid recoding (`process_preliquids()`) so new-fave's preliquid codes
  (e.g. `iyL`) are translated back into standard vowel + following segment
  notation before further processing.
- This CHANGELOG file — started versioning history properly.

### Changed
- Reworked new-fave/DARLA token IDs to use each row's own `id` rather than a
  freshly generated row index, laying the groundwork for `_points.csv`
  support alongside the existing `_tracks.csv` support.

### Fixed
- Normalization producing all-`NA` formants on `_points.csv` data: the
  DCT-based `norm_track_*` functions need a formant trajectory per token and
  silently return `NA` when given only one row per token. Normalization now
  detects whether the loaded data is points-shaped or tracks-shaped and picks
  the matching normalization function accordingly.
- Trajectory data not being collapsed to per-token midpoints: the
  points-vs-tracks shape check deduplicated `token_id` before counting rows
  per token, so every dataset looked like points data and midpoints was
  showing the raw, un-averaged dataset instead.

## 2026-07-29

### Changed
- Minor splash/UI text updates.
- Ignored Claude-generated scratch files in git.

## 2026-06-19

### Changed
- Made hyperlinks in the sidebar visually stand out.
- General text cleanup, including consistent en-dash usage.

## 2026-06-17

### Fixed
- Server startup, by removing `renv::restore()` from app launch and guarding
  the `app_version` lookup.

## 2026-06-12 (v0.5.0)

### Added
- Contour/KDE distribution plotting and adjustable plot dimensions.

### Changed
- Reorganized the plot and customization tabs.

## 2026-06-02

### Added
- Auto-restore of `renv` packages on startup.
- Inline JS-powered help text.

## 2026-05-30

### Added
- Multiple color schemes (Kelly, Glasbey, Alphabet, Paul Tol) with a toggle
  to switch between them.

## 2026-05-29

### Changed
- Merged the "auditing" pull request (#1): general code cleanup, comments,
  and removal of dead/commented-out code.
- Clarified where normalization (ooo3) lives in the pipeline.
- Switched the file type picker to a dropdown; renamed JPEG to JPG.
- Removed README pre-rendering now that the GitHub README and in-app splash
  page are separate; removed mentions of trajectories (not yet supported).

## 2026-05-28

### Added
- Guard against uploading the same dataset twice.
- Customizable plot height and width.

### Fixed
- Crashes when mixing datasets, by dropping all-`NA` columns (e.g. `F3` when
  DARLA data, which has no `F3`, is mixed with new-fave data).
- Plot titles now truly blank when left unspecified (previously not `NULL`).

## 2026-05-27

### Added
- `TODO.md`.

### Changed
- Separated the GitHub README from the in-app splash page.

### Fixed
- Files with the same ID from different sources colliding.
- A stray `full_df()` call.

## 2026-05-26

### Changed
- Updated the "how to get started" instructions now that the app is live.

## 2026-05-19

### Added
- TODO note for handling transcription systems.

### Changed
- Silenced noisy console messages.
- Switched to more modern tidyverse syntax throughout.
- Minor text updates on the Pillai page.

### Fixed
- Aspect ratio of the Pillai plot.

## 2026-05-18

### Added
- `renv` for dependency management, activated on startup.
- Conference materials (NWAV54 folder) and notes on usage/plans.

### Changed
- Made the `DT` dependency explicit; noted the `joeyr` dependency.

## 2026-05-15

### Added
- Pipe-organ–inspired CSS theme.
- Splash page pulled from the README.

### Changed
- Reordered sidebar tabs.
- Offloaded vowel pairs to a config list and made the Pillai score page more
  robust.
- Temporarily removed trajectory support to keep the app stable.
- Rounded normalized formant columns for display only (not the underlying
  data).

### Fixed
- Sidebar tabs jumping around.

## 2026-05-14

### Changed
- Tidied up code and removed redundancy for robustness.
- Offloaded the stopword list to its own place and added "okay" to it.

## 2026-05-13

### Added
- Toggle between normalization procedures.
- Initial README.

### Fixed
- Bugs in loading, adding, and removing datasets.

## 2026-05-12 — Initial build

### Added
- Initial Shiny app scaffolding: file upload, data processing pipeline,
  Pillai score plotting.
- Radio buttons for choosing a data source, bundled sample data, and
  scaffolded new-fave support (first working end-to-end, with known bugs).
- Ability to add and remove uploaded files from the analysis.

### Changed
- Moved data processing into its own file; moved plot data prep into
  `reactive()` blocks and simplified away redundant `eventReactive()` use.
- Cleaned up Pillai plotting code and improved the progress bar labels.

### Fixed
- Residual bug left over from the `aes_string` switch.
