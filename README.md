# CompoKit

CompoKit is an all-inclusive environment with (almost) all tools required for hosting PC [demoscene](https://en.wikipedia.org/wiki/Demoscene) competitions.

## Contents

A CompoKit installation mainly consists of third-party tools:

- **File Manager:** [Total Commander](https://www.ghisler.com/index.htm), [7-Zip](https://www.7-zip.org/) and [CKLaunch](src/cklaunch), a custom launcher tailored for running compos
- **Video Player:** [MPC-HC](https://mpc-hc.org/)
- **Audio Player:** [XMPlay](https://www.un4seen.com/xmplay.html) with [OpenMPT Plugin](https://lib.openmpt.org/libopenmpt/) and additional plugins for SID, AHX and YM
- **Image Viewer:** [XnView](https://www.xnview.com/en/), [CompoView](https://www.pouet.net/prod.php?which=56934), [GLISS](http://svn.emphy.de/scripts/trunk/gliss.cpp)
- **ANSI Viewer:** [ACiDView](https://sourceforge.net/projects/acidview6-win32/) and [Sahli](https://github.com/m0qui/Sahli)
- **Emulators:**
  - **DOS:** [DOSBox](https://www.dosbox.com/) and [DOSBox-X](https://dosbox-x.com/)
  - **C64:** [WinVICE](http://vice-emu.sourceforge.net/)
  - **Amiga:** [WinUAE](http://www.winuae.net/)
- **Text Editor:** [Notepad++](https://notepad-plus-plus.org/)
- **PDF Viewer:** [SumatraPDF](https://www.sumatrapdfreader.org/)
- **Audio/Video Tools:** [FFmpeg](http://ffmpeg.org/), [youtube-dl](https://ytdl-org.github.io/youtube-dl/) *(only installed on demand)*
- **Music:**
  - a selection of nice, not too bombastic demoscene music for use as background music during graphics compos ...
  - ... and a few proper bangers for grabbing the audience's attention before a compo
  - downloaded from scene.org archives and (where necessary) SoundCloud
  - see [music/download.txt](music/download.txt) - suggestions or pull requests to extend or improve the list are highly welcome!
- **Full-screen typer:** [typr](https://github.com/mog/typr)
- **Manual:** a comprehensive [document](Compo-HOWTO.md) that describes everything a compo organizer has to do

The following applications are **not** included for bloat or licensing reasons, but may be required for full functionality:
- Google Chrome (for WebGL demos and Sahli)
  - must be installed system-wide (in `C:\Program Files (x86)\Google\Chrome`)
- Pico-8 (to show `.p8` cartridges)
  - just unpack `pico8.exe` and the data files into a directory called `pico-8` next to (not inside of!) the `bin` directory


## Features

- Most programs and their configuration files are contained in a single directory, `bin`.
- As far as possible, the programs are set up in a "portable" mode that eliminates or minimizes interference with possible pre-existing system-wide installations of the same programs.
- Where applicable, the tools are preconfigured for use in compos. For example, images and videos open in fullscreen mode, and media files don't start playback until a key has been pressed (so that the video source for the bigscreen can be switched in the meantime).
- All tools are automatically downloaded and unpacked using a PowerShell script. No special software needs to be pre-installed.
  - This script, `setup.ps1` (and its batch wrapper, `setup.cmd`) works like a small package manager, including "`-reconfigure`" and "`-reinstall`" options.
- The script `setpath.cmd` can be used to add CompoKit's `bin` directory to the `PATH` in command-line sessions.
- Contains a script (`play_shuffled.cmd`) to generate shuffled playlists of whole directories and play them back, using the [Balanced Shuffle](https://keyj.emphy.de/balanced-shuffle/) algorithm.
- Contains a tool to control Lightware and Extron DVI/HDMI crossbar switches ("matrices") with macro support, running on e.g. a Raspberry Pi with a numeric keypad: [dvi_matrix_control](src/dvi_matrix_control)

## Installation

Just run `setup.cmd`. This will download and unpack all essential programs (except FFmpeg and youtube-dl) into the `bin` directory.

You may also have a look at `bin/setup.ps1` before and update the version-dependent download URLs to the newest releases of the various programs.

To get all the music files (i.e. populate the `music` directory with all the stuff listed in `music/download.txt`), run `bin/download_music.cmd`.

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
  - *no* Direct3D exclusive fullscreen mode (questionable if it would have any benefits on Windows 10; may become extremely problematic when codec errors occur)
- XMPlay
  - starts paused (press P to start playback)
  - OpenMPT plugin is used by default for MOD, S3M, XM and IT formats
    - MOD files use 20% stereo separation and Amiga low-pass filter instead of interpolation
    - S3M, XM, IT use 100% stereo separation and 8-tap interpolation
  - OpenMPT pattern visualization is configured with maximum font size
  - SID is configured for Mono output with 8580 digi boost enabled
  - single-instance mode
  - no title information bubbles in fullscreen mode
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
  - a [manual](Sahli-HOWTO.md) is provided
- typr
  - a `_run.cmd` script is put into the typr directory that launches typr in Chrome
- SumatraPDF
  - English language (regardless of system locale)
  - page layout set to "single page, don't save for every document"
- DOSBox
  - provided config file `dosbox.conf` sets fullscreen with correct aspect ratio, maximum speed (`core=dynamic`, `cycles=max`), 48000 Hz sample rate from all audio sources (including GUS and Covox), and UART mode for the MPU-401 MIDI interface
  - CKLaunch is configured to interpret `.dosbox` files as DOSBox configuration files and runs them with the `dosbox -conf` option
    - This can be used to provide an entry-specific DOSBox configuration: Rename the `.conf` file to `.dosbox` and make sure the entry is auto-started:
      ```
      [autoexec]
      mount C: .
      C:
      whatever.com
      ```
- WinVICE (C64, VIC-20, Plus/4 only)
  - version 3.1 is used, because it's the last non-bloated pure Win32 version
  - scanlines disabled, brightness adjusted to compensate
  - fullscreen mode set to 1080p50 (make sure that mode exists before using Alt+D!)
  - no confirmation on exit
- WinUAE
  - installed in "portable mode"
  - comes with `kickstart13.rom`
  - configuration file `a500.uae` is provided with
    - all settings for maximum Amiga 500 compatibility (with 512k slow RAM expansion)
    - 20% stereo separation
    - launch in fullscreen mode with aspect ratio correction, no GUI
    - exit with Ctrl+F11 enabled
  - wrapper script `runa500.cmd` provided to run a single Amiga executable ("onefiler") by preparing a `dh0:` directory with a suitable `startup-sequence` and running it
    - CKLaunch is configured to run `.a500` and `.amiga` files through that, so simply renaming Amiga 500 4k/64k intros from `.exe` (or whatever) to `.a500` makes them runnable
- Chrome: special settings when run through `bin/Chrome.cmd` and `Sahli/_run.cmd` scripts and CKLaunch's default configuration
  - fullscreen mode
  - `--allow-file-acces-from-files`
  - uses private profile directory (`%TEMP%\cklaunch_chrome_profile`)
    - clean "freshly installed" profile, no user misconfiguration possible
    - forces new instance if Chrome is already running with the default profile
- Firefox: special settings when run through `bin/Firefox.cmd` script
  - uses private profile directory (`%TEMP%\cklaunch_firefox_profile`)
    - clean "freshly installed" profile, no user misconfiguration possible
    - forces new instance if Firefox is already running with the default profile
  - if no filename is specified, opens the `about:config` page with the setting that needs to be disabled to allow file-based demos to run
