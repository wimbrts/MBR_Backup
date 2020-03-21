:: ========================================================================================================
:: ====================================== MBR_Backup.cmd - 16 Feb 2020 ====================================
:: ========================================================================================================
@ECHO OFF
CLS

set winos=NT
set win_vista=0

:: Check Windows version
IF NOT "%OS%"=="Windows_NT"  (
  ECHO.
  ECHO ***** ONLY for Windows XP OR Windows 2003 OR Vista *****
  ECHO.
  GOTO :_end_quit
) 

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

SET TP=%~dp0
SET TP=%TP:~0,-1%
cd /d "%TP%"

:: Vista checks ::::::::::::

IF "%winos%"=="NT" (
  VER | find "6.0." > nul
  IF !errorlevel! EQU 0 SET win_vista=1
)

Set datum=%DATE%
FOR /F "tokens=2 delims= " %%G in ('ECHO %datum%') DO (
  set datum=%%G
)

FOR /F "tokens=1,2,3 delims=/.-" %%G in ('ECHO !datum!') DO (
  set datum=%%I-%%H-%%G
)

SET compname=%computername%
FOR /F "tokens=1 delims= " %%G in ('ECHO %compname%') DO (
  set compname=%%G
)

SET log_nm=MBR_%compname%_%datum%
SET b_fol=!log_nm!

ECHO.
ECHO  Program - MBR_Backup.cmd - 16 Feb 2020 - Date = %DATE% %TIME:~0,8%
ECHO.
ECHO  Use R-mouse Menu to Run MBR_Backup.cmd as Administrator is required
ECHO.
ECHO  Make Backup of all Bootsectors of all Local Harddisks Fixed + Removable
ECHO.
ECHO  Learn More Using the Links in MBR_bookmark.htm in Folder Help_Info
ECHO.
ECHO  Use TinyHexer to Compare BootSectors in Detail - ALL USE IS AT OWN RISK
ECHO.
ECHO  ***** Backup Contains BootSector Files for:
ECHO.
ECHO  Guid Partition Table - GPT - First 34 Sectors of GPT Harddisk
ECHO.
ECHO  Master Boot Record - MBR - Sector 0 of Harddisk containing Partition Table
ECHO.
ECHO  Extended Partition Boot Record - EPBR - Beginning of Extended Partition
ECHO.
ECHO  Extended Boot Records - EBR - Beginning of Logical Partitions within Extended
ECHO.
ECHO  Partition BootSectors - 16 Sectors for NTFS FAT32 and 1 Sector for FAT32  FAT
ECHO.
ECHO  And Partition Info File = MBR_Date_ComputerName.txt
ECHO.
ECHO  ***** PARTINFW.EXE and MbrFix.exe are needed in MBR_Backup\makebt Folder ****
ECHO.
ECHO  =============================================================================

PAUSE

Set /A Counter=0

:backuploop
SET /A Counter=%Counter%+1
IF %Counter%==6 GOTO :__Error2
IF %Counter% GTR 1 Set b_fol=%log_nm%_%Counter%

IF NOT EXIST %b_fol%\nul (
  MD %b_fol%
) ELSE (
  GOTO :backuploop
)

(
  ECHO.
  ECHO.
  ECHO  ************************** NEW MBR Backup ***********************************
  ECHO  =============================================================================
  ECHO.
  ECHO  Program - MBR_Backup.cmd - 16 Feb 2020 - Date = %DATE% %TIME:~0,8%
  ECHO.
  ECHO  Use R-mouse Menu to Run MBR_Backup.cmd as Administrator is required
  ECHO.
  ECHO  Make Backup of all Bootsectors of all Local Harddisks Fixed + Removable
  ECHO.
  ECHO  Learn More Using the Links in MBR_bookmark.htm in Folder Help_Info
  ECHO.
  ECHO  Use TinyHexer to Study and Compare BootSectors in Detail
  ECHO.
  ECHO  Use TinyHexer for Restore of Bootsectors - Hopefully Never Needed
  ECHO.
  ECHO  ***** Using These Programs is COMPLETELY At Your Own Risk *****
  ECHO.
  ECHO  ***** Backup Contains BootSector Files for:
  ECHO.
  ECHO  Guid Partition Table - GPT - First 34 Sectors of GPT Harddisk
  ECHO.
  ECHO  Master Boot Record - MBR - Sector 0 of Harddisk containing Partition Table
  ECHO.
  ECHO  Extended Partition Boot Record - EPBR - Beginning of Extended Partition
  ECHO.
  ECHO  Extended Boot Records - EBR - Beginning of Logical Partitions within Extended
  ECHO.
  ECHO  Partition BootSectors - 16 Sectors for NTFS FAT32 and 1 Sector for FAT32  FAT
  ECHO.
  ECHO  And Partition Info File = MBR_Date_ComputerName.txt
  ECHO.
  ECHO  ***** PARTINFW.EXE and MbrFix.exe are needed in MBR_Backup\makebt Folder ****
  ECHO.
  ECHO  =============================================================================
) >> %b_fol%\%log_nm%.log


FINDSTR.EXE /? >NUL 2>&1
IF ERRORLEVEL 1 (
  ECHO.
  ECHO  ***** ERROR - FINDSTR.EXE NOT Found *****
  ECHO.
  GOTO _end_quit
)

IF NOT EXIST makebt\PARTINFW.EXE (
  ECHO.
  ECHO  ***** ERROR - File makebt\PARTINFW.EXE is Missing *****
  ECHO.
  GOTO _end_quit
)

IF NOT EXIST makebt\MbrFix.exe (
  ECHO.
  ECHO  ***** ERROR - File makebt\MbrFix.exe is Missing *****
  ECHO.
  GOTO _end_quit
)

makebt\PARTINFW.EXE > %b_fol%\MBR_%compname%_partinfw.txt
IF ERRORLEVEL 1 (
  ECHO.
  ECHO  ***** ERROR - File PARTINFW.EXE could NOT Make Partition Info File *****
  ECHO  ***** ERROR - File PARTINFW.EXE could NOT Make Partition Info File ***** >> %b_fol%\%log_nm%.log
  ECHO.
  GOTO _end_quit
)

IF EXIST %b_fol%\MBR_%compname%_partinfw.txt (
  SET partinf=%b_fol%\MBR_%compname%_partinfw.txt
) ELSE (
  ECHO.
  ECHO  ***** ERROR - %b_fol%\MBR_%compname%_partinfw.txt Partition Info File NOT Found *****
  ECHO  ***** ERROR - %b_fol%\MBR_%compname%_partinfw.txt Partition Info File NOT Found ***** >> %b_fol%\%log_nm%.log
  ECHO.
  GOTO _end_quit
)


IF "%win_vista%"=="1" (
  FIND "MBR" %partinf% > nul
  IF "!errorlevel!"=="0" (
    ECHO.
    ECHO  Partition Info = %partinf%
  ) ELSE (
    ECHO.
    ECHO  STOP Vista - First Set User Account Control OFF
    ECHO.
    ECHO.>> %b_fol%\%log_nm%.log
    ECHO  STOP Vista - First Set User Account Control OFF >> %b_fol%\%log_nm%.log
    ECHO.>> %b_fol%\%log_nm%.log
    goto _end_quit
  )
) ELSE (
  ECHO.
  ECHO  Partition Info = %partinf%
  ECHO.>> %b_fol%\%log_nm%.log
  ECHO >> %b_fol%\%log_nm%.log Partition Info = %partinf%
)

:: ======================== Making Backup BootSector Files ================================================



SET /A count=0
FOR /F "tokens=1,2,5,7 delims=: " %%G in ('TYPE %partinf% ^| FINDSTR /N "MBR LBA"') DO (
  SET rgnr=%%G
  IF !rgnr! LSS 100 SET rgnr= %%G
  IF !rgnr! LSS 10  SET rgnr=  %%G
  IF "%%H"=="MBR" (
    SET dnr=%%I
    IF NOT "%%J"=="" (
      SET dnum=!dnr:~3,2!
      SET /A count=!count! + 1
      SET __dn.!count!=!dnum!
      SET __rg.!count!=%%G
      SET lba_cnt=0
      SET dhex=%%J
      SET dhex=!dhex:~0,-1!
      SET __dh.!count!=!dhex!
      SET hd_fol=HD!dnum!_!dhex!
      IF NOT EXIST %b_fol%\!hd_fol!\nul MD %b_fol%\!hd_fol!
      ECHO.
      ECHO. >> %b_fol%\%log_nm%.log
      makebt\MbrFix.exe /drive !dnum! savembr %b_fol%\!hd_fol!\HD!dnum!_mbr.dat
      IF ERRORLEVEL 1 GOTO __ERROR1
      ECHO  =============================================================================
      ECHO  ============================================================================= >> %b_fol%\%log_nm%.log
      ECHO.
      ECHO. >> %b_fol%\%log_nm%.log
      ECHO  Backup Folder  = %b_fol%\!hd_fol!
      ECHO  Backup Folder  = %b_fol%\!hd_fol! >> %b_fol%\%log_nm%.log
      ECHO.
      ECHO. >> %b_fol%\%log_nm%.log
      ECHO  Rule Disk   TYPE  Sectors  Start         BackupFile
      ECHO  Rule Disk   TYPE  Sectors  Start         BackupFile >> %b_fol%\%log_nm%.log
      ECHO.
      ECHO. >> %b_fol%\%log_nm%.log
      ECHO  !rgnr!  HD !dnum!   MBR     1     0             HD!dnum!_mbr.dat
      ECHO  !rgnr!  HD !dnum!   MBR     1     0             HD!dnum!_mbr.dat >> %b_fol%\%log_nm%.log
    )
  ) ELSE (
    SET mkhead=0
    SET dsec=%%J
    SET /A lba_cnt=!lba_cnt! + 1
    IF !lba_cnt! EQU 1 (
      SET __rglba.!count!=%%G
      IF !dsec! EQU Max  SET mkhead=2
      IF !dsec! EQU 2048 SET mkhead=1
      IF !dsec! EQU 63   SET mkhead=1
      IF "!mkhead!"=="2" (
        makebt\MbrFix.exe /drive !dnum! readdrive 0 34 %b_fol%\!hd_fol!\HD!dnum!_gpt.dat
        IF ERRORLEVEL 1 GOTO __ERROR1
        ECHO  !rgnr!  HD !dnum!   GPT    34     0             HD!dnum!_gpt.dat
        ECHO  !rgnr!  HD !dnum!   GPT    34     0             HD!dnum!_gpt.dat >> %b_fol%\%log_nm%.log
      )
      IF "!mkhead!"=="1" (
        makebt\MbrFix.exe /drive !dnum! readdrive 0 63 %b_fol%\!hd_fol!\HD!dnum!_mbr_head.dat
        IF ERRORLEVEL 1 GOTO __ERROR1
        ECHO  !rgnr!  HD !dnum!   HEAD   63     0             HD!dnum!_mbr_head.dat
        ECHO  !rgnr!  HD !dnum!   HEAD   63     0             HD!dnum!_mbr_head.dat >> %b_fol%\%log_nm%.log
      )
    )
    IF "%%I"=="Backup" SET mkhead=3
    IF "%%I"=="LAvail" SET mkhead=3
    IF !mkhead! LSS 2 (
      IF "%%I"=="0x7" (
        makebt\MbrFix.exe /drive !dnum! readdrive !dsec! 16 %b_fol%\!hd_fol!\HD!dnum!_!dsec!.dat
        IF ERRORLEVEL 1 GOTO __ERROR1
        ECHO  !rgnr!  HD !dnum!   %%I    16     !dsec!          HD!dnum!_!dsec!.dat
        ECHO  !rgnr!  HD !dnum!   %%I    16     !dsec!          HD!dnum!_!dsec!.dat >> %b_fol%\%log_nm%.log
      ) ELSE (
        makebt\MbrFix.exe /drive !dnum! readdrive !dsec! 1 %b_fol%\!hd_fol!\HD!dnum!_!dsec!.dat
        IF ERRORLEVEL 1 GOTO __ERROR1
        ECHO  !rgnr!  HD !dnum!   %%I     1     !dsec!          HD!dnum!_!dsec!.dat
        ECHO  !rgnr!  HD !dnum!   %%I     1     !dsec!          HD!dnum!_!dsec!.dat >> %b_fol%\%log_nm%.log
      )
      SET f32sect=0
      IF "%%I"=="0xB" SET f32sect=1
      IF "%%I"=="0xC" SET f32sect=1
      IF "%%I"=="0x1B" SET f32sect=1
      IF "%%I"=="0x1C" SET f32sect=1
      IF !f32sect! EQU 1 (
        makebt\MbrFix.exe /drive !dnum! readdrive !dsec! 16 %b_fol%\!hd_fol!\HD!dnum!_!dsec!_FAT32.dat
        IF ERRORLEVEL 1 GOTO __ERROR1
        ECHO  !rgnr!  HD !dnum!   %%I    16     !dsec!          HD!dnum!_!dsec!_FAT32.dat
        ECHO  !rgnr!  HD !dnum!   %%I    16     !dsec!          HD!dnum!_!dsec!_FAT32.dat >> %b_fol%\%log_nm%.log
      )
    )
  )
)


SET cmax=!count!

ECHO.
ECHO. >> %b_fol%\%log_nm%.log
ECHO  =============================================================================
ECHO  ============================================================================= >> %b_fol%\%log_nm%.log

:: ======================== Making EBR Backup BootSector Files ============================================

ECHO  =========== Making EBR Backup BootSector Files ==============================
ECHO  =========== Making EBR Backup BootSector Files ============================== >> %b_fol%\%log_nm%.log
ECHO.
ECHO. >> %b_fol%\%log_nm%.log
ECHO  Rule Disk   TYPE  Sectors  Start         BackupFile
ECHO  Rule Disk   TYPE  Sectors  Start         BackupFile >> %b_fol%\%log_nm%.log
ECHO.
ECHO. >> %b_fol%\%log_nm%.log

SET dnum=!__dn.1!
SET dhex=!__dh.1!
FOR /F "tokens=1,17 delims=: " %%A in ('TYPE %partinf% ^| FINDSTR /N /C:"|  f |"') DO (
  FOR /L %%G IN (1,1,%cmax%) DO (
    IF %%A GTR !__rg.%%G! (
      SET dnum=!__dn.%%G!
      SET epbr=%%B
      SET rg_mbr=!__rg.%%G!
      SET rg_lba=!__rglba.%%G!
      SET dhex=!__dh.%%G!
    )
  )
  SET hd_fol=HD!dnum!_!dhex!
  makebt\MbrFix.exe /drive !dnum! readdrive !epbr! 1 %b_fol%\!hd_fol!\HD!dnum!_epbr_!epbr!.dat
  IF ERRORLEVEL 1 GOTO __ERROR1
  SET rgnr=%%A
  IF !rgnr! LSS 100 SET rgnr= %%A
  IF !rgnr! LSS 10  SET rgnr=  %%A
  ECHO  !rgnr!  HD !dnum!   EPBR    1     !epbr!       HD!dnum!_epbr_!epbr!.dat
  ECHO  !rgnr!  HD !dnum!   EPBR    1     !epbr!       HD!dnum!_epbr_!epbr!.dat >> %b_fol%\%log_nm%.log
  FOR /F "tokens=1,17 delims=: " %%P in ('TYPE %partinf% ^| FINDSTR /N /C:"|  5 |"') DO (
    IF %%P GTR !rg_mbr! IF %%P LSS !rg_lba! (
      SET /A ebr=!epbr! + %%Q
      makebt\MbrFix.exe /drive !dnum! readdrive !ebr! 1 %b_fol%\!hd_fol!\HD!dnum!_ebr_!ebr!.dat
      IF ERRORLEVEL 1 GOTO __ERROR1
      SET rgnr=%%P
      IF !rgnr! LSS 100 SET rgnr= %%P
      IF !rgnr! LSS 10  SET rgnr=  %%P
      ECHO  !rgnr!  HD !dnum!   EBR     1     !ebr!       HD!dnum!_ebr_!ebr!.dat
      ECHO  !rgnr!  HD !dnum!   EBR     1     !ebr!       HD!dnum!_ebr_!ebr!.dat >> %b_fol%\%log_nm%.log
    ) 
  )
  ECHO.
  ECHO. >> %b_fol%\%log_nm%.log
)

SET dnum=!__dn.1!
SET dhex=!__dh.1!
FOR /F "tokens=1,17 delims=: " %%A in ('TYPE %partinf% ^| FINDSTR /N /C:"|  5 |"') DO (
  FOR /L %%G IN (1,1,%cmax%) DO (
    IF %%A GTR !__rg.%%G! (
      SET dnum=!__dn.%%G!
      SET epbr=%%B
      SET rg_mbr=!__rg.%%G!
      SET rg_lba=!__rglba.%%G!
      SET dhex=!__dh.%%G!
    )
  )
  SET /A rg_pt=!rg_mbr! + 7
  IF %%A LSS !rg_pt! (
    SET hd_fol=HD!dnum!_!dhex!
    makebt\MbrFix.exe /drive !dnum! readdrive !epbr! 1 %b_fol%\!hd_fol!\HD!dnum!_epbr_!epbr!.dat
    IF ERRORLEVEL 1 GOTO __ERROR1
    SET rgnr=%%A
    IF !rgnr! LSS 100 SET rgnr= %%A
    IF !rgnr! LSS 10  SET rgnr=  %%A
    ECHO  !rgnr!  HD !dnum!   EPBR    1     !epbr!       HD!dnum!_epbr_!epbr!.dat
    ECHO  !rgnr!  HD !dnum!   EPBR    1     !epbr!       HD!dnum!_epbr_!epbr!.dat >> %b_fol%\%log_nm%.log
    FOR /F "tokens=1,17 delims=: " %%P in ('TYPE %partinf% ^| FINDSTR /N /C:"|  5 |"') DO (
      IF %%P GTR !rg_pt! IF %%P LSS !rg_lba! (
        SET /A ebr=!epbr! + %%Q
        makebt\MbrFix.exe /drive !dnum! readdrive !ebr! 1 %b_fol%\!hd_fol!\HD!dnum!_ebr_!ebr!.dat
        IF ERRORLEVEL 1 GOTO __ERROR1
        SET rgnr=%%P
        IF !rgnr! LSS 100 SET rgnr= %%P
        IF !rgnr! LSS 10  SET rgnr=  %%P
        ECHO  !rgnr!  HD !dnum!   EBR     1     !ebr!       HD!dnum!_ebr_!ebr!.dat
        ECHO  !rgnr!  HD !dnum!   EBR     1     !ebr!       HD!dnum!_ebr_!ebr!.dat >> %b_fol%\%log_nm%.log
      ) 
    )
    ECHO.
    ECHO. >> %b_fol%\%log_nm%.log
  )
)


ECHO  =============================================================================
ECHO  ============================================================================= >> %b_fol%\%log_nm%.log

ECHO.
ECHO  File System ID:  TYPE 0x7 = NTFS   0xC = FAT32X   0xE = FAT16X
ECHO.
ECHO.>> %b_fol%\%log_nm%.log
ECHO >> %b_fol%\%log_nm%.log File System ID:  TYPE 0x7 = NTFS   0xC = FAT32X   0xE = FAT16X
ECHO.>> %b_fol%\%log_nm%.log


:_end_quit
ECHO.
ECHO  ***** End Program - MBR_Backup.cmd *****
ECHO.

(
  ECHO.
  ECHO  ***** End Program - MBR_Backup.cmd *****
  ECHO.
) >> %b_fol%\%log_nm%.log

IF "%OS%"=="Windows_NT" ENDLOCAL
PAUSE
EXIT

:__ERROR1
ECHO.
Echo  ***** ERROR - MbrFix could not Backup Your Bootsectors - End Of Program *****
ECHO.

(
  ECHO.
  Echo  ***** ERROR - MbrFix could not Backup Your Bootsectors - End Of Program *****
  ECHO.
) >> %b_fol%\%log_nm%.log
pause
GOTO _end_quit

:__Error2
ECHO.
ECHO  ***** STOP - Backup Folder %b_fol% Exists Already *****
ECHO.
ECHO  ***** Too Many Backups - Delete OR Rename First Existing Backup Folders ***** 
ECHO.
GOTO _end_quit


:: ========================================================================================================
:: ====================================== END MBR_Backup.cmd ==============================================
:: ========================================================================================================
