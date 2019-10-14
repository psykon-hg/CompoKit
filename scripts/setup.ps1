# CompoKit setup script
#
# Run this script, lean back, and see how the bin/ directory of CompoKit gets
# populated with lots of software and some configuration files.

###############################################################################

##### download URLs #####

# some special syntax options are supported in these URLs:
# - a download filename can be specified explicitly by appending it after
#   a pipe sign ('|') [the default is to derive the download filename from
#   the last path component of the URL]
# - SourceForge downloads (which usually have unwieldy URLs ending in
#   "/download" instead of a proper filename) can be written as
#   "SourceForge:projectname/path/to/file.zip"


# the following URLs are version dependent and may change often;
# below every link, there's another (version independent) URL from which
# the actual download link can be found

$URL_7zip_main = "https://www.7-zip.org/a/7z1900-x64.exe"
# https://www.7-zip.org/ -> latest stable version, .exe 64-bit x64

$URL_totalcmd = "https://totalcommander.ch/win/tcmd922ax64.exe"
# https://www.ghisler.com/download.htm -> 64-bit only

$URL_npp = "http://download.notepad-plus-plus.org/repository/7.x/7.8/npp.7.8.bin.minimalist.7z"
# http://notepad-plus-plus.org/downloads/ -> latest release -> minimalist 7z

$URL_sumatra = "https://www.sumatrapdfreader.org/dl/SumatraPDF-3.1.2-64.zip"
# https://www.sumatrapdfreader.org/download-free-pdf-viewer.html -> 64-bit builds, portable version

$URL_mpc_hc = "https://binaries.mpc-hc.org/MPC%20HomeCinema%20-%20x64/MPC-HC_v1.7.13_x64/MPC-HC.1.7.13.x64.7z"
# https://mpc-hc.org/downloads/ -> for 64-bit Windows, 7z

$URL_xmplay = "http://uk.un4seen.com/files/xmplay38.zip"
# https://www.un4seen.com/xmplay.html -> small download button (top center)

$URL_libopenmpt = "https://lib.openmpt.org/files/libopenmpt/bin/libopenmpt-0.4.9+release.bin.win.zip"
# https://lib.openmpt.org/libopenmpt/download/ -> xmp-openmpt for Windows 7+ (x86 + SSE2)

$URL_dosbox_vanilla = "SourceForge:dosbox/0.74-3/DOSBox0.74-3-win32-installer.exe"
# https://sourceforge.net/projects/dosbox/files/dosbox/ -> latest version -> Win32 installer

$URL_dosbox_x = "https://github.com/joncampbell123/dosbox-x/releases/download/dosbox-x-v0.82.22/dosbox-x-windows-20190930-175141-windows.zip"
# https://github.com/joncampbell123/dosbox-x/releases -> latest dosbox-x-windows-*-windows.zip


# these are generic and not likely to change
# (either because they always point to the latest version,
# or because the software hasn't been changed in years)
$URL_7zip_bootstrap = "https://www.7-zip.org/a/7za920.zip"
$URL_xmp_flac = "http://uk.un4seen.com/files/xmp-flac.zip"
$URL_xmp_opus = "http://uk.un4seen.com/files/xmp-opus.zip"
$URL_xmp_sid = "https://bitbucket.org/ssz/public-files/downloads/xmp-sid.zip"
$URL_xmp_ahx = "https://bitbucket.org/ssz/public-files/downloads/xmp-ahx.zip"
$URL_xmp_ym = "https://www.un4seen.com/stuff/xmp-ym.zip"
$URL_xnview = "https://download.xnview.com/XnView-win-small.zip"
$URL_compoview = "https://files.scene.org/get:nl-http/resources/graphics/compoview_v1_02b.zip"
$URL_gliss = "https://www.emphy.de/~mfie/foo/gliss_new.exe|gliss.exe"
$URL_acidview = "SourceForge:acidview6-win32/6.10/avw-610.zip"
$URL_sahli = "https://github.com/m0qui/Sahli/archive/master.zip|Sahli-master.zip"
$URL_ffmpeg = "http://keyj.emphy.de/ffmpeg_win32_builds/ffmpeg_win32_build_latest.7z"

###############################################################################

# setup and helper functions

# set up directories
$baseDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$cacheDir = Join-Path $baseDir "temp"
$tempDir = Join-Path $cacheDir "temp_extract"
$binDir = Join-Path $baseDir "bin"
cd $baseDir

# add the bin directory to the PATH while we're working on it
if (-not ($env:Path).Contains($binDir)) {
    Set-Item -Path Env:Path -Value ($binDir + ";" + $Env:Path)
}

# check if a file or directory doesn't already exist
function need($obj) {
    return -not (Test-Path $obj)
}

# write a status message
function status($msg) {
    Write-Host -ForegroundColor DarkCyan $msg
}

# write an error message
function error($msg) {
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkRed ("ERROR: " + $msg)
}

# create a directory if it doesn't exist
function mkdir_s($dir) {
    if (need $dir) {
        status ("Creating Directory: " + $dir)
        mkdir $dir > $null
    }
}

# remove temporary extraction directory again
function remove_temp {
    if (Test-Path $tempDir) {
        rm -Recurse -Force $tempDir > $null
    }
}

# get the path of the first subdirectory inside a directory
function subdir_of($dir) {
    $sub = Get-ChildItem $dir -Attributes Directory | select -First 1
    return Join-Path $dir $sub.Name
}

# split a URL into a (URL, filename) tuple
function parse_url($url) {
    # check for filename override
    $parts = $url.split("|")
    if ($parts.Count -gt 1) {
        $url = $parts[0]
        $filename = $parts[-1]
    }
    else {
        $filename = $url.split("?")[0].split("#")[0].trim("/").split("/")[-1]
    }

    # check for SourceForge pseudo-URL
    if ($url.ToLower().StartsWith("sourceforge:")) {
        $url = $url.split(":")[-1]
        $project = $url.split("/")[0]
        $url = "https://sourceforge.net/projects/$project/files/$url/download"
    }

    return @($url, $filename)
}

# download a file into the temp directory and return its path
function download($url) {
    $url, $filename = parse_url $url
    mkdir_s $cacheDir
    $filename = Join-Path $cacheDir $filename
    if (need $filename) {
        status ("Downloading: " + $url)
        $tempfile = $filename + ".part"
        if (Test-Path $tempfile) { rm $tempfile >$null }
        try {
            (New-Object System.Net.WebClient).DownloadFile($url, $tempfile)
        }
        catch {
            error ("failed to download " + $url + "`n(this may cause some subsequent errors, which may be ignored)")
            return ""
        }
        mv $tempfile $filename >$null
    }
    return $filename
}

# extract (specific files from) an archive, disregarding paths
function extract {
    Param(
        [string] $archive,
        [parameter(ValueFromRemainingArguments=$true)] [string[]] $args
    )
    if (-not $archive) { return }
    status ("Extracting: " + $archive)
    7z -y e $archive @args > $null
}

# extract an archive into a temporary directory and return its path
function extract_temp($archive) {
    if (-not $archive) { return }
    remove_temp
    mkdir $tempDir > $null
    status ("Extracting: " + $archive)
    $cwd = pwd
    cd $tempDir
    7z -y x $archive > $null
    cd $cwd.Path
    return $tempDir
}

# move a bunch of files from the source directory to the current directory
function collect($fromDir, $items) {
    $targetDir = (pwd).Path
    cd $fromDir
    foreach ($item in $items) {
        if (-not (Test-Path (Join-Path $targetDir $item))) {
            mv $item $targetDir
        }
    }
    cd $targetDir
}

# create a text file with specific content (if it doesn't exist already)
function config($filename, $contents="") {
    if (need $filename) {
        status ("Creating File: " + $filename)
        New-Item -Name $filename -Value $contents > $null
    }
}

###############################################################################

# populate the bin directory
mkdir_s $binDir
cd $binDir
$hadCache = Test-Path $cacheDir


##### 7-zip #####

if (need "7z.exe") {
    # bootstrapping: download the old 9.20 x86 executable first;
    # it's the only one that comes in .zip format and can be extracted
    # by PowerShell itself
    $f = download $URL_7zip_bootstrap
    status("Extracting: " + $f)
    Expand-Archive -Path $f -DestinationPath . > $null
    rm @("7-zip.chm", "license.txt", "readme.txt")  # remove unwanted stuff

    # now we can download and extract the current version
    $f = download $URL_7zip_main
    status ("Extracting: " + $f)
    7za -y e $f 7z.dll 7z.exe 7zFM.exe 7zG.exe > $null
    rm "7za.exe" >$null  # we don't need the old standalone version any longer
}


##### Total Commander #####

if (need "totalcmd64.exe") {
    # tcmd's download file is an installer that contains a .cab file
    # with the actual data; thus we need to extract the .cab first
    $cab = Join-Path $cacheDir "tcmd.cab"
    if (need $cab) {
        cd $cacheDir
        extract (download $URL_totalcmd) INSTALL.CAB
        mv INSTALL.CAB $cab
        cd $binDir
    }

    # now we can extract the actual files, but we need to turn
    # their names into lowercase too
    $tcfiles = @(
        "TOTALCMD64.EXE", "TOTALCMD64.EXE.MANIFEST",
        "WCMZIP64.DLL", "UNRAR64.DLL", "TC7Z64.DLL", "TCLZMA64.DLL", "TCUNZL64.DLL",
        "NOCLOSE64.EXE", "TCMADM64.EXE", "TOTALCMD.INC"
    )
    extract $cab @tcfiles
    foreach ($f in $tcfiles) { mv $f $f.ToLower() }
}
config "wincmd.ini" @"
[Configuration]
UseIniInProgramDir=7
UseNewDefFont=1
FirstTime=0
FirstTimeIconLib=0
onlyonce=1
ShowHiddenSystem=1
UseTrash=0
AltSearch=3
Editor=notepad++.exe "%1"
[AllResolutions]
FontName=Segoe UI
FontSize=10
FontWeight=400
FontNameWindow=Segoe UI
FontSizeWindow=10
FontWeightWindow=400
FontNameDialog=Segoe UI
FontSizeDialog=9
[Shortcuts]
F2=cm_RenameSingleFile
[Colors]
InverseCursor=1
ThemedCursor=0
InverseSelection=0
BackColor=6316128
BackColor2=-1
ForeColor=14737632
MarkColor=65280
CursorColor=10526880
CursorText=16777215
[right]
path=$baseDir
"@
config "wcx_ftp.ini" @"
[default]
pasvmode=1
"@


##### Notepad++, SumatraPDF #####

if (need "notepad++.exe") {
    extract (download $URL_npp) notepad++.exe SciLexer.dll doLocalConf.xml langs.model.xml stylers.model.xml
    if (need langs.xml)   { mv langs.model.xml   langs.xml   >$null }
    if (need stylers.xml) { mv stylers.model.xml stylers.xml >$null }
}

if (need "SumatraPDF.exe") {
    extract (download $URL_sumatra) SumatraPDF.exe
}
config "SumatraPDF-settings.txt" @"
UiLanguage = en
CheckForUpdates = false
RememberStatePerDocument = false
DefaultDisplayMode = single page
"@


##### MPC-HC #####

if (need "mpc-hc64.exe") {
    collect (subdir_of (extract_temp (download $URL_mpc_hc))) @(
        "LAVFilters64", "Shaders",
        "D3DCompiler_43.dll", "d3dx9_43.dll",
        "mpc-hc64.exe"
    )
    remove_temp
}
config "mpc-hc64.ini" @"
[Settings]
AfterPlayback=0
AllowMultipleInstances=0
ExitFullscreenAtTheEnd=0
LaunchFullScreen=1
Loop=0
LoopMode=1
LoopNum=0
MenuLang=0
ShowOSD=0
TrayIcon=0
UpdaterAutoCheck=0
LogoExt=0
LogoID2=206
DSVidRen=13
DX9Resizer=4
SynchronizeClock=1
SynchronizeDisplay=0
SynchronizeNearest=0
[Commands2]
CommandMod0=816 1 51 "" 5 0 0 0
"@
# cf. https://www.pouet.net/topic.php?which=11591&page=18#c553418


##### XMPlay #####

if (need "xmplay.exe") {
    extract (download $URL_xmplay) xmplay.exe xmp-zip.dll xmp-wma.dll
}
if (need "xmp-openmpt.dll") {
    extract (download $URL_libopenmpt) XMPlay/openmpt-mpg123.dll XMPlay/xmp-openmpt.dll
}
if (need "xmp-flac.dll") {
    extract (download $URL_xmp_flac) xmp-flac.dll
}
if (need "xmp-opus.dll") {
    extract (download $URL_xmp_opus) xmp-opus.dll
}
if (need "xmp-sid.dll") {
    extract (download $URL_xmp_sid) xmp-sid.dll
}
if (need "xmp-ahx.dll") {
    extract (download $URL_xmp_ahx) xmp-ahx.dll
}
if (need "xmp-ym.dll") {
    extract (download $URL_xmp_ym) xmp-ym.dll
}
config "xmplay.ini" @"
[XMPlay]
PluginTypes=786D702D6F70656E6D70742E646C6C006D6F642073336D20786D20697400
MODmode=2
InfoTextSize=3
Info=-2147220736
MultiInstance=0
AutoSet=1
Bubbles=1
TitleTray=0
[SID_27]
config=00FF70FF7F095000002C018813B80B1932
[OpenMPT]
UseAmigaResampler=1
"@
if (need "xmplay.set") {
    # XMPlay's preset file is an ugly binary blob :(
    status ("Creating File: xmplay.set")
    $data = [byte[]] @()
    foreach ($spec in @("IT:8:100", "MOD:1:20", "S3M:8:100", "XM:8:100")) {
        $fmt, $interpol, $stereo = $spec.Split(":")
        $cfg = "xmp-openmpt.dll`0<settings InterpolationFilterLength=`"$interpol`" StereoSeparation_Percent=`"$stereo`"/>`0"
        $item = [System.Text.Encoding]::UTF8.GetBytes($fmt)
        $item += [byte[]] @(0, ($cfg.Length + 2), 0,0,0, $cfg.Length, 0)
        $item += [System.Text.Encoding]::UTF8.GetBytes($cfg)
        $data += [byte[]] @(($item.Count + 4), 0, 3, 0x20) + $item
    }
    $data | Set-Content -Path "xmplay.set" -Encoding Byte
}


##### XnView #####

if (need "xnview.exe") {
    extract (download $URL_xnview) XnView/xnview.exe XnView/xnview.exe.manifest
}
config "xnview.ini" @"
[Cache]
SavingMode=1
[Start]
ParamsSavingMode=1
SavingMode=1
BToolBar=0
VToolBar=0
TabBar=0
LaunchTimes=1
ShowAgain=268435422
InFullscreen=1
Only1ESC=1
ENTER=0
MMB=2
Filter0=65
Filter1=65
Filter2=64
Filter3=1
[Browser]
AutoPlay=0
ShowPreview=0
UseFileDB=0
UseShadow=0
FlatStyle=1
Spacing=2
IconHeight=128
IconWidth=192
IconInfo=0
UseColor=0
UseBackgroundColor=1
BackgroundColor=6316128
PreviewColor=6316128
TextBackColor=6316128
TextColor=14737632
ThumbConfig=11
[View]
PlayMovie=0
PlaySound=0
BackgroundColor=6316128
OneViewMultiple=1
OnlyOneView=1
RightButtonFlag=1
ShowText=0
DirKeyVFlag=1
[Cache]
IsActive=0
[Full]
UseDelay=0
[File]
LosslessBak=0
"@


##### CompoView, GLISS, ACiDview #####

if (need "compoview_64.exe") {
    extract (download $URL_compoview) compoview/compoview_64.exe
}
if (need "gliss.exe") {
    mv (download $URL_gliss) .
}
if (need "ACiDview.exe") {
    extract (download $URL_acidview) ACiDview.exe
}


##### Sahli, Chrome #####

cd $baseDir
if (need "Sahli") {
    mv (subdir_of (extract_temp (download $URL_sahli))) "Sahli"
    remove_temp
}
config "Sahli/_run.cmd" @"
@"%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" --user-data-dir="%~dp0\..\temp\chrome" --allow-file-access-from-files --start-fullscreen "file://%~dp0/index.html"
"@

cd $binDir
config "Chrome.cmd" @"
@"%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" --user-data-dir="%~dp0\..\temp\chrome" --allow-file-access-from-files --start-fullscreen "%1"
"@


##### DOSBox(-X) #####

if (need "dosbox.exe") {
    extract (download $URL_dosbox_vanilla) DOSBox.exe SDL.dll SDL_net.dll
}
config "dosbox.conf" @"
[sdl]
fullscreen=true
fullresolution=desktop
output=ddraw
[render]
aspect=true
[cpu]
core=dynamic
cycles=max
[mixer]
rate=48000
[sblaster]
oplrate=48000
[gus]
gus=true
gusrate=48000
[speaker]
pcrate=48000
tandyrate=48000
disney=true
[midi]
mpu401=uart
"@
if (need "dosbox-x.exe") {
    extract (download $URL_dosbox_x) bin/x64/Release/dosbox-x.exe
}


##### FFmpeg and some other multimedia stuff #####

if (need "ffmpeg.exe") {
	extract (download $URL_ffmpeg) bin64/ffmpeg.exe bin64/ffprobe.exe bin64/ffplay.exe bin64/lame.exe
}
config "setpath.cmd" @"
@set PATH=%~dp0;%PATH%
@echo CompoKit binary directory has been added to the PATH.
"@


##### Done! #####

if ((-not $hadCache) -and (Test-Path $cacheDir)) {
    Write-Host -ForegroundColor Green "Everything set up. You can now delete the temp directory if you like:"
    Write-Host -ForegroundColor Green "   rmdir /s /q $cacheDir"
}
