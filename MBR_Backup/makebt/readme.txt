~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PARTINFG.EXE - WinXP and later GUI version
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This version allows you to view the MBR/EMBR partition information and
optionally export a report that you can send for support purposes.


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PARTINFO.EXE - DOS/Win9x/WinME command line version.
PARTINFW.EXE - WinNT/Win2K/WinXP command line version.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the '>' symbol to redirect the output to a file.

For example:

partinfo > c:\partinfo.txt

or

partinfw > c:\partinfo.txt

The above example assumes you have permission to create a new file in
the root of C:.  If not, you may want to place it on your desktop by
entering the command as:

partinfw > %userprofile%\desktop\partinfo.txt

Note:

Redirection will only work under Windows when running partinfw from a
command prompt (not Start/Run).  Consider obtaining Drop to DOS from
www.terabyteunlimited.com/utilities.html.  Drop to DOS makes it easy
to open a command prompt within an existing folder (such as the one
that contains partinfw) by simply right clicking it and selecting
Drop to DOS (same as Open Command Prompt).


Windows 9x Note:

Windows 9x may crash if you have any removable drives with windows drivers
where the drive is mapped to the BIOS as a hard drive.  For example, if you
had a SCSI jaz drive and the SCSI adapter set to support removable
devices as bootable (making the jaz device show up as a BIOS HD) then
Win9x will crash as soon as this program accesses that drive.
