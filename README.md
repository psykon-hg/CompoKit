# CompoKit

CompoKit is an all-inclusive environment with (almost) all tools required for hosting PC demoscene competitions.

## Contents

A CompoKit installation mainly consists of third-party tools:

- **File Manager:** [Total Commander](https://www.ghisler.com/index.htm), [7-Zip](https://www.7-zip.org/) and [CKLaunch](src/cklaunch), a custom launcher tailored for running compos
- **Video Player:** [MPC-HC](https://mpc-hc.org/)
- **Audio Player:** [XMPlay](https://www.un4seen.com/xmplay.html) with [OpenMPT Plugin](https://lib.openmpt.org/libopenmpt/) and additional plugins for SID, AHX and YM
- **Image Viewer:** [XnView](https://www.xnview.com/en/), [CompoView](https://www.pouet.net/prod.php?which=56934), [GLISS](http://svn.emphy.de/scripts/trunk/gliss.cpp)
- **ANSI Viewer:** [ACiDView](https://sourceforge.net/projects/acidview6-win32/) and [Sahli](https://github.com/m0qui/Sahli)
- **DOS Emulator:** [DOSBox](https://www.dosbox.com/) and [DOSBox-X](https://dosbox-x.com/)
- **Text Editor:** [Notepad++](https://notepad-plus-plus.org/)
- **PDF Viewer:** [SumatraPDF](https://www.sumatrapdfreader.org/)
- Graphics compo background music
  - a selection of nice, not too bombastic demoscene music *(not included in the repository)*
  - a script ("`play_shuffled.cmd`") to generate shuffled playlists of whole directories and play them back, using the [Balanced Shuffle](https://keyj.emphy.de/balanced-shuffle/) algorithm
- Other tools: [FFmpeg](http://ffmpeg.org/) (for quick editing or transcoding of media files, should the need arise)

The following applications are **not** included for bloat or licensing reasons, but may be required for full functionality:
- Google Chrome (for WebGL demos and Sahli)
  - must be installed system-wide (in `C:\Program Files (x86)\Google\Chrome`)
- Pico-8 (to show `.p8` cartridges)
  - just unpack `pico8.exe` and the data files into a directory called `pico-8` next to (not inside of!) the `bin` directory


## Features

- Most programs and their configuration files are contained in a single directory, `bin`.
- As far as possible, the programs are set up in a "portable" mode that eliminates or minimizes interference with possible pre-existing system-wide installations of the same programs.
- All tools are automatically downloaded and unpacked using a PowerShell script. No special software needs to be pre-installed.
- The script `setpath.cmd` can be used to add CompoKit's `bin` directory to the `PATH` in command-line sessions.

## Installation

Just run `scripts/setup.cmd`. This will download and unpack everything.

## Special Configuration Options

Some of the tools are pre-configured in non-standard ways:

- CKLaunch
  - medium-contrast "dark" color scheme with Segoe UI font
  - file associations pre-configured to use all the tools CompoKit provides
- Total Commander
  - medium-contrast "dark" color scheme with Segoe UI font
  - search files in the current directory by simply typing letters (no Ctrl or Alt required)
  - F2 key renames files
  - Passive FTP by default
  - single-instance mode
- MPC-HC
  - starts in fullscreen mode
  - starts paused (press Space to start playback)
  - doesn't leave fullscreen mode when playback is complete
  - Q key quits (instead of Alt+X)
  - uses the Sync Renderer to minimize framedrops and judder
  - no Direct3D exclusive fullscreen mode (questionable if it would have any benefits on Windows 10; may become extremely problematic when codec errors occur)
- XMPlay
  - OpenMPT plugin is used by default for MOD, S3M, XM and IT formats
    - MOD files use 20% stereo separation and Amiga low-pass filter instead of interpolation
    - S3M, XM, IT use 100% stereo separation and 8-tap interpolation
  - OpenMPT pattern visualization is configured with maximum font size
  - SID is configured for Mono output with 8580 digi boost enabled
  - single-instance mode
- XnView
  - medium-contrast "dark" color scheme
  - shows only image files in browser, nothing else
  - all toolbars except menu and status bar disabled
  - no image info overlays on thumbnails or in fullscreen mode
  - starts in fullscreen mode, exit with Esc
  - toggle fullscreen with Enter key
  - Cursor Up/Down keys change frames/pages in multi-page documents (pages in TIFF, layers in PSD, ...)
- Sahli
  - a little script `_run.cmd` is put into the Sahli directory that launches Sahli in Chrome
- SumatraPDF
  - English language (regardless of system locale)
  - page layout set to "single page, don't save for every document"
- DOSBox
  - provided config file `dosbox.conf` sets fullscreen with correct aspect ratio, maximum speed (`cycles=max`) and 48000 Hz sample rate from all audio sources (including GUS and Covox)
  - CKLaunch is configured to interpret `.dosbox` files as DOSBox configuration files and runs them with the `dosbox -conf` option
    - This can be used to provide an entry-specific DOSBox configuration: Rename the `.conf` file to `.dosbox` and make sure the entry is auto-started:
      ```
      [autoexec]
      mount C: .
      C:
      whatever.com
      ```
- Chrome
  - CKLaunch, the `bin/Chrome.cmd` and `Sahli/_run.cmd` scripts run Chrome in fullscreen mode with the `--allow-file-acces-from-files` parameter 