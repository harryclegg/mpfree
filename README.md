# mpfree

Feature list:

- [x] Import playlist tree from iTunes.
- [x] Display playlist tree in window, showing playlist name, track count and export name.
- [x] Show a checkbox next to each folder and playlist. Selecting these scopes as expected.
- [x] Export using overwrite (clear folder first) or append mode.
- [x] User prefix and suffix filters to define which playlists are selected by default.
- [x] Option to strip prefix and suffix from playlist name upon export.
- [x] Flat playlist export function, where all playlists are exported to the same folder, with optional delimiter.
- [ ] Allow scoping to main export playlist folder - at the moment it is hard scoped to 'Playlists'.
- [ ] Add table of regex abbreviations to perform on both playlists (folder paths) and track (mp3 file) names.
  - e.g. House -> Hse, removing of anything following ft.
- [ ] Custom export string. Currently, a hard export string of `track-title-artist` is done.
- [ ] Conversion of lossless/non-mp3 files to mp3 upon export. This could make export time consuming. Perhaps there is a way to cache this using acoustid?
