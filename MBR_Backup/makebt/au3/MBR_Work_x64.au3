#RequireAdmin
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5 + file SciTEUser.properties in your UserProfile e.g. C:\Users\User-10

 Author:        WIMB  -  Feb 16, 2020

 Program:       MBR_Work_x64.exe - Version 1.0

 Script Function: Make Backup of all Bootsectors of all Local Harddisks Fixed + Removable
	Backup Contains BootSector Files for:
	- Guid Partition Table - GPT - First 34 Sectors of GPT Harddisk
	- Master Boot Record - MBR - Sector 0 of Harddisk containing Partition Table
	- Extended Partition Boot Record - EPBR - Beginning of Extended Partition
	- Extended Boot Records - EBR - Beginning of Logical Partitions within Extended
	- Partition BootSectors - 16 Sectors for NTFS or FAT32 and 1 Sector for FAT32 or FAT

 Credits and Thanks to:

	- TeraByte for making PartInfo - https://www.terabyteunlimited.com/downloads-free-software.htm
	- SysInt for making MBRFix - https://www.sysint.no/mbrfix/?lang=en

	The program is released "as is" and is free for redistribution, use or changes as long as original author,
	credits part and link to the reboot.pro support forum are clearly mentioned
	Tiny Hexer - MBR_Backup - http://reboot.pro/files/file/595-tiny-hexer-mbr-backup/ and http://reboot.pro/topic/21999-tiny-hexer-mbr-backup/

	Author does not take any responsibility for use or misuse of the program.

#ce ----------------------------------------------------------------------------

#include <guiconstants.au3>
; ------------------------------------------------------------------------------

Opt('MustDeclareVars', 1)
Opt("TrayIconHide", 1)

Global $str = "", $bt_files[4] = ["\MBR_Backup\MBR_Backup_x64.exe", "\MBR_Backup\partinfg.exe", "\BOOTICE\BOOTICEx64.exe", "\tinyhexer\mpth_small.exe"]

;~ 	If @OSArch <> "X86" Then
;~ 	   MsgBox(48, "ERROR - Environment", "In x64 environment use MBR_Work_x64.exe ")
;~ 	   Exit
;~ 	EndIf

For $str In $bt_files
	If Not FileExists(@ScriptDir & $str) Then
		MsgBox(48, "ERROR - Missing File", "File " & $str & " NOT Found ")
		Exit
	EndIf
Next

Global $GUI_Start, $button1, $button2, $button9, $button10, $nMsg

$GUI_Start = GUICreate("MBR Work - x64 Version 1.0 - Admin Launcher", 390, 130, 200, 100, BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX))
$button1 = GUICtrlCreateButton(" BOOTICE ", 30, 25, 150)
GUICtrlSetFont(-1, 10, "", "", "Tahoma")
$button2 = GUICtrlCreateButton(" Tiny Hexer ", 30, 65, 150)
GUICtrlSetFont(-1, 10, "", "", "Tahoma")
$button9 = GUICtrlCreateButton(" Partition Info ", 210, 25, 150)
GUICtrlSetFont(-1, 10, "", "", "Tahoma")
$button10 = GUICtrlCreateButton(" MBR Backup ", 210, 65, 150)
GUICtrlSetFont(-1, 10, "", "", "Tahoma")

DisableMenus(0)

GUISetState(@SW_SHOW)
GUICtrlSetState($button10, $GUI_FOCUS)

While 1
    $nMsg = GUIGetMsg()
	If $nMsg = $GUI_EVENT_CLOSE Then Exit
	If $nMsg > 0 Then
		DisableMenus(1)
		Switch $nMsg
			Case $button1
				ShellExecute(@ScriptDir & "\BOOTICE\BOOTICEx64.exe", @ScriptDir)
				MsgBox(0,"Timeout", "", 0.3)
			Case $button2
				ShellExecute(@ScriptDir & "\tinyhexer\mpth_small.exe", @ScriptDir)
				MsgBox(0,"Timeout", "", 0.3)
			Case $button9
				ShellExecute(@ScriptDir & "\MBR_Backup\partinfg.exe", @ScriptDir)
				MsgBox(0,"Timeout", "", 0.3)
			Case $button10
				ShellExecute(@ScriptDir & "\MBR_Backup\MBR_Backup_x64.exe", @ScriptDir)
				MsgBox(0,"Timeout", "", 0.3)
		EndSwitch
		DisableMenus(0)
	EndIf
WEnd

;===================================================================================================
Func DisableMenus($endis)
	If $endis = 0 Then
		$endis = $GUI_ENABLE
	Else
		$endis = $GUI_DISABLE
	EndIf
	GUICtrlSetState($button1, $endis)
	GUICtrlSetState($button2, $endis)
	GUICtrlSetState($button9, $endis)
	GUICtrlSetState($button10, $endis)

EndFunc ;==>DisableMenus
;===================================================================================================
