#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
;Script by Sora Hjort


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

Gui, Font, s20
Gui, Add, Text, , %TxtBlock%

Gui, Add, Button, gWFC, &1. War For Cybertron
Gui, Add, Button, gFOC, &2. Fall Of Cybertron
Gui, Add, Button, gCancel, &3. Cancel
Gui, Show, xcenter ycenter h130 AutoSize, ReEnergized Steam Launcher
Return


WFC:
if FileExist("tfcwfc_pc.reg") {
    run steam://run/42650
    gui, Hide
    WinWait ahk_exe TWFC.exe
    RunWait reg import tfcwfc_pc.reg
    gosub FIN
    return
    }
else
    {
    MsgBox WFC CDKey Registry not found in launcher's directory, be sure to follow the instructions! You didn't rename it, did you?
    return
    }
return

FOC:
if !FileExist("tfcfoc_pc.reg") {
    MsgBox FOC CDKey Registry not found in launcher's directory, be sure to follow the instructions! You didn't rename it, did you?
    return
    } 
else
    {
    run steam://run/213120
    gui, Hide
    WinWait ahk_exe TFOC.exe
    RunWait reg import tfcfoc_pc.reg
    gosub FIN
    return
    }
return

Cancel:
goto FIN
return


FIN:
ExitApp