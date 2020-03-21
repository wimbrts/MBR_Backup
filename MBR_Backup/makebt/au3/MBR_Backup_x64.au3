#RequireAdmin
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5 + file SciTEUser.properties in your UserProfile e.g. C:\Users\User-10

 Author:        WIMB  -  Feb 16, 2020

 Program:       MBR_Backup_x64.exe - Version 1.0

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
#include <ProgressConstants.au3>
#include <GuiConstantsEx.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#Include <GuiStatusBar.au3>
#include <Array.au3>
#Include <String.au3>
#include <Process.au3>
#include <Date.au3>
#include <Constants.au3>
#include <WinAPIDlg.au3>
#include <MemoryConstants.au3>
#include <MsgBoxConstants.au3>
; ------------------------------------------------------------------------------

Opt('MustDeclareVars', 1)
Opt("TrayIconHide", 1)

Global $hGuiParent, $nMsg, $GO, $ProgressAll, $hStatus, $PART_INFO, $PART_GUI, $Disk_GUI, $Signature_GUI
Global $file_hd, $line_hd, $linesplit_hd[20], $count_hd=0
Global $str = "", $bt_files[2] = ["\makebt\partinfw.exe", "\makebt\MbrFix.exe"]

;~ 	If @OSArch <> "X86" Then
;~ 	   MsgBox(48, "ERROR - Environment", "In x64 environment use MBR_Backup_x64.exe ")
;~ 	   Exit
;~ 	EndIf

For $str In $bt_files
	If Not FileExists(@ScriptDir & $str) Then
		MsgBox(48, "ERROR - Missing File", "File " & $str & " NOT Found ")
		Exit
	EndIf
Next

Global $PE_flag = 0, $ComputerName = @ComputerName, $Backup_Folder = "", $Partinf = "", $LogFile = ""
Global $System_Reg, $OS_DriveLetter = StringLeft(@SystemDir, 1)

If StringLeft(@SystemDir, 1) = "X" Then
	$PE_flag = 1
	$OS_DriveLetter = "C"
Else
	$PE_flag = 0
	$OS_DriveLetter = StringLeft(@SystemDir, 1)
EndIf

If $PE_flag = 1 And FileExists($OS_DriveLetter & ":\Windows\System32\config\system") Then
	$System_Reg = "SYSTEM_" & $OS_DriveLetter

	RunWait(@ComSpec & " /c reg load HKLM\" & $System_Reg & " " & $OS_DriveLetter & ":\Windows\System32\config\system", @ScriptDir, @SW_HIDE)
	$ComputerName = RegRead("HKEY_LOCAL_MACHINE\" & $System_Reg & "\ControlSet001\Control\ComputerName\ComputerName", "ComputerName")
	RunWait(@ComSpec & " /c reg unload HKLM\" & $System_Reg, @ScriptDir, @SW_HIDE)
Else
	$OS_DriveLetter = StringLeft(@SystemDir, 1)
	$ComputerName = @ComputerName
EndIf

$ComputerName = StringReplace($ComputerName, " ", "_")

$Partinf = "MBR_" & $ComputerName & "_" & "partinfw.txt"
$Backup_Folder = "MBR_" & $ComputerName & "_" & @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "-" & @MIN & "-" & @SEC
DirCreate(@ScriptDir & "\" & $Backup_Folder)
$LogFile = $Backup_Folder & "\" & $Backup_Folder & ".log"

RunWait(@ComSpec & " /c makebt\partinfw.exe > " & $Backup_Folder & "\" & $Partinf, @ScriptDir, @SW_HIDE)

$file_hd = FileOpen(@ScriptDir & "\" & $Backup_Folder & "\" & $Partinf, 0)
If $file_hd <> -1 Then
	$count_hd = 0
	While 1
		$line_hd = FileReadLine($file_hd)
		If @error = -1 Then ExitLoop
		$line_hd = StringStripWS($line_hd, 7)
		If $line_hd <> "" Then
			$linesplit_hd = StringSplit($line_hd, " ")
			; _ArrayDisplay($linesplit)
			If $linesplit_hd[0] = 6 And $linesplit_hd[1] = "MBR" Then
				$count_hd = $count_hd + 1
			EndIf
		EndIf
	Wend
	FileClose($file_hd)
	; MsgBox(48, "Harddisk Found", "Number of Harddisks = " & $count_hd)
Else
	MsgBox(48, "STOP - Error", "Unable to Open " & @ScriptDir & "\" & $Backup_Folder & "\" & $Partinf)
	Exit
EndIf

$hGuiParent = GUICreate(" MBR Backup - x64 Version 1.0 ", 335, 185, 200, -1, BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX))

GUICtrlCreateGroup("", 18, 10, 300, 90)

GUICtrlCreateLabel( "Disk Number", 32, 28)
$Disk_GUI = GUICtrlCreateInput("", 110, 25, 95, 20, $ES_READONLY)

GUICtrlCreateLabel( "Disk Signature", 32, 70)
$Signature_GUI = GUICtrlCreateInput("", 110, 67, 95, 20, $ES_READONLY)

$PART_INFO = GUICtrlCreateButton("Part Info", 235, 24, 70, 27)
GUICtrlSetTip($PART_INFO, " Displays Partition Info ")

$PART_GUI = GUICtrlCreateButton("Part Prg", 235, 61, 70, 27)
GUICtrlSetTip($PART_GUI, " Partition Info GUI ")

$GO = GUICtrlCreateButton("GO", 235, 115, 70, 30)
GUICtrlSetTip($GO,  " Use GO to Make MBR Backup of All Disks with " & @CRLF _
& " - GPT Partition Table - 34 Sectors " & @CRLF _
& " - MBR Partition Table -  1 Sector " & @CRLF _
& " - Extended Partition Boot Record - EPBR and EBR " & @CRLF _
& " - Volume BootSectors - NTFS and FAT32 - 16 Sectors ")

$ProgressAll = GUICtrlCreateProgress(16, 123, 203, 16, $PBS_SMOOTH)

$hStatus = _GUICtrlStatusBar_Create($hGuiParent, -1, "", $SBARS_TOOLTIPS)

DisableMenus(1)
GUICtrlSetState($PART_INFO, $GUI_ENABLE)
GUICtrlSetState($PART_GUI, $GUI_ENABLE)
GUICtrlSetData($Disk_GUI, $count_hd)
_GUICtrlStatusBar_SetText($hStatus," Use GO to Make MBR Backup", 0)

GUISetState(@SW_SHOW)
GUICtrlSetState($GO, $GUI_ENABLE + $GUI_FOCUS)

While 1
    $nMsg = GUIGetMsg()
	If $nMsg = $GUI_EVENT_CLOSE Then Exit
	If $nMsg > 0 Then
		DisableMenus(1)
		Switch $nMsg
			Case $GO
				_MBR_Backup()
				GUICtrlSetData($ProgressAll, 100)
				_GUICtrlStatusBar_SetText($hStatus," End of Program - OK", 0)
				MsgBox(64, " END OF PROGRAM - OK ", " End of Program  - OK " & @CRLF _
				& @CRLF & " ")
				Exit
			Case $PART_INFO
				ShellExecute("notepad.exe", @ScriptDir & "\" & $Backup_Folder & "\" & $Partinf, @ScriptDir)
			Case $PART_GUI
				ShellExecute(@ScriptDir & "\partinfg.exe", @ScriptDir)
		EndSwitch
		DisableMenus(0)
	EndIf
WEnd

;===================================================================================================
Func _MBR_Backup()
	Local $file, $line, $linesplit[20], $count=0, $count_mp=0, $Disk_Signature, $HD_Nr, $Disk_Nr = 0, $Sector_Nr, $EPBR_Sector_Nr, $EBR_Sector_Nr
	Local $Disk_Folder = "", $gpt_flag = 0, $fProgressAll

	FileWriteLine(@ScriptDir & "\" & $LogFile, " =============================================================================")
	FileWriteLine(@ScriptDir & "\" & $LogFile, " Partition Info = " & $Backup_Folder & "\" & $Partinf)
	$file = FileOpen(@ScriptDir & "\" & $Backup_Folder & "\" & $Partinf, 0)
	If $file <> -1 Then
		; count correction for 3 empty lines
		$count = 3
		$count_mp = 0
		While 1
			$line = FileReadLine($file)
			If @error = -1 Then ExitLoop
			$line = StringStripWS($line, 7)
			If $line <> "" Then
				$count = $count + 1
				$linesplit = StringSplit($line, " ")
				; _ArrayDisplay($linesplit)
				If $linesplit[0] = 6 And $linesplit[1] = "MBR" Then
					$Disk_Signature = StringLeft($linesplit[6], 10)
					$HD_Nr = StringMid($linesplit[4], 2)
					$Disk_Nr = StringMid($HD_Nr, 3)
					$Disk_Folder = $HD_Nr & "_" & $Disk_Signature
					GUICtrlSetData($Disk_GUI, $HD_Nr)
					GUICtrlSetData($Signature_GUI, $Disk_Signature)
					DirCreate(@ScriptDir & "\" & $Backup_Folder & "\" & $Disk_Folder)
					RunWait(@ComSpec & " /c makebt\MbrFix.exe /drive " & $Disk_Nr & " savembr " & $Backup_Folder & "\" & $Disk_Folder & "\HD" & $Disk_Nr & "_mbr.dat", @ScriptDir, @SW_HIDE)
					$count_mp = $count_mp + 1
					$gpt_flag = 0
					$fProgressAll = Int($count_mp * 100/ $count_hd)
					GUICtrlSetData($ProgressAll, $fProgressAll)
					FileWriteLine(@ScriptDir & "\" & $LogFile, " =============================================================================")
					FileWriteLine(@ScriptDir & "\" & $LogFile, "")
					FileWriteLine(@ScriptDir & "\" & $LogFile, " Backup Folder  = " & $Backup_Folder & "\" & $Disk_Folder)
					FileWriteLine(@ScriptDir & "\" & $LogFile, "")
					FileWriteLine(@ScriptDir & "\" & $LogFile, " Rule Disk   TYPE  Sector  Start         BackupFile")
					FileWriteLine(@ScriptDir & "\" & $LogFile, " " & $count & "  HD " & $Disk_Nr & "   MBR     1     0             HD" & $Disk_Nr & "_mbr.dat")
					MsgBox(0,"Timeout", "", 0.5)
					; MsgBox(48, "Harddisk Found", "Backup made for " & $Disk_Folder, 1)
				EndIf
				If $linesplit[0] = 4 And $linesplit[1] = "GPT" Then
					RunWait(@ComSpec & " /c makebt\MbrFix.exe /drive " & $Disk_Nr & " readdrive 0 34 " & $Backup_Folder & "\" & $Disk_Folder & "\HD" & $Disk_Nr & "_gpt.dat", @ScriptDir, @SW_HIDE)
					$gpt_flag = 1
					; count correction for empty line
					$count = $count + 1
					FileWriteLine(@ScriptDir & "\" & $LogFile, " " & $count & "  HD " & $Disk_Nr & "   GPT    34     0             HD" & $Disk_Nr & "_gpt.dat")
				EndIf
				If $linesplit[0] >= 9 And $linesplit[5] = "LBA:" Then
					$Sector_Nr = $linesplit[6]
					If $Sector_Nr = "63" Or $Sector_Nr = "2048" And $gpt_flag=0 Then
						RunWait(@ComSpec & " /c makebt\MbrFix.exe /drive " & $Disk_Nr & " readdrive 0 63 " & $Backup_Folder & "\" & $Disk_Folder & "\HD" & $Disk_Nr & "_mbr_head.dat", @ScriptDir, @SW_HIDE)
						FileWriteLine(@ScriptDir & "\" & $LogFile, " " & $count & "  HD " & $Disk_Nr & "   HEAD   63     0             HD" & $Disk_Nr & "_mbr_head.dat")
					Endif
					If $linesplit[4] = "0x7" Then
						RunWait(@ComSpec & " /c makebt\MbrFix.exe /drive " & $Disk_Nr & " readdrive " & $Sector_Nr & " 16 " & $Backup_Folder & "\" & $Disk_Folder & "\HD" & $Disk_Nr & "_" & $Sector_Nr & ".dat", @ScriptDir, @SW_HIDE)
						FileWriteLine(@ScriptDir & "\" & $LogFile, " " & $count & "  HD " & $Disk_Nr & "   " & $linesplit[4] & "    16     " & $Sector_Nr & "             HD" & $Disk_Nr & "_" & $Sector_Nr & ".dat")
					Else
						RunWait(@ComSpec & " /c makebt\MbrFix.exe /drive " & $Disk_Nr & " readdrive " & $Sector_Nr & " 1 " & $Backup_Folder & "\" & $Disk_Folder & "\HD" & $Disk_Nr & "_" & $Sector_Nr & ".dat", @ScriptDir, @SW_HIDE)
						FileWriteLine(@ScriptDir & "\" & $LogFile, " " & $count & "  HD " & $Disk_Nr & "   " & $linesplit[4] & "     1     " & $Sector_Nr & "             HD" & $Disk_Nr & "_" & $Sector_Nr & ".dat")
					EndIf
					If $linesplit[4] = "0xB" Or $linesplit[4] = "0xC" Or $linesplit[4] = "0x1B" Or $linesplit[4] = "0x1C" Then
						RunWait(@ComSpec & " /c makebt\MbrFix.exe /drive " & $Disk_Nr & " readdrive " & $Sector_Nr & " 16 " & $Backup_Folder & "\" & $Disk_Folder & "\HD" & $Disk_Nr & "_" & $Sector_Nr & "_FAT32.dat", @ScriptDir, @SW_HIDE)
						FileWriteLine(@ScriptDir & "\" & $LogFile, " " & $count & "  HD " & $Disk_Nr & "   " & $linesplit[4] & "    16     " & $Sector_Nr & "             HD" & $Disk_Nr & "_" & $Sector_Nr & "_FAT32.dat")
					EndIf
				EndIf
				If $linesplit[0] = 19 And $linesplit[9] = "|" And $linesplit[10] = "f" And $linesplit[11] = "|" Then
					$EPBR_Sector_Nr = $linesplit[16]
					; MsgBox(48, "EPBR Found", "EPBR Sector = " & $EPBR_Sector_Nr)
					RunWait(@ComSpec & " /c makebt\MbrFix.exe /drive " & $Disk_Nr & " readdrive " & $EPBR_Sector_Nr & " 1 " & $Backup_Folder & "\" & $Disk_Folder & "\HD" & $Disk_Nr & "_epbr_" & $EPBR_Sector_Nr & ".dat", @ScriptDir, @SW_HIDE)
					FileWriteLine(@ScriptDir & "\" & $LogFile, " " & $count & "  HD " & $Disk_Nr & "   EPBR    1     " & $EPBR_Sector_Nr & "             HD" & $Disk_Nr & "_epbr_" & $EPBR_Sector_Nr & ".dat")
				EndIf
				If $linesplit[0] = 19 And $linesplit[9] = "|" And $linesplit[10] = "5" And $linesplit[11] = "|" Then
					$EBR_Sector_Nr = $EPBR_Sector_Nr + $linesplit[16]
					; MsgBox(48, "EBR Found", "EBR Sector = " & $EBR_Sector_Nr)
					RunWait(@ComSpec & " /c makebt\MbrFix.exe /drive " & $Disk_Nr & " readdrive " & $Sector_Nr & " 1 " & $Backup_Folder & "\" & $Disk_Folder & "\HD" & $Disk_Nr & "_ebr_" & $EBR_Sector_Nr & ".dat", @ScriptDir, @SW_HIDE)
					FileWriteLine(@ScriptDir & "\" & $LogFile, " " & $count & "  HD " & $Disk_Nr & "   EBR     1     " & $EBR_Sector_Nr & "             HD" & $Disk_Nr & "_ebr_" & $EBR_Sector_Nr & ".dat")
				EndIf
			EndIf
		Wend
		FileWriteLine(@ScriptDir & "\" & $LogFile, " =============================================================================")
		FileClose($file)
	EndIf
EndFunc ;==> _MBR_Backup
;===================================================================================================
Func DisableMenus($endis)
	If $endis = 0 Then
		$endis = $GUI_ENABLE
	Else
		$endis = $GUI_DISABLE
	EndIf
	GUICtrlSetState($PART_INFO, $endis)
	GUICtrlSetState($PART_GUI, $endis)
	GUICtrlSetState($GO, $endis + $GUI_FOCUS)
EndFunc ;==>DisableMenus
;===================================================================================================

