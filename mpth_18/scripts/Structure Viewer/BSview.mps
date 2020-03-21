option title, "BSview by jaclaz"
=
=
=	Tiny Hexer script for Bootsector structure view in
=	mirkes.de's tiny hex editor
=
=	by jaclaz, 29 November 2009


option GlobalVars, 0
option ReadTags, 1
option target, structureviewer

= open active editor and goto current position/0
var editor file
editor = fileopen('::current')
if ((param_count > 0) and (dword(params(0))==1))
  fileseek editor, 0
else
  fileseek editor, filegetprop(editor, 'selstart')
endif

var start dword
start = filegetprop(editor, 'position')

= open browser window
var browser file
browser = fileopen('::browser', 'c')

filewrite browser " "
filewrite browser " "

var myfilesize longword
let myfilesize=filegetprop(editor, 'size')

var maxreach longword
let maxreach=start+512

if myfilesize < maxreach
filesetprop browser, 'accepttags', 1
filewrite browser "<font color=blue><b><u>WARNING: </u></b></font>MAXaddress: ",DEC(maxreach)," is beyond EOF: ",DEC(myfilesize),""
filesetprop browser, 'accepttags', 0
GOTO THE_END
ENDIF




= here we start working for real

=variables declarations:
var thispos dword
var pos_0 dword

=FAT16
var jmp1 byte 
var jmp2 byte
var jmp3 byte
var jmp longword

var Filesystem text
var OEM text
var bytesec word
var seclust byte
var ressec word
var nfats byte
var maxroot word
var small word
var media byte
var secfat word
var secfat2 longword
var sechead word
var nheads word
var secbefore longword
var large longword
var disknum byte
var chead byte
var ntsig byte
var volser longword
var vollabel text
var sysid text
var sysfile1 text
var sysfile2 text
var sysfile3 text

=FAT32 only
var flags word


=NTFS only
var totsecs sigqword
var lcn sigqword
var lcnm sigqword
var clusm byte
var nouse word
var clusi byte
var volsernt sigqword
var nouse2 longword

var Status byte
var StatusText text
var Unused1 byte
var Signature text
var Sigvalue longword
var Reserved1 byte
var Reserved2 byte
var KCSsum longword
var Boot byte
var Type byte
var bytevar byte
var wordvar word
var BCyl byte
var Bhead byte
var BSec byte
var ECyl byte
var Ehead byte
var ESec byte
var StartLBA longword
var NumLBA longword
var B_line text
var this_section text
var First3 text
var First3value longword
var First3stext text
var Parttype text
var MagicBytes word
var MagicBytesBE word


let pos_0=start-start
tagvar pos_0, pos_0, 1

filesetprop browser, 'accepttags', 1
filewrite browser "<p><font color=blue><b><u>Master Boot Record structure</u>:</b></font></p>"
filewrite browser "<p>Start position: ",start,"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Position 0 of open file: ",pos_0,"</p>"
filesetprop browser, 'accepttags', 0
call open_table
let this_section="GENERAL DATA:"
call section_header
call type_headers

let thispos=start
fileseek editor, thispos
fileread editor jmp1
let thispos=thispos+1
fileread editor jmp2
let thispos=thispos+1
fileread editor jmp3
let thispos=start
tagvar thispos, thispos, 3
let jmp=jmp3+jmp2*256+jmp1*65536
tagvar jmp, thispos, 3
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tJMP instruction:    ",HEX(jmp,0,6),"\t\t","\n"

let thispos=start
fileseek editor, thispos
fileread editor First3, 3
let First3value=TEXT2DATABE(First3,0,3)
tagvar First3value, thispos, 3
IF First3value==0xEB5890 :let First3stext="Possibly FAT32 NT code" :ENDIF
IF First3value==0x33C08ED0 :let First3stext="Possibly MS DOS code" :ENDIF

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,3),"</p></td>"
filewrite browser "<td align=center><p>JMP First 3 bytes:</p></td>"
filewrite browser "<td align=right><p>",HEX(First3value,0,3),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=center><p>",First3stext,"</p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0



let thispos=start+3
fileseek editor, thispos
fileread editor filesystem,4
tagvar thispos, thispos, 4
IF filesystem=="NTFS" :
	filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tFilesytem:\t\t\t\t",filesystem,"\t\t","\n" 
:ELSE
	let thispos=start+54
	fileseek editor, thispos
	fileread editor filesystem,3
	tagvar thispos, thispos, 3
	IF filesystem=="FAT" :
		let thispos=start+54
		fileseek editor, thispos
		fileread editor filesystem,5
		tagvar thispos, thispos, 5
		filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tFilesytem:\t\t\t\t",filesystem,"\t\t","\n" 
	:ELSE
		let thispos=start+82
		fileseek editor, thispos
		fileread editor filesystem,5
		tagvar thispos, thispos, 5
		filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tFilesytem:\t\t\t\t",filesystem,"\t\t","\n" 

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,3),"</p></td>"
filewrite browser "<td align=center><p>Filesystem:</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=center><p>",filesystem,"</p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0

	:ENDIF
:ENDIF

let thispos=start+510
tagvar thispos, thispos, 2
fileseek editor, thispos
fileread editor MagicBytes,2
let MagicBytesBE=TEXT2DATABE(DATA2TEXT(MagicBytes))
tagvar MagicBytesBE, thispos, 2

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Magic Bytes:</p></td>"
filewrite browser "<td align=right><p>",MagicBytes,"</p></td>"
filewrite browser "<td align=right><p></p></td>"
IF MagicBytes==0xAA55 :filewrite browser "<td align=center><p>Magic Bytes ",HEX(MagicBytesBE)," OK</p></td>":ELSE :filewrite browser "<td align=center><p>Magic Bytes WRONG</p></td>" :ENDIF
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0
call close_table

call open_table
let this_section="Bootsector specific:"
call section_header
call type_headers



IF filesystem=="FAT12" :

let thispos=start+3
fileseek editor, thispos
fileread editor OEM,8
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tOEM String:\t\t\t\t",OEM,"\t\t","\n" 

let thispos=start+11
fileseek editor, thispos
fileread editor ByteSec
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tBytes per sector:     ",HEX(ByteSec),"   ",DEC(ByteSec),"\n" 

let thispos=start+24
fileseek editor, thispos
fileread editor seclust
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per cluster:    ",HEX(seclust),"   ",DEC(seclust),"\n" 

let thispos=start+14
fileseek editor, thispos
fileread editor ressec
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tReserved sectors:     ",HEX(ressec),"   ",DEC(ressec),"\n"

let thispos=start+16
fileseek editor, thispos
fileread editor nfats
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNumber of FAT(s):       ",HEX(nfats),"   ",DEC(nfats),"\n" 

let thispos=start+17
fileseek editor, thispos
fileread editor maxroot
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tMax ROOT entries:     ",HEX(maxroot),"   ",DEC(maxroot),"\n"

let thispos=start+19
fileseek editor, thispos
fileread editor small
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSmall type sectors:   ",HEX(small),"   ",DEC(small),"\n"

let thispos=start+21
fileseek editor, thispos
fileread editor media
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tMedia type:             ",HEX(media),"   ",DEC(media),"\n"

let thispos=start+22
fileseek editor, thispos
fileread editor secfat
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per FAT:      ",HEX(secfat),"   ",DEC(secfat),"\n"

let thispos=start+24
fileseek editor, thispos
fileread editor sechead
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per Head:     ",HEX(sechead),"   ",DEC(sechead),"\n"

let thispos=start+26
fileseek editor, thispos
fileread editor nheads
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNumber of Heads:      ",HEX(nheads),"   ",DEC(nheads),"\n"

let thispos=start+28
fileseek editor, thispos
fileread editor secbefore
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors Before:   ",HEX(secbefore),"   ",DEC(secbefore),"\n"

let thispos=start+32
fileseek editor, thispos
fileread editor large
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tLarge Sectors:    ",HEX(large),"   ",DEC(large),"\n"

let thispos=start+36
fileseek editor, thispos
fileread editor disknum
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tDisk number:            ",HEX(disknum),"   ",DEC(disknum),"\n"

let thispos=start+37
fileseek editor, thispos
fileread editor chead
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tCurrent Head:           ",HEX(chead),"   ",DEC(chead),"\n"

let thispos=start+38
fileseek editor, thispos
fileread editor ntsig
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNT signature:           ",HEX(ntsig),"   ",DEC(ntsig),"\n"

let thispos=start+77
fileseek editor, thispos
fileread editor volser
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tVolume Serial:    ",HEX(volser),"   ",DEC(volser),"\n"

let thispos=start+43
fileseek editor, thispos
fileread editor vollabel,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tVolume label:\t\t\t\t",vollabel,"\t\t","\n"

let thispos=start+54
fileseek editor, thispos
fileread editor sysid,8
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem ID:\t\t\t\t",sysid,"\t\t","\n"

let thispos=start+472
fileseek editor, thispos
fileread editor sysfile1,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 1:\t\t\t\t",sysfile1,"\t\t","\n"

let thispos=start+483
fileseek editor, thispos
fileread editor sysfile2,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 2:\t\t\t\t",sysfile2,"\t\t","\n"

:ENDIF



IF filesystem=="FAT16" :

let thispos=start+3
fileseek editor, thispos
fileread editor OEM,8
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tOEM String:\t\t\t\t",OEM,"\t\t","\n" 

let thispos=start+11
fileseek editor, thispos
fileread editor ByteSec
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tBytes per sector:     ",HEX(ByteSec),"   ",DEC(ByteSec),"\n" 

let thispos=start+24
fileseek editor, thispos
fileread editor seclust
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per cluster:    ",HEX(seclust),"   ",DEC(seclust),"\n" 

let thispos=start+14
fileseek editor, thispos
fileread editor ressec
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tReserved sectors:     ",HEX(ressec),"   ",DEC(ressec),"\n"

let thispos=start+16
fileseek editor, thispos
fileread editor nfats
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNumber of FAT(s):       ",HEX(nfats),"   ",DEC(nfats),"\n" 

let thispos=start+17
fileseek editor, thispos
fileread editor maxroot
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tMax ROOT entries:     ",HEX(maxroot),"   ",DEC(maxroot),"\n"

let thispos=start+19
fileseek editor, thispos
fileread editor small
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSmall type sectors:   ",HEX(small),"   ",DEC(small),"\n"

let thispos=start+21
fileseek editor, thispos
fileread editor media
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tMedia type:             ",HEX(media),"   ",DEC(media),"\n"

let thispos=start+22
fileseek editor, thispos
fileread editor secfat
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per FAT:      ",HEX(secfat),"   ",DEC(secfat),"\n"

let thispos=start+24
fileseek editor, thispos
fileread editor sechead
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per Head:     ",HEX(sechead),"   ",DEC(sechead),"\n"

let thispos=start+26
fileseek editor, thispos
fileread editor nheads
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNumber of Heads:      ",HEX(nheads),"   ",DEC(nheads),"\n"

let thispos=start+28
fileseek editor, thispos
fileread editor secbefore
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors Before:   ",HEX(secbefore),"   ",DEC(secbefore),"\n"

let thispos=start+32
fileseek editor, thispos
fileread editor large
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tLarge Sectors:    ",HEX(large),"   ",DEC(large),"\n"

let thispos=start+36
fileseek editor, thispos
fileread editor disknum
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tDisk number:            ",HEX(disknum),"   ",DEC(disknum),"\n"

let thispos=start+37
fileseek editor, thispos
fileread editor chead
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tCurrent Head:           ",HEX(chead),"   ",DEC(chead),"\n"

let thispos=start+38
fileseek editor, thispos
fileread editor ntsig
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNT signature:           ",HEX(ntsig),"   ",DEC(ntsig),"\n"

let thispos=start+77
fileseek editor, thispos
fileread editor volser
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tVolume Serial:    ",HEX(volser),"   ",DEC(volser),"\n"

let thispos=start+43
fileseek editor, thispos
fileread editor vollabel,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tVolume label:\t\t\t\t",vollabel,"\t\t","\n"

let thispos=start+54
fileseek editor, thispos
fileread editor sysid,8
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem ID:\t\t\t\t",sysid,"\t\t","\n"

let thispos=start+472
fileseek editor, thispos
fileread editor sysfile1,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 1:\t\t\t\t",sysfile1,"\t\t","\n"

let thispos=start+483
fileseek editor, thispos
fileread editor sysfile2,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 2:\t\t\t\t",sysfile2,"\t\t","\n"

:ENDIF

IF filesystem=="FAT32" :

let thispos=start+3
fileseek editor, thispos
fileread editor OEM,8
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tOEM String:\t\t\t\t",OEM,"\t\t","\n" 

let thispos=start+11
fileseek editor, thispos
fileread editor ByteSec
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tBytes per sector:     ",HEX(ByteSec),"   ",DEC(ByteSec),"\n" 

let thispos=start+13
fileseek editor, thispos
fileread editor seclust
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per cluster:    ",HEX(seclust),"   ",DEC(seclust),"\n" 

let thispos=start+14
fileseek editor, thispos
fileread editor ressec
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tReserved sectors:     ",HEX(ressec),"   ",DEC(ressec),"\n"

let thispos=start+16
fileseek editor, thispos
fileread editor nfats
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNumber of FAT(s):       ",HEX(nfats),"   ",DEC(nfats),"\n" 

let thispos=start+17
fileseek editor, thispos
fileread editor maxroot
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tMax ROOT entries:     ",HEX(maxroot),"   ",DEC(maxroot),"\n"

let thispos=start+19
fileseek editor, thispos
fileread editor small
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSmall type sectors:   ",HEX(small),"   ",DEC(small),"\n"

let thispos=start+21
fileseek editor, thispos
fileread editor media
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tMedia type:             ",HEX(media),"   ",DEC(media),"\n"

let thispos=start+22
fileseek editor, thispos
fileread editor secfat
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSecs per FAT (small): ",HEX(secfat),"   ",DEC(secfat),"\n"

let thispos=start+24
fileseek editor, thispos
fileread editor sechead
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per Head:     ",HEX(sechead),"   ",DEC(sechead),"\n"

let thispos=start+26
fileseek editor, thispos
fileread editor nheads
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNumber of Heads:      ",HEX(nheads),"   ",DEC(nheads),"\n"

let thispos=start+28
fileseek editor, thispos
fileread editor secbefore
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors Before:   ",HEX(secbefore),"   ",DEC(secbefore),"\n"

let thispos=start+32
fileseek editor, thispos
fileread editor large
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tLarge Sectors:    ",HEX(large),"   ",DEC(large),"\n"

let thispos=start+36
fileseek editor, thispos
fileread editor secfat2
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per FAT:  ",HEX(secfat2),"   ",DEC(secfat2),"\n"

let thispos=start+40
fileseek editor, thispos
fileread editor flags
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tFlags:                ",HEX(flags),"   ",DEC(flags),"\n"

let thispos=start+66
fileseek editor, thispos
fileread editor ntsig
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNT signature:           ",HEX(ntsig),"   ",DEC(ntsig),"\n"

let thispos=start+77
fileseek editor, thispos
fileread editor volser
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tVolume Serial:    ",HEX(volser),"   ",DEC(volser),"\n"

let thispos=start+71
fileseek editor, thispos
fileread editor vollabel,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tVolume label:\t\t\t\t",vollabel,"\t\t","\n"

let thispos=start+82
fileseek editor, thispos
fileread editor sysid,8
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem ID:\t\t\t\t",sysid,"\t\t","\n"

let thispos=start+472
fileseek editor, thispos
fileread editor sysfile1,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 1:\t\t\t\t",sysfile1,"\t\t","\n"

let thispos=start+483
fileseek editor, thispos
fileread editor sysfile2,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 2:\t\t\t\t",sysfile2,"\t\t","\n"

let thispos=start+368
fileseek editor, thispos
fileread editor sysfile3,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 3:\t\t\t\t",sysfile3,"\t\t","\n"

:ENDIF

IF filesystem=="NTFS" :

let thispos=start+3
fileseek editor, thispos
fileread editor OEM,8
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tOEM String:\t\t\t\t",OEM,"\t\t","\n" 

let thispos=start+11
fileseek editor, thispos
fileread editor ByteSec
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tBytes per sector:     ",HEX(ByteSec),"   ",DEC(ByteSec),"\n" 

let thispos=start+13
fileseek editor, thispos
fileread editor seclust
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per cluster:    ",HEX(seclust),"   ",DEC(seclust),"\n" 

let thispos=start+14
fileseek editor, thispos
fileread editor ressec
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tReserved sectors:     ",HEX(ressec),"   ",DEC(ressec),"\n"

let thispos=start+16
fileseek editor, thispos
fileread editor nfats
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNumber of FAT(s):       ",HEX(nfats),"   ",DEC(nfats),"\n" 

let thispos=start+17
fileseek editor, thispos
fileread editor maxroot
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tMax ROOT entries:     ",HEX(maxroot),"   ",DEC(maxroot),"\n"

let thispos=start+19
fileseek editor, thispos
fileread editor small
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSmall type sectors:   ",HEX(small),"   ",DEC(small),"\n"

let thispos=start+21
fileseek editor, thispos
fileread editor media
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tMedia type:             ",HEX(media),"   ",DEC(media),"\n"

let thispos=start+22
fileseek editor, thispos
fileread editor secfat
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSecs per FAT (small): ",HEX(secfat),"   ",DEC(secfat),"\n"

let thispos=start+24
fileseek editor, thispos
fileread editor sechead
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per Head:     ",HEX(sechead),"   ",DEC(sechead),"\n"

let thispos=start+26
fileseek editor, thispos
fileread editor nheads
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNumber of Heads:      ",HEX(nheads),"   ",DEC(nheads),"\n"

let thispos=start+28
fileseek editor, thispos
fileread editor secbefore
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors Before:   ",HEX(secbefore),"   ",DEC(secbefore),"\n"

let thispos=start+32
fileseek editor, thispos
fileread editor large
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tLarge Sectors:    ",HEX(large),"   ",DEC(large),"\n"

let thispos=start+36
fileseek editor, thispos
fileread editor secfat2
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSectors per FAT:  ",HEX(secfat2),"   ",DEC(secfat2),"\n"

let thispos=start+40
fileseek editor, thispos
fileread editor totsecs
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tTotal Sectors:                ",HEX(totsecs),"   ",DEC(totsecs),"\n"

let thispos=start+48
fileseek editor, thispos
fileread editor lcn
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tLCN for $MFT::                ",HEX(lcn),"   ",DEC(lcn),"\n"

let thispos=start+56
fileseek editor, thispos
fileread editor lcnm
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tLCN for $MFTMirr::                ",HEX(lcnm),"   ",DEC(lcnm),"\n"

let thispos=start+64
fileseek editor, thispos
fileread editor clusm
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tClusters per $MFT record:            ",HEX(clusm),"   ",DEC(clusm),"\n"

let thispos=start+66
fileseek editor, thispos
fileread editor nouse
tagvar thispos, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNOT used:           ",HEX(nouse),"   ",DEC(nouse),"\n"



let thispos=start+68
fileseek editor, thispos
fileread editor clusi
tagvar thispos, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tClusters per Index record:            ",HEX(clusi),"   ",DEC(clusi),"\n"


let thispos=start+72
fileseek editor, thispos
fileread editor volsernt
tagvar thispos, thispos, 8
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tVolume Serial:    ",HEX(volsernt),"\n"

let thispos=start+71
fileseek editor, thispos
fileread editor vollabel,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tVolume label:\t\t\t\t",vollabel,"\t\t","\n"

let thispos=start+80
fileseek editor, thispos
fileread editor nouse2
tagvar thispos, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNOT used:           ",HEX(nouse2),"   ",DEC(nouse2),"\n"




let thispos=start+472
fileseek editor, thispos
fileread editor sysfile1,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 1:\t\t\t\t",sysfile1,"\t\t","\n"

let thispos=start+483
fileseek editor, thispos
fileread editor sysfile2,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 2:\t\t\t\t",sysfile2,"\t\t","\n"

let thispos=start+368
fileseek editor, thispos
fileread editor sysfile3,11
tagvar thispos, thispos, 11
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSystem File 3:\t\t\t\t",sysfile3,"\t\t","\n"

:ENDIF

GOTO END
let thispos=start+434
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Status
IF Status==0x00 :let Statustext="Status NOT set":ELSE :let Statustext="Status set" :ENDIF
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tStatus byte:      ",Status, "\t",DEC(Status),"\t",Statustext,"\n"

let thispos=start+435
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Unused1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tUnused byte:      ",Unused1, "\t",DEC(Unused1),"\n"

let thispos=start+440
tagvar thispos, thispos, 2
fileseek editor, thispos
fileread editor Signature,4
let Sigvalue=TEXT2DATA(Signature)
tagvar Sigvalue, thispos, 4
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tSignature:  ",Sigvalue, "\t\t",Signature,"\t"
IF Sigvalue==0x00000000 :filewrite browser "NO signature \n" :ELSE :filewrite browser "Signature OK \n" :ENDIF

let thispos=start+444
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Reserved1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tReserved 1:       ",Reserved1, "\t",DEC(Reserved1),"\n"

let thispos=start+445
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Reserved2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tReserved 2:       ",Reserved2, "\t",DEC(Reserved2),"\n\n"

let KCSsum=Status*16777216+Unused1*65536+Reserved1*256+Reserved2
IF KCSsum==0x00000000 :filewrite browser " \n" :ELSE :filewrite browser "Possible XP Kansas City Shuffle with value ",KCSsum,"\n" :ENDIF

filesetprop browser, 'accepttags', 1
filewrite browser "\n<font color=blue><b><u>FIRST PARTITION DATA:</u></b></font>\n"
filesetprop browser, 'accepttags', 0
let pos_0=0
call Part_loop

filesetprop browser, 'accepttags', 1
filewrite browser "\n<font color=blue><b><u>SECOND PARTITION DATA:</u></b></font>\n"
filesetprop browser, 'accepttags', 0
let pos_0=16
call Part_loop

filesetprop browser, 'accepttags', 1
filewrite browser "\n<font color=blue><b><u>THIRD PARTITION DATA:</u></b></font>\n"
filesetprop browser, 'accepttags', 0
let pos_0=32
call Part_loop

filesetprop browser, 'accepttags', 1
filewrite browser "\n<font color=blue><b><u>FOURTH PARTITION DATA:</u></b></font>\n"
filesetprop browser, 'accepttags', 0
let pos_0=48
call Part_loop

filesetprop browser, 'accepttags', 1
filewrite browser "<font color=blue><b><u>Note:</u></b><font><font color=black>  Data marked with * may not correspond to hex values,\n<font>"
filesetprop browser, 'accepttags', 0
filewrite browser "due to 16 bit conversion into 10+6 (Cylinders and Sectors).\n"
@@end
end

@@Part_loop
let thispos=pos_0+446
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Boot
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tBoot (Active):    ",Boot,"\t",DEC(Boot),"\t"
IF Boot==0x80 :filewrite browser "Active \n" :ELSE :filewrite browser "NOT Active \n" :ENDIF

let thispos=pos_0+450
fileseek editor, thispos
tagvar thispos, thispos, 1
fileread editor Type
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tPartition Type:   ",Type,"\t"
filewrite browser " \n"

let thispos=pos_0+449
tagvar thispos, thispos, 2
fileseek editor, thispos
fileread editor BCyl

let thispos=pos_0+448
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor BSec

let bytevar=BSec
let bytevar=bytevar>>6
let wordvar=WORD(bytevar)
let wordvar=wordvar<<8
let wordvar=wordvar+BCyl
tagvar wordvar, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tBegin Cylinder: ",wordvar,"*\t",DEC(wordvar),"\n"

let thispos=pos_0+447
fileseek editor, thispos
tagvar thispos, thispos, 1
fileread editor BHead
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tBegin Head:       ",BHead,"\t",DEC(BHead),"\n"

let bytevar=BSec
let bytevar=bytevar<<2
let bytevar=bytevar>>2
tagvar bytevar, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tBegin Sector:     ",bytevar,"*\t",DEC(bytevar),"\n"

let thispos=pos_0+453
tagvar thispos, thispos, 2
fileseek editor, thispos
fileread editor ECyl

let thispos=pos_0+452
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor ESec

let bytevar=ESec
let bytevar=bytevar>>6
let wordvar=WORD(bytevar)
let wordvar=wordvar<<8
let wordvar=wordvar+ECyl
tagvar wordvar, thispos, 2
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tEnd Cylinder:   ",wordvar,"*\t",DEC(wordvar),"\n"

let thispos=pos_0+451
fileseek editor, thispos
tagvar thispos, thispos, 1
fileread editor EHead
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tEnd Head:         ",EHead,"\t",DEC(EHead),"\n"


let bytevar=ESec
let bytevar=bytevar<<2
let bytevar=bytevar>>2
tagvar bytevar, thispos, 1
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tEnd Sector:       ",bytevar,"*\t",DEC(bytevar),"\n"


let thispos=pos_0+454
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor StartLBA
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tStart LBA:  ",startLBA,"\t",DEC(StartLBA),"\n"

let thispos=pos_0+458
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor NumLBA
filewrite browser DEC(thispos),"\t", HEX(thispos,0,4),"\tNum LBA:    ",NumLBA,"\t",DEC(NumLBA),"\n\n"


return

@@open_table
filesetprop browser, 'accepttags', 1
filewrite browser "<body bgcolor=#CCCCCC text=black link=blue vlink=purple alink=red>"
filewrite browser "<table border=1>"
filesetprop browser, 'accepttags', 0
return

@@section_header
filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=left colspan=6><p><font color=blue><b><u>",this_section,"</u></b></font></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0
return

@@type_headers
filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td width=100 align=center colspan=2><p><b>Offset</b></p></td>"
filewrite browser "<td width=100 align=center rowspan=2><p><b>&nbsp;&nbsp;Description&nbsp;&nbsp;</b></p></td>"
filewrite browser "<td width=160 align=center colspan=2><p><b>Value</b></p></td>"
filewrite browser "<td width=400 align=center rowspan=2><p><b>Notes</b></p></td>"
filewrite browser "</tr>"
filewrite browser "<tr>"
filewrite browser "<td width=50 align=center><p><b>Dec</b></p></td>"
filewrite browser "<td width=50 align=center><p><b>Hex</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>Hex</b></p></td>"
filewrite browser "<td width=60 align=center><p><b>Dec</b></p></td>"

filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0
return

@@close_table
filesetprop browser, 'accepttags', 1
filewrite browser "</table>"
filewrite browser "<br>"
filesetprop browser, 'accepttags', 0
return


@@THE_END