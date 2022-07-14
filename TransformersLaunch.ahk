WinClose, % "ahk_id " Instances%A_Index%


/*

To Do:

*/

;@Ahk2Exe-SetMainIcon matrix.ico
FileInstall, imgs/TFLaunchGUI.png, imgs/TFLaunchGUI.png
FileInstall, imgs/matrixdim.png, imgs/matrixdim.png
FileInstall, imgs/matrix.ico, imgs/matrix.ico

#SingleInstance off
DetectHiddenWindows On
SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2
;Script by Sora Hjort

version := 20220714.125500

nil := ""

Launch = %1%
IcoImg := FileExist("imgs/matrix.ico")
If (IcoImg == "A")
    {
    menu, tray, icon, imgs/matrix.ico
    }
menu, tray, nostandard
menu, tray, add, E&xit,FIN
Menu, tray, Tip, ReEnergized Steam Launcher - By Sora Hjort


;	Restart script in admin mode if needed.

	full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
    {
        try
        {
            if A_IsCompiled
                Run *RunAs "%A_ScriptFullPath%" %1% /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %1%
        }
        ExitApp
    } Else {	
		SetTitleMatchMode 2
		WinGet, Instances, List, ReEnergized Steam Launcher - By Sora Hjort
		Loop %Instances%
		{
			If ( Instances%A_Index% != A_ScriptHwnd )
                InstantBlock =
                (
                Previous instance of the launcher detected
                
                Would you like to close the previous instance?
                )
                MsgBox, 4,Old Instance Detected, %InstantBlock%
                IfMsgBox Yes
                    {
                    WinClose, % "ahk_id " Instances%A_Index% 
                    } Else {
                    WinActivate, % "ahk_id " Instances%A_Index% 
                    ExitApp
                    }
		}
	
	}




;Version Check

FileReadLine, VerFile, ./version, 1

If (VerFile < version)
    {
    FileDelete, ./version
    FileAppend, %version%, ./version 
    }
    
;Read the ini and fix any erroneous values.
ini = %A_ScriptDir%\TFLaunch.ini

REWFC := FileExist("configs/WFC.ReEnergized.ini")
REFOC := FileExist("configs/FOC.ReEnergized.ini")
WFCBak := FileExist("configs/WFC.Backup.ini")
FOCBak := FileExist("configs/FOC.Backup.ini")
First := FileExist("TFLaunch.ini")
MainImg := FileExist("imgs/TFLaunchGUI.png")
DimImg := FileExist("imgs/matrixdim.png")
IcoImg := FileExist("imgs/matrix.ico")
FOCFirst := True
WFCFirst := True


gosub IniReader
gosub ValueFixer

IfNotExist, ./imgs
    {
    FileCreateDir, ./imgs
    }

If (MainImg != "A")
    {
    gosub DownMain
    }
If (DimImg != "A")
    {
    gosub DownDim
    }
If (IcoImg != "A")
    {
    gosub DownIco
    }

If (IcoImg == "A")
    {
    menu, tray, icon, imgs/matrix.ico
    }
    
    
FileCreateShortcut, %A_ScriptFullPath%, LaunchFOC.lnk,, FOC
FileCreateShortcut, %A_ScriptFullPath%, LaunchWFC.lnk,, WFC


;Check for updates function

FormatTime, time, A_now, yyyyMMdd

if (LastCheck < time)
    {
    If CheckForUpdates = True
        {
        UrlDownloadToFile, https://raw.githubusercontent.com/SoraHjort/AHK_TF_ReEnergized_Launcher/main/version, ./updateCheck
        FileReadLine, updateCheck, ./updateCheck, 1
        FileDelete, ./updateCheck
        If (version < updateCheck)
            {
            UpdateMsg =
(
There is an update available! 
Current:   v%version%  
Updated: v%updateCheck%
Check the github for the update!
)
            MsgBox %UpdateMsg%
            }
        }
    }


;First Launch text box

FirstBlock =
(
This appears to be the first time you've ran this! Or the ini got deleted.

This tool helps you launch the Steam versions of War For Cybertron and Fall Of Cybertron, for playing on the ReEnergized server! This is because the Steam version likes to overwrite the CD Key whenever you launch it. This launcher helps solve this issue by launching the game and then running the registry file automatically!

Click the Help button on the main window for more info! But the quick rundown is:

1. Make sure the .reg files are in the regs folder next to the launcher. Original names given to you by the bot. Launcher will assist you if it can't find it, with some passive agressiveness.

2. Borderless mode requires the games to be in windowed mode, not fullscreen mode. Mode1 is more likely to work, though has tearing in 2d Sprites (UI and cursor). Mode2 has a spotty record for many.

3. WFC and FOC have different load times, adjust the delay for borderless accordingly

4. Shortcuts have been created next to the launcher for quickly launching into the games. This'll also use the borderless options configured in the launcher!

5. During the initial launching of either game, it will launch the game and then kill it. And then relaunch it. This is for it to know where the game is for fixing up the Coalsced.ini.

~Sora Hjort
)


;Help button text

HelpBlock =
(
This launcher will download the Coalesced.ini for you automatically.

The Launcher will help/yell at you on where to put the .reg files when you go to launch a game.

The Borderless mode does require you to run the game in windowed mode.

Borderless Mode1 is generally more reliable. It does result in 2D Sprites, such as UI elements and the Cursor to have some tearing. 3D rendering seems unaffected.

Borderless Mode2 has been known to work less often for a variety of people. But the tearing on the 2D elements do not occur.

WFC and FOC have differing load times, adjust the delay (in seconds) to fine tune when the borderless event triggers. When in doubt, increase the delay up to 20 or even 30 seconds to make sure it triggers.

You can also trigger the borderless while the game is running by attempting to run the shortcuts or pressing the related launch button. It will not launch a second instance of the game.

If you wish to launch the games through this launcher through Steam, you will have to add the launcher as a non-steam game. And if you wish for it to launch straight into a specific game, add "WFC" or "FOC" without quotes as the launch option to have it launch directly into that specific game.

When in doubt, look at the properties of the created shortcuts.

Coalsced.ini switching. The launcher will read the list of Coalsced.ini in the configs folder and populate the two dropdown lists. All WFC ini have the prefix of "WFC.". And "FOC." for FOC. They can be any name as long as they have those prefix and ".ini" at the end.

On launch it will copy the file over to the game's config folder. This is useful if you want to switch between cosemetic mods.

When in doubt use the ReEnergized inis.

Note: If you're running the AHK script version of the launcher instead of the EXE, you will have steam add an exe first. Then you'll have to edit the properties of the entry to direct to the script.
)

;Create the Gui!

WFCBlock = 
(
&War For
Cybertron
)

FOCBlock = 
(
&Fall Of
Cybertron
)


WFCReg := "tfcwfc_pc.reg"
FOCReg := "tfcfoc_pc.reg"

Gui, Main:New, ,ReEnergized Steam Launcher - By Sora Hjort
Gui, Margin ,0,0
Gui, add, picture, xm0 ym0 w960 h540 BackgroundTrans, imgs/TFLaunchGUI.png

gui, color, 0x000000
Gui, Font, s16 c39ff14, Arial

Gui, Add, Button, xm+10 ym+500 w140 h30 gHelp , &Help

Gui, Add, Text, xm345 ym470 , Delay:
Gui, Add, Text, xm345 ym500 , (In Seconds)


Gui, Add, Button, xm+170 ym+460 w150 h70 gWFC , %WFCBlock%

Gui, Add, Edit,  w70 xm410 ym467 h30 +Center
Gui, Add, UpDown, vWFCDelay range0-100 wrap, %WFCDelay%


Gui, Add, Text, xm665 ym470 , Delay:
Gui, Add, Text, xm665 ym500 , (In Seconds)

Gui, Add, Button, xm+490 ym+460 w150 h70 gFOC , %FOCBlock%

Gui, Add, Edit,  w70 xm730 ym467 h30 +Center
Gui, Add, UpDown, vFOCDelay range0-100 wrap, %FOCDelay%

Gui, Add, Button, xm+810 ym+460 w140 h70 gCancel , &Close



;gui, Add, CheckBox, vBEnable %BCloseChecked% xm0 ym400 , Enable Borderless Fullscreen? (Experimental)


GuiControl, Focus, Help


If (First != "A")
    {
    gosub FirstRun
    gosub FinishGui
    Gui, First:new,,First ReEnergized
    gui, color, 0x000000
    Gui, add, picture, +Center xm224 ym32 w512 BackgroundTrans,  imgs/matrixdim.png
    Gui, Font, s16 c39ff14, Arial
    Gui, Add, Text, xm0 ym0 w960 wrap BackgroundTrans, %FirstBlock%
    Gui, First:Show, xcenter ycenter 
    } else {
    gosub FinishGui
    }
Return


FinishGui:
    Gui, Main:Font, s12
    
    gui, Main:add, DropDownList, vWFCConfig xm750 ym10 w200 Choose%WFCCFGSel%, %WFCList%
    
    gui, Main:add, DropDownList, vFOCConfig xm750 ym50 w200 Choose%FOCCFGSel%, %FOCList%
    
    gui, Main:Add, DropDownList, vBorderless Choose%BModeNum% xm750 ym90 w200 , Borderless Disabled|Borderless Mode1|Borderless Mode2
    
    gui, Main:Add, CheckBox, xm750 ym130 vAutoCloseTester %ACloseChecked% , Auto-Close Launcher?
    
    gui, Main:Add, CheckBox, xm750 ym150 vUpdateEnable %UpdateChecker%, Check updates daily?
    
    ;Launch Parameters
    
if (Launch == "FOC" or Launch == "foc")
    {    
    gosub FOC
    gosub FIN
    return
    }

if (Launch == "WFC" or Launch == "wfc")
    {
    gosub WFC
    gosub FIN
    return
    }
    
    Gui, Main:Show, xcenter ycenter h130 AutoSize, ReEnergized Steam Launcher - By Sora Hjort
return



Help:
Gui, Help:New,,Launcher Help
Gui, Margin ,20,20
Gui, add, picture, +Center xm64 ym64 w512 BackgroundTrans,  imgs/matrixdim.png
gui, color, 0x000000
Gui, Font, s16 c39ff14, Arial
Gui, Add, Text, W640 xm0 ym0 wrap BackgroundTrans, %HelpBlock%
Gui, Add, Button, gHelpGuiClose, &Close
Gui, Help:Show
return

;WFC's block

WFC:
gosub Read
SecMult := WFCDelay * 1000
game := "ahk_exe TWFC.exe"
class := "ahk_class LaunchUnrealUWindowsClient"
Stub := "WFC"
StubLong := "War For Cybertron"
WFCSub:
WFCCfgPath = %WFCPath%%CfgPath%
CheckPath := WFCCfgPath
gosub CheckSum
WFCRegPath = regs/%WFCReg%
if !FileExist(WFCRegPath)
    {
    gosub MissingReg
    return
    }
If (WFCFirst = True)
    {
    gosub FirstLaunch
    }
if FileExist(WFCRegPath)
    {
    if (OverwriteCfg = true)
        {
        if (WFCBak != "A")
            {
            gosub BackupConfigs
            }
        gosub DownCheck
        FileCopy, %A_ScriptDir%\configs\%WFCConfig%, %WFCCfgPath%\Coalesced.ini, 1
        }
    runwait steam://run/42650
    WinWait %game%
    RunWait reg import %WFCRegPath%
    WinActivate %game%
    #If WinActive(%game%)
        {
        If (WFCFirst != True)
            {
            Gui, Launch:Destroy
            if (Borderless == "Mode1" or Borderless == "Mode2")
                {
                sleep, %SecMult%
                gosub Borderless%Borderless%
                }
            }
        }
    gosub Save
    gosub FirstRestart
    msgbox If you see this message, please inform Sora. Code: WFC.FR
    return
    }
return
gosub EOF


;FOC's Block

FOC:
gosub Read
SecMult := FOCDelay * 1000
game := "ahk_exe TFOC.exe"
class := "ahk_class LaunchUnrealUWindowsClient"
Stub := "FOC"
StubLong := "Fall Of Cybertron"
FOCSub:
FOCCfgPath = %FOCPath%%CfgPath%
CheckPath := FOCCfgPath
gosub CheckSum
FOCRegPath = regs/%FOCReg%
if !FileExist(FOCRegPath)
    {
    gosub MissingReg
    return
    }
If (FOCFirst = True)
    {
    gosub FirstLaunch
    }
if FileExist(FOCRegPath)
    {
    if (OverwriteCfg = true)
        {
        if (FOCBak != "A")
            {
            gosub BackupConfigs
            }
        gosub DownCheck
        FileCopy, %A_ScriptDir%\configs\%FOCConfig%, %FOCCfgPath%\Coalesced.ini, 1
        }
    runwait steam://run/213120
    WinWait %game%
    Runwait reg import %FOCRegPath%
    WinActivate %game%
    #If WinActive(%game%) && (%class%)
        {
        If (FOCFirst != True)
            {
            Gui, Launch:Destroy
            if (Borderless == "Mode1" or Borderless == "Mode2")
                {
                sleep, %SecMult%
                gosub Borderless%Borderless%
                }
            }
        }
    gosub Save
    gosub FirstRestart
    msgbox If you see this message, please inform Sora. Code: FOC.FR
    return
    }
return
gosub EOF

CheckSum:

if (Stub = "FOC" and FOCFirst != True)
    {
    runwait %ComSpec% /c certUtil -hashfile "%A_ScriptDir%\configs\%FOCConfig%" SHA256 > "%A_ScriptDir%\configs\FOCSel.SHA256",,hide
    runwait %ComSpec% /c certUtil -hashfile "%FOCCfgPath%\Coalesced.ini" SHA256 > "%A_ScriptDir%\configs\FOCCur.SHA256",,hide
    FileReadLine, FOCSel, %A_ScriptDir%\configs\FOCSel.SHA256,2
    FileReadLine, FOCCur, %A_ScriptDir%\configs\FOCCur.SHA256,2
    if (FOCSel != FOCCur)
        {
        OverwriteCfg := true
        }
    } else {
    OverwriteCfg := true
    }

if (Stub = "WFC" and WFCFirst != True)
    {
    runwait %ComSpec% /c certUtil -hashfile "%A_ScriptDir%\configs\%WFCConfig%" SHA256 > "%A_ScriptDir%\configs\WFCSel.SHA256",,hide
    runwait %ComSpec% /c certUtil -hashfile "%WFCCfgPath%\Coalesced.ini" SHA256 > "%A_ScriptDir%\configs\WFCCur.SHA256",,hide
    FileReadLine, WFCSel, %A_ScriptDir%\configs\WFCSel.SHA256,2
    FileReadLine, WFCCur, %A_ScriptDir%\configs\WFCCur.SHA256,2
    if (WFCSel != WFCCur)
        {
        OverwriteCfg := true
        }
    } else {
    OverwriteCfg := true
    }
    
return


Borderless0:


    ;WinMove, %game%, , 0, 0, A_ScreenWidth, A_ScreenHeight
    ;WinSet, Style, 0x140A0000, %game%
    ;WinSet, Style, -0xC00000, %game%
    ;WinSet, Style, -0x800000, %game%
    ;WinSet, Style, -0x40000, %game%
    ;WinSet, Style, -0x400000, %game%
    ;WinSet, Style, -0x0, %game%
    ;WinSet, Style, -0x80880000, %game%
    ;WinSet, Redraw, , %game%
    ;WinHide, %game%
    ;WinShow, %game%
    ;WinMove, %game%, , 0, 0, A_ScreenWidth, A_ScreenHeight
    ;WinSet, Redraw,, %game%
    ;DllCall("SetMenu", "Ptr", WinExist(), "Ptr", 0)

return


BorderlessMode1:

    WinMove, %class%, , 0, 0, A_ScreenWidth, A_ScreenHeight
    WinSet, Style, 0x140A0000, %class%
    WinSet, Style, -0xC00000, %class%
    WinSet, Style, -0x800000, %class%
    WinSet, Style, -0x40000, %class%
    WinSet, Style, -0x400000, %class%
    WinSet, Style, -0x0, %class%
    WinSet, Style, -0x80880000, %class%
    WinSet, Redraw,, %class%
    WinActivate %class%

return



BorderlessMode2:
    WinSet, Style, -0xC00000, %class%
    WinMove, %class%, , 0, 0, A_ScreenWidth, A_ScreenHeight
    DllCall("SetMenu", "Ptr", WinExist(), "Ptr", 0)
    WinActivate %class%

return


;Closing out

Cancel:
gosub Read
gosub Save
gosub FIN
return


;Read the Ini Files

IniReader:
IniRead, WFCPath, %ini%, Launch, WFCPath,
IniRead, FOCPath, %ini%, Launch, FOCPath,

IniRead, WFCConfig, %ini%, launch, WFCConfig, WFC.ReEnergized.ini
IniRead, FOCConfig, %ini%, launch, FOCConfig, FOC.ReEnergized.ini

IniRead, WFCDelay, %ini%, Launch, WFCDelay, 15
IniRead, FOCDelay, %ini%, Launch, FOCDelay, 10

IniRead, LastCheck, %ini%, Update, LastCheck, 0
    
IniRead, CheckForUpdates, %ini%, Update, CheckForUpdates, False
IniRead, AutoClose, %ini%, Launch, AutoClose, True

    
IniRead, Borderless, %ini%, Launch, Borderless, Disabled


TestCheck = 
(
CheckForUpdates: %CheckForUpdates%
AutoClose: %AutoClose%
Borderless: %Borderless%
____
FOCPath: %FOCPath%
FOCConfig: %FOCConfig%
____
WFCPath: %WFCPath%
WFCConfig: %WFCConfig%

)

;msgbox %TestCheck%
return


;Fixing all the values

ValueFixer:

;Invalid Value Error Preventions 
if StrLen(WFCPath) >= 53
    {
    WFCPathBak := WFCPath
    }

if StrLen(FOCPath) >= 53
    {
    FOCPathBak := FOCPath
    }

if WFCDelay is not number
    {
    WFCDelay := 15
    }
if FOCDelay is not number
    {
    FOCDelay := 10
    }

if LastCheck is not number
    {
    LastCheck := 0
    }
    
if (AutoClose != True or AutoClose != False)
    {
    AutoClose := "True"
    }


;Auto Close?



If AutoClose = True
    {
    AutoClose = True
    ACloseChecked := "Checked"
} else {
    AutoClose = False
    ACloseChecked =
    }


;Borderless Mode enabled?

If (Borderless == "Disabled")
    {
    BModeNum := 1
    } else if (Borderless = 0 or Borderless = nil) {
    BModeNum := 1
    } else if (Borderless == "Mode1") {
    BModeNum := 2
    } else if (Borderless == "Mode2") {
    BModeNum := 3
    } else {
    BModeNum := 1
    }

;Check for updates?

If CheckForUpdates = True
    {
    CheckForUpdates = True
    UpdateChecker := "Checked"
} else {
    CheckForUpdates = False
    UpdateChecker =
    }

;FOC and WFC need differing delays before engaging borderless due to load times.


If FOCDelay = nil
    {
    FOCDelay = 10
    }


If WFCDelay = nil
    {
    WFCDelay = 15
    }
    
;Check WFC and FOC paths in ini

CfgPath := "TransGame\Config\PC\Cooked"

if (WFCPath = 0 or WFCPath = nil or WFCPath == "ERROR")
    {
    WFCList := "Launch WFC once first"
    WFCCFGSel := 1
    WFCFirst := True
    } else {
    Tag := "WFC"
    WFCFirst := False
    gosub ConfigRead
    }

if (FOCPath = 0 or FOCPath = nil or FOCPath == "ERROR")
    {
    FOCList := "Launch FOC once first"
    FOCCFGSel := 1
    FOCFirst := True
    } else {
    Tag := "FOC"
    FOCFirst := False
    gosub ConfigRead
    }
WFCCfgPath = %WFCPath%%CfgPath%
FOCCfgPath = %FOCPath%%CfgPath%



return

;Read controls

Read:

Gui, Main:Submit, NoHide

    If (AutoCloseTester = 0)
        {
        AutoClose := False
        } else {
        AutoClose := True
        }


    If (UpdateEnable = 0)
        {
        CheckForUpdates = False
        } else {
        CheckForUpdates = True
        }
BCut := "Borderless "
StringReplace, Borderless, Borderless, %BCut%,,

return


;Save to ini

Save:

Gui, Main:Submit, NoHide

if (WFCConfig = "Launch WFC once first")
    {
    WFCConfig := "WFC.ReEnergized.ini"
    }
if (FOCConfig = "Launch FOC once first")
    {
    FOCConfig := "FOC.ReEnergized.ini"
    }

if (Stub = "FOC" or Stub = "WFC")
    {
    WinGet, GamePath, ProcessPath, %game%

    GamePath := StrReplace(GamePath, "Binaries\TFOC.exe")
    GamePath := StrReplace(GamePath, "Binaries\TWFC.exe")

    IniWrite, %GamePath%, %ini%, Launch, %Stub%Path
    }
    
if (WFCPath < 53 and WFCPathBak >= 53)
    {
    WFCPath := WFCPathBak
    } else if (WFCPath < 53 and WFCPathBak < 53) {
    WFCFirst := True
    }
if (FOCPath < 53 and FOCPathBak >= 53)
    {
    FOCPath := FOCPathBak
    } else if (FOCPath < 53 and FOCPathBak < 53) {
    FOCFirst := True
    }
    
StringReplace, Borderless, Borderless, %BCut%,,
    
IniWrite, %Borderless%, %ini%, Launch, Borderless
IniWrite, %WFCDelay%, %ini%, Launch, WFCDelay
IniWrite, %FOCDelay%, %ini%, Launch, FOCDelay
IniWrite, %AutoClose%, %ini%, Launch, AutoClose
IniWrite, %WFCConfig%, %ini%, Launch, WFCConfig
IniWrite, %FOCConfig%, %ini%, Launch, FOCConfig
IniWrite, %time%, %ini%, Update, LastCheck
IniWrite, %CheckForUpdates%, %ini%, Update, CheckForUpdates

if (Stub = "FOC")
    {
    if (FOCFirst = True)
        {
        Tag := "FOC"
        WinGet, PID, PID, %game%
        Process, Close, %PID%
        gosub ConfigRead
        gosub IniReader
        FOCFirst := False
        FOCConfig := FOCCfgDef
        FOCCFGNum := 2
        RestartQ := True
        RestartMe := True
        goto FOCSub
        return
        }
    }
    
if (Stub = "WFC")
    {
    if (WFCFirst = True)
        {
        Tag := "WFC"
        WinGet, PID, PID, %game%
        Process, Close, %PID%
        gosub ConfigRead
        gosub IniReader
        WFCFirst := False
        WFCConfig := WFCCfgDef
        WFCCFGNum := 2
        RestartQ := True
        RestartMe := True
        goto WFCSub
        return
        }
    }
    WinWait %class%
    WinActivate, %game%
if (AutoCloseTester = 1)
        {
        gui, Main:Hide
        sleep, 1000
        gosub FIN
        }
if (AutoCloseTester = 0 and RestartQ = True)
    {
    goto FirstRestart
    }
return

FirstGuiClose:
FirstGuiEscape:
gui, First:hide
return

HelpGuiClose:
HelpGuiEscape:
gui, Help:hide
return

FirstLaunch:

FirstBlock =
(
Please hold why we launch %StubLong%,
kill the game, then relaunch it for you.

This should only occur during the first launch of
%StubLong%. If this occurs after that, 
it just means the launcher's config ran into a
slight error during a previous launch. It should
hopefully fix itself in time for the next launch.

Anyway!

Don't worry, your old Coalesced.ini files for
%StubLong% are being backed up. They'll
show up in the Config Selection dropdown boxes
labeled as "%Stub%.Backup.ini".

If you did any custom changes to the config file
prior, you may want to go into the configs folder
and rename it. Remember to keep the %Stub% prefix
and the .ini extension.
)

Gui, Launch:new
Gui, -caption
gui, font,s16
Gui, add, text,, %FirstBlock%
gui, Launch:show
return

;Download sub sections

DownMain:
UrlDownloadToFile, https://github.com/SoraHjort/AHK_TF_ReEnergized_Launcher/raw/main/imgs/TFLaunchGUI.png, ./imgs/TFLaunchGui.png
return

DownDim:
UrlDownloadToFile, https://raw.githubusercontent.com/SoraHjort/AHK_TF_ReEnergized_Launcher/main/imgs/matrixdim.png, ./imgs/matrixdim.png
return

DownIco:
UrlDownloadToFile, https://raw.githubusercontent.com/SoraHjort/AHK_TF_ReEnergized_Launcher/main/imgs/matrix.ico, ./imgs/matrix.ico
menu, tray, icon, imgs/matrix.ico
return

;download the ReEnergized basic configs 

DownCheck:
DownYes := False

If (REWFC != "A")
    {
    WFCDown := true
    DownYes := true
    }
    
If (REFOC != "A")
    {
    FOCDown := true
    DownYes := true
    }
    
If (DownYes = true)
    {
    gosub DownConfigs
    }

REWFC := FileExist("configs/WFC.ReEnergized.ini")
REFOC := FileExist("configs/FOC.ReEnergized.ini")

return


DownConfigs:
DownBlock =
(
Now downloading config files. Please hold.

This message will disappear when the
downloads are completed.
)
Gui, Down:New
Gui, Down:Font, s16
Gui, Down:add, text,, %DownBlock%
Gui, Down:show

if (WFCDown = true)
    {
    UrlDownloadToFile, https://wiki.aiwarehouse.xyz/guides/tfcwfc_pc_guide/coalesced.ini, ./configs/WFC.ReEnergized.ini
    }
    
If (FOCDown = true)
    {
    UrlDownloadToFile, https://wiki.aiwarehouse.xyz/guides/tfcfoc_guide/coalesced.ini, ./configs/FOC.ReEnergized.ini
    }
    
Gui, Down:Destroy
return

;Make a backup of the configs incase of overwriting concerns

BackupConfigs:

gosub IniReader

WFCCfgPath = %WFCPath%%CfgPath%
FOCCfgPath = %FOCPath%%CfgPath%
sleep 50

FOCBackup:
if (FOCFirst != True and FOCBak != "A")
    {
    FileCopy, %FOCCfgPath%\Coalesced.ini, %A_ScriptDir%\configs\FOC.Backup.ini
    FOCBak := FileExist("configs/FOC.Backup.ini")
    sleep 50
    goto FOCBackup
    }

WFCBackup:
if (WFCFirst != True and WFCBak != "A")
    {
    FileCopy, %WFCCfgPath%\Coalesced.ini, %A_ScriptDir%\configs\WFC.Backup.ini
    WFCBak := FileExist("configs/WFC.Backup.ini")
    sleep 50
    goto WFCBackup
    }

return


;List the configs in the configs folder

ConfigRead:
FOCArray := []
WFCArray := []

WFCCfgDef := "WFC.ReEnergized.ini"
FOCCfgDef := "FOC.ReEnergized.ini"

IfNotExist, ./configs
        {
        FileCreateDir, ./configs
        }

gosub DownCheck

CountWithMe := 0
FOCCWM := CountWithMe
WFCCWM := CountWithMe

    Loop, ./configs/%Tag%*.ini
        {
        If (Tag = "FOC")
            {
            If (CountWithMe > 0)
                {
                FOCList = %FOCList%|%A_LoopFileName%
                AddCfg = %A_LoopFileName%
                FOCArray.push(AddCfg)
                } else {
                FOCList = %FOCList%%A_LoopFileName%
                AddCfg = %A_LoopFileName%
                FOCArray.push(AddCfg)
                }
            FOCCWM++
            }
        if (Tag = "WFC")
            {
            If (CountWithMe > 0)
                {
                WFCList = %WFCList%|%A_LoopFileName%
                AddCfg = %A_LoopFileName%
                WFCArray.push(AddCfg)
                } else {
                WFCList = %WFCList%%A_LoopFileName%
                AddCfg = %A_LoopFileName%
                WFCArray.push(AddCfg)
                }
            WFCCWM++
            }
        CountWithMe++
        }

If (Tag = "WFC")
    {
    WFCList = %WFCList%|<--------------------->
    WFCArray.push("<--------------------->")
    
    WFCList = %WFCList%|!/:WFC.Overwrite.Off:\!
    WFCArray.push("!/:WFC.Overwrite.Off:\!")
    loop % WFCArray.length()
        {
        WFCTest = % WFCArray[A_Index]
        WFCCFGNum++
        if (WFCTest = WFCConfig)
            {
            WFCCFGSel := WFCCFGNum
            }
        if (WFCTest = WFCCfgDef)
            {
            WFCCFGDefSel := WFCCFGNum
            }
        }
    }

If (Tag = "FOC")
    {
    FOCList = %FOCList%|<--------------------->
    FOCArray.push("<--------------------->")
    
    FOCList = %FOCList%|!/:FOC.Overwrite.Off:\!
    FOCArray.push("!/:FOC.Overwrite.Off:\!")
    loop % FOCArray.length()
        {
        FOCTest = % FOCArray[A_Index]
        FOCCFGNum++
        if (FOCTest = FOCConfig)
            {
            FOCCFGSel := FOCCFGNum
            }
        if (FOCTest = FOCCfgDef)
            {
            FOCCFGDefSel := FOCCFGNum
            }
        }
    }

If (FOCCFGSel = "")
    {
    FOCCFGSel := FOCCFGDefSel
    }
    
If (WFCCFGSel = "")
    {
    WFCCFGSel := WFCCFGDefSel
    }
    
iniLoop := True
if (WFCFirst != True and WFCBak != "A")
    {
    gosub BackupConfigs
    goto ConfigRead
    return
    }
    
if (FOCFirst != True and FOCBak != "A")
    {
    gosub BackupConfigs
    goto ConfigRead
    return
    }    

return


;First Run Section
FirstRun:
FileCreateDir, ./configs
FileCreateDir, ./regs
DownYes := True
gosub DownConfigs
return



;Exit
LaunchGuiClose:
LaunchGuiEscape:
MainGuiClose:
MainGuiEscape:
FIN:
ExitApp
return

FirstRestart:
RestartBlock =
(
Due to you turning off the auto close launcher before
the first time setup of launching %StubLong%,
the launcher will now restart. This does mean it will
bring itself infront of the game. 

This should only occur this one time from launching
%StubLong%. 
)
    ;MsgBox, %RestartBlock%
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %1%
    }
    ExitApp


MissingReg:
FileCreateDir, ./regs
run, explorer .\regs
WinWaitActive, ahk_exe explorer.exe
WinMove,,, 0, 0, 600, 600
MissingRegBlock =
(
%Stub% CDKey Registry File not found in launcher's directory,
be sure to follow the instructions!

You didn't rename it, did you?

Anyway, I've opened the file explorer to where you should put
it, so throw the reg file into it.
)

MsgBox %MissingRegBlock%
return


;Should never reach here
EOF:
return