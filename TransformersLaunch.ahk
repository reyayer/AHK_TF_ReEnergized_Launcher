#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2
;Script by Sora Hjort
;ahk_class LaunchUnrealUWindowsClient


;	Restart script in admin mode if needed.

	full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

ini = %A_ScriptDir%\TFLaunch.ini


TxtBlock =
(
Welcome to the ReEngergized Launcher Helper for Steam!
Make sure you have the .reg files inthe same folder 
as this program. They need to be the same name as
they were given to you by the bot!

If you have not, then please go follow the instructions
in the install guide. It's over on the discord server!

P.S. This launcher and the registry files can be stored
anywhere, as long as they're in the same folder!

Signed Sora Hjort



Select the game you wish to launch!
)

;Read the ini and fix any erroneous values.

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
    
    

;Create the Gui!

Gui, Font, s16
Gui, Add, Text, , %TxtBlock%

Gui, Add, Button, gWFC, &1. War For Cybertron
Gui, Add, Button, gFOC, &2. Fall Of Cybertron
Gui, Add, Button, gCancel, &3. Close
gui, add, text,,

gui, Add, CheckBox, vBEnable %BCloseChecked%, Enable Borderless Fullscreen? (Experimental)
Gui, add, Text,, [WFC] Delay to auto activate Borderless (Seconds):
Gui, Add, Edit
Gui, Add, UpDown, vWFCDelay range0-100, %WFCDelay%
Gui, add, Text,, [FOC] Delay to auto activate Borderless (Seconds):
Gui, Add, Edit
Gui, Add, UpDown, vFOCDelay range0-100, %FOCDelay%

gui, Add, CheckBox, vAClose %ACloseChecked%, Automatically Close Launcher?
Gui, Show, xcenter ycenter h130 AutoSize, ReEnergized Steam Launcher
Return


;WFC's block

WFC:
gosub Read
SecMult := WFCDelay * 1000
game := "ahk_exe TWFC.exe"
if FileExist("tfcwfc_pc.reg") {
    run steam://run/42650
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
    gosub Save
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
    gosub Save
    return
    }
return
gosub EOF

Borderless:
    WinActivate %game%
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
if (AutoCloseTester == 1)
        {
        gui, Hide
        ExitSleep := SecMult + 10000
        sleep, %ExitSleep%
        gosub FIN
        }
return


;Exit
FIN:
ExitApp
return


;Should never reach here
EOF:
return
