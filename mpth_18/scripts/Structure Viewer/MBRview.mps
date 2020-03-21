option title, "MBRview by jaclaz"
=
=
=	Tiny Hexer script for MBR structure view in
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

= filesetprop editor, 'Position', 0



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
var First4 text
var First4value longword
var Status byte
var StatusText text
var Unused1 byte
var Signature text
var Sigvalue longword
var SigvalueBE longword
var Reserved1 byte
var Reserved2 byte
var KCSsum longword
var Boot byte
var Type byte
var bytevar byte
var wordvar word
var BCyl word
var BCyl_temp byte
var Bhead byte
var BSec byte
var BSec_temp byte
var ECyl word
var ECyl_temp byte
var Ehead byte
var ESec byte
var ESec_temp byte
var StartLBA longword
var NumLBA longword
var B_line text
var MagicBytes word
var MagicBytesBE word
var this_section text
var First4stext text
var Parttype text

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
fileread editor First4, 4
let First4value=TEXT2DATABE(First4,0,4)
tagvar First4value, thispos, 4
IF First4value==0xEA0501B0 :let First4stext="Possibly XOSL code" :ENDIF
IF First4value==0x33C08ED0 :let First4stext="Possibly MS DOS code" :ENDIF

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>First 4 bytes:</p></td>"
filewrite browser "<td align=right><p>",HEX(First4value),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=center><p>",First4stext,"</p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0



let thispos=start+434
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Status
IF Status==0x00 :let Statustext="Status NOT set":ELSE :let Statustext="Status set" :ENDIF

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Status byte:</p></td>"
filewrite browser "<td align=right><p>",Status,"</p></td>"
filewrite browser "<td align=right><p>",DEC(Status),"</p></td>"
filewrite browser "<td align=center><p>",Statustext,"</p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0




let thispos=start+435
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Unused1

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Unused byte:</p></td>"
filewrite browser "<td align=right><p>",Unused1,"</p></td>"
filewrite browser "<td align=right><p>",DEC(Unused1),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0





let thispos=start+440
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor Signature, 4
let Sigvalue=TEXT2DATA(Signature)
tagvar Sigvalue, thispos, 4
let SigvalueBE=TEXT2DATABE(Signature)
tagvar SigvalueBE, thispos, 4

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Signature:</p></td>"
filewrite browser "<td align=right><p>",Sigvalue,"</p></td>"
filewrite browser "<td align=right><p></p></td>"
IF Sigvalue==0x00000000 :filewrite browser "<td align=center><p>NO signature</p></td>":ELSE :filewrite browser "<td align=center><p>OK, reversed ",HEX(SigvalueBE),"</p></td>" :ENDIF
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0





let thispos=start+444
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Reserved1

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Reserved 1:</p></td>"
filewrite browser "<td align=right><p>",Reserved1,"</p></td>"
filewrite browser "<td align=right><p>",DEC(Reserved1),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0



let thispos=start+445
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Reserved2

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Reserved 2:</p></td>"
filewrite browser "<td align=right><p>",Reserved2,"</p></td>"
filewrite browser "<td align=right><p>",DEC(Reserved2),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0



let KCSsum=Status*16777216+Unused1*65536+Reserved1*256+Reserved2

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p></p></td>"
filewrite browser "<td align=center><p></p></td>"
filewrite browser "<td align=center><p>KCSsum:</p></td>"
filewrite browser "<td align=right><p>",HEX(KCSsum),"</p></td>"
filewrite browser "<td align=right><p>",DEC(KCSsum),"</p></td>"
IF KCSsum==0x00000000 :filewrite browser "<td align=center><p>NO XP Kansas City Shuffle</p></td>":ELSE :filewrite browser "<td align=center><p>Possible XP Kansas City Shuffle</p></td>" :ENDIF
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0

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
let this_section="FIRST PARTITION DATA:"
call section_header
call type_headers
let pos_0=start+0
call Part_loop
call close_table


call open_table
let this_section="SECOND PARTITION DATA:"
call section_header
call type_headers
let pos_0=start+16
call Part_loop
call close_table


call open_table
let this_section="THIRD PARTITION DATA:"
call section_header
call type_headers
let pos_0=start+32
call Part_loop
call close_table


call open_table
let this_section="FOURTH PARTITION DATA:"
call section_header
call type_headers
let pos_0=start+48
call Part_loop
call close_table



call open_table
filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=left colspan=6><p><font color=blue><b><u>Note:</u></b><font><font color=black>  Data marked with * may not correspond to hex values, due to 16 bit conversion into 10+6 (Cylinders and Sectors).<font></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0
call close_table

end

@@Part_loop
let thispos=pos_0+446
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Boot

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Boot (Active):</p></td>"
filewrite browser "<td align=right><p>",Boot,"</p></td>"
filewrite browser "<td align=right><p>",DEC(Boot),"</p></td>"
IF Boot==0x80 :filewrite browser "<td align=center><p>Active</p></td>":ELSE :filewrite browser "<td align=center><p>NOT Active</p></td>" :ENDIF
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0




let thispos=pos_0+450
fileseek editor, thispos
tagvar thispos, thispos, 1
fileread editor Type
let Parttype=""
IF Type==0x01 :let Parttype="FAT12":ENDIF
IF Type==0x04 :let Parttype="FAT16 (small) obsolete":ENDIF
IF Type==0x05 :let Parttype="Extended CHS mapped":ENDIF
IF Type==0x06 :let Parttype="FAT16 CHS mapped":ENDIF
IF Type==0x07 :let Parttype="NTFS":ENDIF
IF Type==0x0B :let Parttype="FAT32 CHS mapped":ENDIF
IF Type==0x0C :let Parttype="FAT32 LBA mapped":ENDIF
IF Type==0x0E :let Parttype="FAT16 LBA mapped":ENDIF
IF Type==0x0F :let Parttype="Extended LBA mapped":ENDIF


filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Partition Type:</p></td>"
filewrite browser "<td align=right><p>",HEX(Type),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=center><p>",Parttype,"</p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0


let thispos=pos_0+449
tagvar thispos, thispos, 2
fileseek editor, thispos
fileread editor BCyl_temp

let thispos=pos_0+448
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor BSec_temp

let bytevar=BSec_temp
let bytevar=bytevar>>6
let BCyl=WORD(bytevar)
let BCyl=BCyl<<8
let BCyl=BCyl+BCyl_temp
tagvar BCyl, thispos, 2


filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Begin Cylinder:</p></td>"
filewrite browser "<td align=right><p>",BCyl,"*</p></td>"
filewrite browser "<td align=right><p>",DEC(BCyl),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0

let bytevar=BSec_temp
let BSec_temp=BSec_temp<<2
let BSec_temp=BSec_temp>>2
tagvar BSec_temp, thispos, 1
let Bsec=BSec_temp


let thispos=pos_0+447
fileseek editor, thispos
tagvar thispos, thispos, 1
fileread editor BHead


filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Begin Head:</p></td>"
filewrite browser "<td align=right><p>",BHead,"</p></td>"
filewrite browser "<td align=right><p>",DEC(BHead),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Begin Sector:</p></td>"
filewrite browser "<td align=right><p>",Bsec,"*</p></td>"
filewrite browser "<td align=right><p>",DEC(Bsec),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0


let thispos=pos_0+453
tagvar thispos, thispos, 2
fileseek editor, thispos
fileread editor ECyl_temp

let thispos=pos_0+452
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor ESec_temp

let bytevar=ESec_temp
let bytevar=bytevar>>6
let ECyl=WORD(bytevar)
let ECyl=ECyl<<8
let ECyl=ECyl+ECyl_temp
tagvar ECyl, thispos, 2


filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>End Cylinder:</p></td>"
filewrite browser "<td align=right><p>",ECyl,"*</p></td>"
filewrite browser "<td align=right><p>",DEC(ECyl),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0


let bytevar=ESec_temp
let ESec_temp=ESec_temp<<2
let ESec_temp=ESec_temp>>2
tagvar ESec_temp, thispos, 1
let Esec=ESec_temp



let thispos=pos_0+451
fileseek editor, thispos
tagvar thispos, thispos, 1
fileread editor EHead


filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>End Head:</p></td>"
filewrite browser "<td align=right><p>",EHead,"</p></td>"
filewrite browser "<td align=right><p>",DEC(EHead),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>End Sector:</p></td>"
filewrite browser "<td align=right><p>",Esec,"*</p></td>"
filewrite browser "<td align=right><p>",DEC(Esec),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0



let thispos=pos_0+454
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor StartLBA

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Start LBA:</p></td>"
filewrite browser "<td align=right><p>",startLBA,"</p></td>"
filewrite browser "<td align=right><p>",DEC(startLBA),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0


let thispos=pos_0+458
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor NumLBA

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Num LBA:</p></td>"
filewrite browser "<td align=right><p>",NumLBA,"</p></td>"
filewrite browser "<td align=right><p>",DEC(NumLBA),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0


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
