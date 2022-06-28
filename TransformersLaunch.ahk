WinClose, % "ahk_id " Instances%A_Index%

;@Ahk2Exe-SetMainIcon matrix.ico
FileInstall, imgs/TFLaunchGUI.png, imgs/TFLaunchGUI.png
FileInstall, imgs/matrixdim.png, imgs/matrixdim.png
FileInstall, imgs/matrix.ico, imgs/matrix.ico

#SingleInstance off
SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2
;Script by Sora Hjort


version := 20220627.214000


Launch = %1%



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
}




;Version Check

FileReadLine, VerFile, ./version, 1

If (VerFile <= version)
    {
    FileDelete, ./version
    FileAppend, %version%, ./version 
    }
    
;Read the ini and fix any erroneous values.
ini = %A_ScriptDir%\TFLaunch.ini

IniRead, LastCheck, %ini%, Update, LastCheck, 0
IniRead, CheckForUpdates, %ini%, Update, CheckForUpdates, False


;Auto Close?

IniRead, AutoClose, %ini%, Launch, AutoClose, True

If AutoClose = True
    {
    AutoClose = True
    ACloseChecked := "Checked"
} else {
    AutoClose = False
    ACloseChecked =
    }


;Borderless Mode enabled?

IniRead, BorderlessEnabled, %ini%, Launch, BorderlessEnabled, True

If BorderlessEnabled = True
    {
    BorderlessEnabled = True
    BCloseChecked := "Checked"
} else {
    BorderlessEnabled = False
    BCloseChecked =
    }


;FOC and WFC need differing delays before engaging borderless due to load times.

IniRead, FOCDelay, %ini%, Launch, FOCDelay, 10
If FOCDelay =
    {
    FOCDelay = 10
    }

IniRead, WFCDelay, %ini%, Launch, WFCDelay, 15
If WFCDelay =
    {
    WFCDelay = 15
    }
    
    

;Launch Parameters
    
if (Launch == "FOC" or Launch == "foc") {
    gosub FOC
    gosub FIN
    return
    }

if (Launch == "WFC" or Launch == "wfc") {
    gosub WFC
    gosub FIN
    return
    }
    
    
First := FileExist("TFLaunch.ini")
MainImg := FileExist("imgs/TFLaunchGUI.png")
DimImg := FileExist("imgs/matrixdim.png")
IcoImg := FileExist("imgs/matrix.ico")

IfNotExist, ./imgs
    {
    FileCreateDir, ./imgs
    }

If (MainImg != "A")
    {
    UrlDownloadToFile, https://github.com/SoraHjort/AHK_TF_ReEnergized_Launcher/raw/main/imgs/TFLaunchGUI.png, ./imgs/TFLaunchGui.png
    }
If (DimImg != "A")
    {
    UrlDownloadToFile, https://raw.githubusercontent.com/SoraHjort/AHK_TF_ReEnergized_Launcher/main/imgs/matrixdim.png, ./imgs/matrixdim.png
    }
If (IcoImg != "A")
    {
    UrlDownloadToFile, https://raw.githubusercontent.com/SoraHjort/AHK_TF_ReEnergized_Launcher/main/imgs/matrix.ico, ./imgs/matrix.ico
    }

If (IcoImg == "A")
    {
    menu, tray, icon, imgs/matrix.ico
    }

menu, tray, nostandard
menu, tray, add, E&xit,FIN
    
    
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
        If (version <= updateCheck)
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

1. Make sure the .reg files are in the same location as the launcher. Original names given to you by the bot.
2. Borderless mode requires the games to be in windowed mode, not fullscreen mode
3. WFC and FOC have different load times, adjust the delay for borderless accordingly
4. Shortcuts have been created next to the launcher for quickly launching into the games. This'll also use the borderless options configured in the launcher!

~Sora Hjort
)


;Help button text

HelpBlock =
(
This launcher still needs you to grab the Coalesced.ini from the Discord Server.

The reg files "tfcwfc_pc.reg" and "tfcfoc_pc.reg" must be in the same folder as the launcher. The launcher will yell at you if you did not do this.

The Borderless mode does require you to run the game in windowed mode.

WFC and FOC have differing load times, adjust the delay (in seconds) to fine tune when the borderless event triggers. When in doubt, increase the delay up to 20 or even 30 seconds to make sure it triggers.

You can also trigger the borderless while the game is running by attempting to run the shortcuts or pressing one of the launch buttons. It will not launch a second instance of the game.

If you wish to launch the games through this launcher through Steam, you will have to add the launcher as a non-steam game. And if you wish for it to launch straight into a specific game, add "WFC" or "FOC" without quotes as the launch option to have it launch directly into that specific game.

When in doubt, look at the properties of the shortcuts.

Note: If you're running the AHK script version of the launcher instead of the EXE, you will have steam add any other program. Then you'll have to edit the properties of the entry to direct to the script.
)


;Launcher main text

TxtBlock =
(
Welcome to the ReEngergized Launcher Helper for Steam!

Make sure you have the .reg files inthe same folder as this program. They need to be the same name as they were given to you by the bot!

If you have not, then please go follow the instructions in the install guide. It's over on the discord server!

P.S. This launcher and the registry files can be stored anywhere, as long as they're in the same folder!

Signed Sora Hjort



Select the game you wish to launch!
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

Gui, New, ,ReEnergized Steam Launcher
Gui, Margin ,0,0
Gui, add, picture, xm0 ym0 w960 h540 BackgroundTrans, imgs/TFLaunchGUI.png

gui, color, 0x000000
Gui, Font, s16 c39ff14, Arial

Gui, Add, Button, xm+10 ym+500 w140 h30 gHelp , &Help

Gui, Add, Text, xm345 ym470 , Delay:
Gui, Add, Text, xm345 ym500 , (In Seconds)


Gui, Add, Button, xm+170 ym+460 w150 h70 gWFC , %WFCBlock%

Gui, Add, Edit,  w70 xm410 ym470 h30 +Center
Gui, Add, UpDown, vWFCDelay range0-100 wrap, %WFCDelay%


Gui, Add, Text, xm665 ym470 , Delay:
Gui, Add, Text, xm665 ym500 , (In Seconds)

Gui, Add, Button, xm+490 ym+460 w150 h70 gFOC , %FOCBlock%

Gui, Add, Edit,  w70 xm730 ym470 h30 +Center
Gui, Add, UpDown, vFOCDelay range0-100 wrap, %FOCDelay%

Gui, Add, Button, xm+810 ym+460 w140 h70 gCancel , &Close


gui, Add, CheckBox, vBEnable %BCloseChecked% xm0 ym400 , Enable Borderless Fullscreen? (Experimental)

gui, Add, CheckBox, xm0 ym430 vAClose %ACloseChecked% , Automatically Close Launcher?

GuiControl, Focus, Help


Gui, Show, xcenter ycenter h130 AutoSize, ReEnergized Steam Launcher
If (First != "A")
    {
    Gui, First:new,,First ReEnergized
    gui, color, 0x000000
    Gui, Font, s16 c39ff14, Arial
    Gui, Add, Text,w960 wrap BackgroundTrans, %FirstBlock%
    Gui, First:Show, xcenter ycenter 
    }
Return



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
if FileExist("tfcwfc_pc.reg") {
    run steam://run/42650
    gosub Save
    WinWait %game%
    RunWait reg import tfcwfc_pc.reg
    WinActivate %game%
    sleep, %SecMult%
    #If WinActive(%game%)
        {
        if (BorderlessEnabled == "True")
            {
            gosub Borderless
            }
        }
    return
    }
else
    {
    MsgBox WFC CDKey Registry not found in launcher's directory, be sure to follow the instructions! You didn't rename it, did you?
    return
    }
return
gosub EOF


;FOC's Block

FOC:
gosub Read
SecMult := FOCDelay * 1000
game := "ahk_exe TFOC.exe"
game2 := "TFOC.exe"
if !FileExist("tfcfoc_pc.reg") {
    MsgBox FOC CDKey Registry not found in launcher's directory, be sure to follow the instructions! You didn't rename it, did you?
    return
    } 
else
    {
    run steam://run/213120
    gosub Save
    WinWait %game%
    Run reg import tfcfoc_pc.reg
    WinActivate %game%
    sleep, %SecMult%
    #If WinActive(%game%)
        {
        if (BorderlessEnabled == "True")
            {
            gosub Borderless
            }
        }
    return
    }
return
gosub EOF

Borderless:
    WinActivate %game%
    WinSet, Style, -0xC00000, %game%
    WinSet, Style, -0xC40000, %game%
    WinMove, %game%, , 0, 0, A_ScreenWidth, A_ScreenHeight
    DllCall("SetMenu", "Ptr", WinExist(), "Ptr", 0)
return


;Closing out

Cancel:
gosub Read
gosub Save
gosub FIN
return


;Read controls

Read:

GuiControlGet, FOCDelay,, FOCDelay
GuiControlGet, WFCDelay,, WFCDelay
GuiControlGet, AutoCloseTester,, AClose
    If (AutoCloseTester == 0)
        {
        AutoClose = False
        } else {
        AutoClose = True
        }

GuiControlGet, BEnableTester,, BEnable
    If (BEnableTester == 0)
        {
        BorderlessEnabled = False
        } else {
        BorderlessEnabled = True
        }

return


;Save to ini

Save:
        

IniWrite, %BorderlessEnabled%, %ini%, Launch, BorderlessEnabled
IniWrite, %WFCDelay%, %ini%, Launch, WFCDelay
IniWrite, %FOCDelay%, %ini%, Launch, FOCDelay
IniWrite, %AutoClose%, %ini%, Launch, AutoClose
IniWrite, %time%, %ini%, Update, LastCheck
IniWrite, %CheckForUpdates%, %ini%, Update, CheckForUpdates
if (AutoCloseTester == 1)
        {
        gui, Hide
        ExitSleep := SecMult + 10000
        sleep, %ExitSleep%
        gosub FIN
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


;Exit
GuiClose:
GuiEscape:
FIN:
ExitApp
return


;Should never reach here
EOF:
return