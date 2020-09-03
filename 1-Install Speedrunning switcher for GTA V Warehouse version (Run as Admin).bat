@echo off
ECHO This should be considered an ALPHA release. Please ensure that you have taken a BACKUP of your Entire PC, particularly any Mods, etc. installed for GTA V. 
ECHO NO RESPONSIBILITY TAKEN for any problems whatsoever which may occur from running this script, including the unlikely event of a ban from Rockstar.
ECHO If you do not agree, press the [X] In the top-right corner to cancel now. Or if you accept,
pause
ECHO.
ECHO Note: The Latest version of Rockstar Launcher will be installed and will also update GTA V to the latest version. 
ECHO If you have Mods installed, these might need to be updated. Be Careful about accessing GTA Online with Mods,
ECHO however this tool by itself is unlikely to interfere with GTA Online.
ECHO.
pause


rem ==== START EDITABLE CONFIG ZONE - YOU CHANGE THIS PATH IF YOU HAVE GTA V ON A DRIVE OTHER THAN C: ====

set RSG_Root=C:\Program Files\Rockstar Games

REM ==== END EDITABLE CONFIG ZONE ====

REM Starting Variables and Check for Admin

set SRS_Root=%RSG_Root%\SpeedrunningSwitcher
set GTAV_Current=%RSG_Root%\Grand Theft Auto V
set GTAV_Main=%RSG_Root%\Grand Theft Auto V.Main
set GTAV_Speedrunning=%RSG_Root%\Grand Theft Auto V.Speedrunning
set RSSC_Current=C:\Program Files\Rockstar Games\Social Club
set RSSC_Main=C:\Program Files\Rockstar Games\Social Club.Main
set RSSC_Speedrunning=C:\Program Files\Rockstar Games\Social Club.Speedrunning

set StartingDir=%cd%
net.exe session 1>NUL 2>NUL || (GOTO ERR_Admin)


REM Put in place the Initial Directory Structure

mkdir "%SRS_Root%"
mkdir "%SRS_Root%\Restored"
mkdir "%SRS_Root%\Backup-RSSC-v1.1.7.8"

REM Check if files needed to be restored are in place

IF NOT EXIST "%SRS_Root%\Restored\update.rpf" GOTO ERR_Restored
IF NOT EXIST "%SRS_Root%\Restored\GFSDK_ShadowLib.win64.dll" GOTO ERR_Restored
IF NOT EXIST "%SRS_Root%\Restored\GTA5.exe" GOTO ERR_Restored
IF NOT EXIST "%SRS_Root%\Restored\GTAVLauncher.exe" GOTO ERR_Restored
IF NOT EXIST "%SRS_Root%\Restored\x64a.rpf" GOTO ERR_Restored

REM Cleanup
rmdir /s /q "%RSG_Root%\Grand Theft Auto V.Speedrunning"
rmdir /s /q "%RSG_Root%\Social Club.Speedrunning"
rmdir /s /q "%RSG_Root%\Social Club.Main"
rmdir /s /q "%RSG_Root%\Social Club"

REM Download required files from the Internet where officially available

mkdir "%SRS_Root%\Downloaded"
cd /d "%SRS_Root%\Downloaded"
IF NOT EXIST "Social-Club-v1.1.7.8-Setup.exe" powershell "Invoke-WebRequest -Uri 'http://patches.rockstargames.com/prod/socialclub/Social-Club-v1.1.7.8-Setup.exe' -OutFile 'Social-Club-v1.1.7.8-Setup.exe' -UseBasicParsing"

FOR /F %%i IN ('powershell "(Get-Item -path Rockstar-Games-Launcher.exe).VersionInfo.FileVersion"') DO (SET rs_launcher_installer_ver=%%i)
echo INFO: rs_launcher_installer_ver: %rs_launcher_installer_ver%
IF %rs_launcher_installer_ver% == 1.0.27.272 GOTO SKIP_RSGL_DOWNLOAD
IF EXIST "Rockstar-Games-Launcher.exe" echo del /q Rockstar-Games-Launcher.exe
powershell "Invoke-WebRequest -Uri 'https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe' -OutFile 'Rockstar-Games-Launcher.exe' -UseBasicParsing"
:SKIP_RSGL_DOWNLOAD

REM Firewall block the old 1.27 version since Online mode doesn't work anyway and will error out in Online mode anyway. Contingency in case -scOfflineOnly is missing. Also better security. Does not affect the new GTA versions with R* Launcher.

powershell "New-NetFirewallRule -DisplayName 'aaa Block GTAV Speedrunning version - Launcher' -Direction Outbound -Program '%GTAV_Current%\GTAVLauncher.exe' -RemoteAddress Any -Action Block"
powershell "New-NetFirewallRule -DisplayName 'aaa Block GTAV Speedrunning version - Socialclub' -Direction Outbound -Program '%ProgramFiles%\Rockstar Games\Social Club\subprocess.exe' -RemoteAddress Any -Action Block"

REM Fresh start is to make sure we are on the Latest Launcher and it works in the latest version in the first place
cd /d "%SRS_Root%\Downloaded"
ECHO.
ECHO Setup will now prompt you to install the Rockstar Launcher. 
ECHO Please do it even if you already have it. We need a baseline to make sure everything is working properly.
ECHO Please launch GTA V, make sure it is opens properly in the latest version, and then quit GTA V completely.
ECHO NOTE: Make sure you run the Launcher after the install, Accept UAC prompts and 'Auto Sign-In'
ECHO ADDITIONAL NOTE: The Launcher may take around 30 seconds to detect that Grand Theft Auto V is installed once in.
ECHO Then come back here and

Rockstar-Games-Launcher.exe
Pause
ECHO.
ECHO Please click on this Window again and press any key once you have tested that GTA V is working. Please make sure that you exit out of GTA V and Rockstar Launcher completely
ECHO.
Pause

REM Better make sure it's really closed before we mess around (some more)
taskkill /F /IM GTA5.exe
taskkill /F /IM GTAVLauncher.exe
taskkill /F /IM LauncherPatcher.exe
taskkill /F /IM Launcher.exe
taskkill /F /IM RockstarService.exe
Echo Note that the above errors are normal
ping -n 10 127.0.0.1 > nul
taskkill /F /IM GTA5.exe
taskkill /F /IM GTAVLauncher.exe
taskkill /F /IM LauncherPatcher.exe
taskkill /F /IM Launcher.exe
taskkill /F /IM RockstarService.exe
echo Note that the above errors are normal

REM Remove the new Social Club so that we can temporarily install the old one and take a snapshot of it
ECHO.
ECHO We are now going to install the old Social Club to take a snapshot, but first we need to remove the current one.
ECHO Please follow the prompts to uninstall Social Club and then come back here
ECHO.
"%RSSC_Current%\uninstallRGSCRedistributable.exe"
pause
ECHO.
ECHO Please click on this Window again and press any key once you have uninstalled Social Club.
ECHO When done, please follow the prompts to install the old version Social Club
ECHO Click back onto this window again when done
"%SRS_Root%\Downloaded\Social-Club-v1.1.7.8-Setup.exe" /1033
ECHO.  

xcopy /S /Y "%RSSC_Current%\*.*" "%RSSC_Speedrunning%\"
ECHO.
ECHO Snapshot has been completed, we are now going to remove the old one.
ECHO Please follow the prompts to uninstall Social Club and then come back here, and then 
ECHO.
"%RSSC_Current%\uninstallRGSCRedistributable.exe"
pause

REM Install Latest Launcher and tell user to test
cd /d "%SRS_Root%\Downloaded"
ECHO.
ECHO Setup will now prompt you to install the Rockstar Launcher (again). 
ECHO  It will re-install the latest Social Club automatically.
ECHO Please launch GTA V to make sure it is opens properly in the latest version, and then quit GTA V completely.
ECHO NOTE: Make sure you run the Launcher after the install, Accept UAC prompts and 'Auto Sign-In'
ECHO ADDITIONAL NOTE: The Launcher may take around 30 seconds to detect that Grand Theft Auto V is installed once in.
ECHO Then come back here and

Rockstar-Games-Launcher.exe
Pause
ECHO.
ECHO Please click on this Window again and press any key once you have tested that GTA V is working. Please make sure that you exit out of GTA V and Rockstar Launcher completely
ECHO.
Pause

REM Better make sure it's really closed before we mess around (some more)
taskkill /F /IM GTA5.exe
taskkill /F /IM GTAVLauncher.exe
taskkill /F /IM LauncherPatcher.exe
taskkill /F /IM Launcher.exe
taskkill /F /IM RockstarService.exe
Echo Note that the above errors are normal
ping -n 10 127.0.0.1 > nul
taskkill /F /IM GTA5.exe
taskkill /F /IM GTAVLauncher.exe
taskkill /F /IM LauncherPatcher.exe
taskkill /F /IM Launcher.exe
taskkill /F /IM RockstarService.exe
echo Note that the above errors are normal

REM Setup, make the switch the first time and test the old version...

REM some Sanity checks to make sure we not Downgrading an already Downgraded version
cd /d "%GTAV_Current%"
FOR /F %%i IN ('powershell "(Get-Item -path gta5.exe).VersionInfo.ProductVersion"') DO (SET gtav_warehouse_ver=%%i)
cd /d "%RSSC_Current%"
FOR /F %%i IN ('powershell "(Get-Item -path socialclub.dll).VersionInfo.ProductVersion"') DO (SET gtav_socialclub_ver=%%i)
echo INFO: gtav_warehouse_ver: %gtav_warehouse_ver%
echo INFO: gtav_socialclub_ver: %gtav_socialclub_ver%
IF %gtav_warehouse_ver% == 1.0.372.2 GOTO ERR_AlreadyDowngraded
IF %gtav_socialclub_ver% == 1.1.7.8 GOTO ERR_AlreadyDowngraded


REM Create the Main Directory Structure for the new GTA V install

mkdir "%GTAV_Speedrunning%"
mkdir "%GTAV_Speedrunning%\update"
mkdir "%GTAV_Speedrunning%\update\x64"
mkdir "%GTAV_Speedrunning%\update\x64\data\"
mkdir "%GTAV_Speedrunning%\update\x64\data\errorcodes"
mkdir "%GTAV_Speedrunning%\update\x64\dlcpacks\mpchristmas2"
mkdir "%GTAV_Speedrunning%\update\x64\dlcpacks\mpheist"
mkdir "%GTAV_Speedrunning%\update\x64\dlcpacks\mpluxe"
mkdir "%GTAV_Speedrunning%\update\x64\dlcpacks\mppatchesng"
mkdir "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday1ng"
mkdir "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday2bng"
mkdir "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday2ng"
mkdir "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday3ng"
mkdir "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday4ng"

mkdir "%GTAV_Speedrunning%\x64"
mkdir "%GTAV_Speedrunning%\x64\audio"
mkdir "%GTAV_Speedrunning%\x64\audio\sfx"
mkdir "%GTAV_Speedrunning%\x64\data"
mkdir "%GTAV_Speedrunning%\x64\data\errorcodes"

REM copy some of the smaller files in place to the new GTAV install rather than hardlinking to avoid potential problems.

copy /Y "%GTAV_Current%\bink2w64.dll" "%GTAV_Speedrunning%"
copy /Y "%GTAV_Current%\d3dcompiler_46.dll" "%GTAV_Speedrunning%"
copy /Y "%GTAV_Current%\d3dcsx_46.dll" "%GTAV_Speedrunning%"
rem copy /Y "%GTAV_Current%\GFSDK_ShadowLib.win64.dll" "%GTAV_Speedrunning%"
copy /Y "%GTAV_Current%\GFSDK_TXAA.win64.dll" "%GTAV_Speedrunning%"
copy /Y "%GTAV_Current%\GFSDK_TXAA_AlphaResolve.win64.dll" "%GTAV_Speedrunning%"
copy /Y "%GTAV_Current%\GPUPerfAPIDX11-x64.dll" "%GTAV_Speedrunning%"
copy /Y "%GTAV_Current%\NvPmApi.Core.win64.dll" "%GTAV_Speedrunning%"
copy /Y "%GTAV_Current%\version.txt" "%GTAV_Speedrunning%"

copy /Y "%GTAV_Current%\update\x64\metadata.dat" "%GTAV_Speedrunning%\update\x64"
copy /Y "%GTAV_Current%\update\x64\data\errorcodes\*.txt" "%GTAV_Speedrunning%\update\x64\data\errorcodes"
copy /Y "%GTAV_Current%\x64\metadata.dat" "%GTAV_Speedrunning%\x64"
copy /Y "%GTAV_Current%\x64\data\errorcodes\*.txt" "%GTAV_Speedrunning%\x64\data\errorcodes"

xcopy /S /Y "%GTAV_Current%\ReadMe\*.*" "%GTAV_Speedrunning%\ReadMe\"

REM Now restore the files from the Backup which are needed to downgrade

copy /Y "%SRS_Root%\Restored\update.rpf" "%GTAV_Speedrunning%\update"
copy /Y "%SRS_Root%\Restored\GFSDK_ShadowLib.win64.dll" "%GTAV_Speedrunning%"
copy /Y "%SRS_Root%\Restored\GTA5.exe" "%GTAV_Speedrunning%"
copy /Y "%SRS_Root%\Restored\GTAVLauncher.exe" "%GTAV_Speedrunning%"
copy /Y "%SRS_Root%\Restored\x64a.rpf" "%GTAV_Speedrunning%"

REM Now the hardlinking bit to save a lot of disk space

mklink /H "%GTAV_Speedrunning%\common.rpf" "%GTAV_Current%\common.rpf"
rem mklink /H "%GTAV_Speedrunning%\x64a.rpf" "%GTAV_Current%\x64a.rpf"
mklink /H "%GTAV_Speedrunning%\x64b.rpf" "%GTAV_Current%\x64b.rpf"
mklink /H "%GTAV_Speedrunning%\x64c.rpf" "%GTAV_Current%\x64c.rpf"
mklink /H "%GTAV_Speedrunning%\x64d.rpf" "%GTAV_Current%\x64d.rpf"
mklink /H "%GTAV_Speedrunning%\x64e.rpf" "%GTAV_Current%\x64e.rpf"
mklink /H "%GTAV_Speedrunning%\x64f.rpf" "%GTAV_Current%\x64f.rpf"
mklink /H "%GTAV_Speedrunning%\x64g.rpf" "%GTAV_Current%\x64g.rpf"
mklink /H "%GTAV_Speedrunning%\x64h.rpf" "%GTAV_Current%\x64h.rpf"
mklink /H "%GTAV_Speedrunning%\x64i.rpf" "%GTAV_Current%\x64i.rpf"
mklink /H "%GTAV_Speedrunning%\x64j.rpf" "%GTAV_Current%\x64j.rpf"
mklink /H "%GTAV_Speedrunning%\x64k.rpf" "%GTAV_Current%\x64k.rpf"
mklink /H "%GTAV_Speedrunning%\x64l.rpf" "%GTAV_Current%\x64l.rpf"
mklink /H "%GTAV_Speedrunning%\x64m.rpf" "%GTAV_Current%\x64m.rpf"
mklink /H "%GTAV_Speedrunning%\x64n.rpf" "%GTAV_Current%\x64n.rpf"
mklink /H "%GTAV_Speedrunning%\x64o.rpf" "%GTAV_Current%\x64o.rpf"
mklink /H "%GTAV_Speedrunning%\x64p.rpf" "%GTAV_Current%\x64p.rpf"
mklink /H "%GTAV_Speedrunning%\x64q.rpf" "%GTAV_Current%\x64q.rpf"
mklink /H "%GTAV_Speedrunning%\x64r.rpf" "%GTAV_Current%\x64r.rpf"
mklink /H "%GTAV_Speedrunning%\x64s.rpf" "%GTAV_Current%\x64s.rpf"
mklink /H "%GTAV_Speedrunning%\x64t.rpf" "%GTAV_Current%\x64t.rpf"
mklink /H "%GTAV_Speedrunning%\x64u.rpf" "%GTAV_Current%\x64u.rpf"
mklink /H "%GTAV_Speedrunning%\x64v.rpf" "%GTAV_Current%\x64v.rpf"
mklink /H "%GTAV_Speedrunning%\x64w.rpf" "%GTAV_Current%\x64w.rpf"

rem mklink /H "%GTAV_Speedrunning%\update\update.rpf" "%GTAV_Current%\update\update.rpf"
mklink /H "%GTAV_Speedrunning%\update\x64\dlcpacks\mpchristmas2\dlc.rpf" "%GTAV_Current%\update\x64\dlcpacks\mpchristmas2\dlc.rpf"
mklink /H "%GTAV_Speedrunning%\update\x64\dlcpacks\mpheist\dlc.rpf" "%GTAV_Current%\update\x64\dlcpacks\mpheist\dlc.rpf"
mklink /H "%GTAV_Speedrunning%\update\x64\dlcpacks\mpluxe\dlc.rpf" "%GTAV_Current%\update\x64\dlcpacks\mpluxe\dlc.rpf"
mklink /H "%GTAV_Speedrunning%\update\x64\dlcpacks\mppatchesng\dlc.rpf" "%GTAV_Current%\update\x64\dlcpacks\mppatchesng\dlc.rpf"
mklink /H "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday1ng\dlc.rpf" "%GTAV_Current%\update\x64\dlcpacks\patchday1ng\dlc.rpf"
mklink /H "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday2bng\dlc.rpf" "%GTAV_Current%\update\x64\dlcpacks\patchday2bng\dlc.rpf"
mklink /H "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday2ng\dlc.rpf" "%GTAV_Current%\update\x64\dlcpacks\patchday2ng\dlc.rpf"
mklink /H "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday3ng\dlc.rpf" "%GTAV_Current%\update\x64\dlcpacks\patchday3ng\dlc.rpf"
mklink /H "%GTAV_Speedrunning%\update\x64\dlcpacks\patchday4ng\dlc.rpf" "%GTAV_Current%\update\x64\dlcpacks\patchday4ng\dlc.rpf"

mklink /H "%GTAV_Speedrunning%\x64\audio\audio_rel.rpf" "%GTAV_Current%\x64\audio\audio_rel.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\occlusion.rpf" "%GTAV_Current%\x64\audio\occlusion.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\ANIMALS.rpf" "%GTAV_Current%\x64\audio\sfx\ANIMALS.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\ANIMALS_FAR.rpf" "%GTAV_Current%\x64\audio\sfx\ANIMALS_FAR.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\ANIMALS_NEAR.rpf" "%GTAV_Current%\x64\audio\sfx\ANIMALS_NEAR.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\CUTSCENE_MASTERED_ONLY.rpf" "%GTAV_Current%\x64\audio\sfx\CUTSCENE_MASTERED_ONLY.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\DLC_GTAO.rpf" "%GTAV_Current%\x64\audio\sfx\DLC_GTAO.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\INTERACTIVE_MUSIC.rpf" "%GTAV_Current%\x64\audio\sfx\INTERACTIVE_MUSIC.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\ONESHOT_AMBIENCE.rpf" "%GTAV_Current%\x64\audio\sfx\ONESHOT_AMBIENCE.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\PAIN.rpf" "%GTAV_Current%\x64\audio\sfx\PAIN.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\POLICE_SCANNER.rpf" "%GTAV_Current%\x64\audio\sfx\POLICE_SCANNER.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\PROLOGUE.rpf" "%GTAV_Current%\x64\audio\sfx\PROLOGUE.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_01_CLASS_ROCK.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_01_CLASS_ROCK.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_02_POP.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_02_POP.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_03_HIPHOP_NEW.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_03_HIPHOP_NEW.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_04_PUNK.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_04_PUNK.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_05_TALK_01.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_05_TALK_01.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_06_COUNTRY.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_06_COUNTRY.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_07_DANCE_01.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_07_DANCE_01.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_08_MEXICAN.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_08_MEXICAN.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_09_HIPHOP_OLD.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_09_HIPHOP_OLD.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_11_TALK_02.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_11_TALK_02.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_12_REGGAE.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_12_REGGAE.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_13_JAZZ.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_13_JAZZ.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_14_DANCE_02.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_14_DANCE_02.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_15_MOTOWN.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_15_MOTOWN.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_16_SILVERLAKE.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_16_SILVERLAKE.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_17_FUNK.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_17_FUNK.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_18_90S_ROCK.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_18_90S_ROCK.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_ADVERTS.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_ADVERTS.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RADIO_NEWS.rpf" "%GTAV_Current%\x64\audio\sfx\RADIO_NEWS.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\RESIDENT.rpf" "%GTAV_Current%\x64\audio\sfx\RESIDENT.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\SCRIPT.rpf" "%GTAV_Current%\x64\audio\sfx\SCRIPT.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\SS_AC.rpf" "%GTAV_Current%\x64\audio\sfx\SS_AC.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\SS_DE.rpf" "%GTAV_Current%\x64\audio\sfx\SS_DE.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\SS_FF.rpf" "%GTAV_Current%\x64\audio\sfx\SS_FF.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\SS_GM.rpf" "%GTAV_Current%\x64\audio\sfx\SS_GM.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\SS_NP.rpf" "%GTAV_Current%\x64\audio\sfx\SS_NP.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\SS_QR.rpf" "%GTAV_Current%\x64\audio\sfx\SS_QR.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\SS_ST.rpf" "%GTAV_Current%\x64\audio\sfx\SS_ST.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\SS_UZ.rpf" "%GTAV_Current%\x64\audio\sfx\SS_UZ.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\STREAMED_AMBIENCE.rpf" "%GTAV_Current%\x64\audio\sfx\STREAMED_AMBIENCE.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\STREAMED_VEHICLES.rpf" "%GTAV_Current%\x64\audio\sfx\STREAMED_VEHICLES.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\STREAMED_VEHICLES_GRANULAR.rpf" "%GTAV_Current%\x64\audio\sfx\STREAMED_VEHICLES_GRANULAR.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\STREAMED_VEHICLES_GRANULAR_NPC.rpf" "%GTAV_Current%\x64\audio\sfx\STREAMED_VEHICLES_GRANULAR_NPC.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\STREAMED_VEHICLES_LOW_LATENCY.rpf" "%GTAV_Current%\x64\audio\sfx\STREAMED_VEHICLES_LOW_LATENCY.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\STREAMS.rpf" "%GTAV_Current%\x64\audio\sfx\STREAMS.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\S_FULL_AMB_F.rpf" "%GTAV_Current%\x64\audio\sfx\S_FULL_AMB_F.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\S_FULL_AMB_M.rpf" "%GTAV_Current%\x64\audio\sfx\S_FULL_AMB_M.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\S_FULL_GAN.rpf" "%GTAV_Current%\x64\audio\sfx\S_FULL_GAN.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\S_FULL_SER.rpf" "%GTAV_Current%\x64\audio\sfx\S_FULL_SER.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\S_MINI_AMB.rpf" "%GTAV_Current%\x64\audio\sfx\S_MINI_AMB.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\S_MINI_GAN.rpf" "%GTAV_Current%\x64\audio\sfx\S_MINI_GAN.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\S_MINI_SER.rpf" "%GTAV_Current%\x64\audio\sfx\S_MINI_SER.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\S_MISC.rpf" "%GTAV_Current%\x64\audio\sfx\S_MISC.rpf"
mklink /H "%GTAV_Speedrunning%\x64\audio\sfx\WEAPONS_PLAYER.rpf" "%GTAV_Current%\x64\audio\sfx\WEAPONS_PLAYER.rpf"

REM backup the old RSSC 1.1.7.8
xcopy /S /Y "%RSSC_Speedrunning%\*.*" "%SRS_Root%\Backup-RSSC-v1.1.7.8\"

REM do the switch to old
cd /d "C:\Program Files\Rockstar Games"
ren "Social Club" "Social Club.Main"
ren "Social Club.Speedrunning" "Social Club"
cd /d "%RSG_Root%"
ren "Grand Theft Auto V" "Grand Theft Auto V.Main"
ren "Grand Theft Auto V.Speedrunning" "Grand Theft Auto V" 

REM now TEST
ECHO.
ECHO We are now going to test GTA V 1.27 - The speedrunning version. Please test that it works.
ECHO.
pause
"%GTAV_Current%\GTAVLauncher.exe" -scOfflineOnly
ECHO Please exit GTA V and Social Club completely click back to this window when done and then 
pause
taskkill /F /IM GTA5.exe
taskkill /F /IM GTAVLauncher.exe
taskkill /F /IM LauncherPatcher.exe
taskkill /F /IM Launcher.exe
taskkill /F /IM RockstarService.exe
echo Note that the above errors are normal
ping -n 10 127.0.0.1 > nul
taskkill /F /IM GTA5.exe
taskkill /F /IM GTAVLauncher.exe
taskkill /F /IM LauncherPatcher.exe
taskkill /F /IM Launcher.exe
taskkill /F /IM RockstarService.exe
echo Note that the above errors are normal

ECHO.
ECHO We are switching back to the new version again now to test that it still works and no redownloading.
ECHO.
pause
cd /d "C:\Program Files\Rockstar Games"
ren "Social Club" "Social Club.Speedrunning"
ren "Social Club.Main" "Social Club"
cd /d "%RSG_Root%"
ren "Grand Theft Auto V" "Grand Theft Auto V.Speedrunning"
ren "Grand Theft Auto V.Main" "Grand Theft Auto V" 
"%RSG_Root%\Launcher\LauncherPatcher.exe"
ECHO Please click back here when you have finished testing and then
pause
ECHO.
ECHO Install completed! Enjoy!
ECHO.

GOTO END

:ERR_Admin
ECHO.
ECHO Error: Please right click on this script and "Run as administrator"
ECHO.
GOTO end

:ERR_Restored
ECHO.
ECHO Error: Please restore The following files from your original backup of GTA version 1.27:
ECHO - \GFSDK_ShadowLib.win64.dll
ECHO - \GTA5.exe
ECHO - \GTAVLauncher.exe
ECHO - \x64a.rpf
ECHO - \update\update.rpf 
ECHO and restore it to the %SpeedrunningSwitcher%\Restored\ folder
ECHO (Note: update.rpf is NOT to be put in a subfolder under Restored)
ECHO.
GOTO end

:ERR_AlreadyDowngraded
ECHO.
ECHO Error: Please make sure that your "%GTAV_Current% folder is up to date as well as Social Club. 
ECHO - You can check this by running GTA V normally via. the Rockstar Launcher.
ECHO - Re-install the Rockstar Launcher if you don't have it working.
ECHO.
GOTO end

:end
cd /d %StartingDir%
pause
