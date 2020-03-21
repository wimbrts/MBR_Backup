option title, "WimOverlayView by jaclaz"
=
=
=	Tiny Hexer script for WimOverlay.dat structure
=	 view in mirkes.de's tiny hex editor
=
=	by jaclaz, 13 April 2019

REQUIRE 'def.mps'

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
= let maxreach=start+512
let maxreach=start+219

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

var thispostext text
var thisposvalue longword
var thisposdesc text


var First4 text
var First4value longword
var WimProviderVersion longword
var Unknown01 longword
var WimOverlay_dat_entry_num_1 longword
var WimOverlay_dat_entry_num_2 longword
var Unknown02 longword
var Unknown03 longword
var Unknown04 longword
var WimPathSize longword

var PathOffsetPos longword
var Unknown05 longword
var Unknown06 longword

var Unknown07 longword
var InnerStructureSize longword
var Unknown08 longword
var Unknown09 longword
var Unknown10 longword
var Unknown11 longword
var Unknown12 longword

var IsMBR byte
var Bytesbefore qword
var NextInstance qword
var padding64 qword

var GUID0_4 longword
var GUID4_2 word
var GUID6_2 word
var GUID8_2 word
var GUID10_2 word
var GUID12_4 longword
var GUID_value text

var Sigvalue longword
var SigvalueBE longword

var Unknown13 longword
var Unknown14 longword
var Unknown15 longword
var Unknown16 longword

var Status byte
var StatusText text
var Unused1 byte
var Signature text

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
filewrite browser "<p><font color=blue><b><u>WimOverlay.dat File Structure</u>:</b></font></p>"
filewrite browser "<p>Start position: ",start,"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Position 0 of open file: ",pos_0,"</p>"

call open_table
let this_section="Wim_Overlay_dat_header:"
call section_header
call type_headers



let thispos=start
fileseek editor, thispos
fileread editor thispostext, 4
let thisposvalue=TEXT2DATABE(thispostext,0,4)
tagvar thisposvalue, thispos, 4
let thispostext="File Signature"+data2text(thispostext)
let thisposdesc="First 4 bytes:"
call print_line_longword_HEX


let thispos=start+4
let thisposdesc="WimProviderVersion:"
let thispostext=
call print_line_longword_DEC

let thispos=start+8
let thisposdesc="Unknown01:"
let thispostext=
call print_line_longword_DEC


let thispos=start+12
let thisposdesc="WimOverlay_dat_entry_num_1:"
let thispostext=
call print_line_longword_DEC


let thispos=start+16
tagvar thispos, thispos, 8
fileseek editor, thispos
fileread editor NextInstance


filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,8),"</p></td>"
filewrite browser "<td align=center><p>Next Instance:</p></td>"
filewrite browser "<td align=right><p>",HEX(NextInstance),"</p></td>"
filewrite browser "<td align=right><p>",DEC(NextInstance),"</p></td>"
filewrite browser "<td align=center><p>Next available data source id</p></td>"
filewrite browser "</tr>"



call open_table
let this_section="WimOverlay_dat_entry_1:"
call section_header
call type_headers


let thispos=start+24
let thisposdesc="Unknown03:"
let thispostext=
call print_line_longword_DEC

let thispos=start+28
let thisposdesc="Unknown04:"
let thispostext=
call print_line_longword_DEC

let thispos=start+32
let thisposdesc="WimOverlay_dat_entry_num_2_size:"
let thispostext="Wim path size including 3 leading null dwords"
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor thisposvalue

filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>",thisposdesc,"</p></td>"
filewrite browser "<td align=right><p>",HEX(thisposvalue),"</p></td>"
filewrite browser "<td align=right><p>",DEC(thisposvalue),"</p></td>"
filewrite browser "<td align=center><p>",thispostext,"</p></td>"
filewrite browser "</tr>"
let WimPathSize=thisposvalue






let thispos=start+36
let thisposdesc="Unknown05:"
let thispostext="Possibly offset to the above"
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor thisposvalue

filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>",thisposdesc,"</p></td>"
filewrite browser "<td align=right><p>",HEX(thisposvalue),"</p></td>"
filewrite browser "<td align=right><p>",DEC(thisposvalue),"</p></td>"
filewrite browser "<td align=center><p>",thispostext,"</p></td>"
filewrite browser "</tr>"
let PathOffsetPos=thisposvalue











let thispos=start+40
let thisposdesc="Unknown06:"
let thispostext=
call print_line_longword_DEC


let thispos=start+44
let thisposdesc="Unknown06bis:"
let thispostext=
call print_line_longword_DEC





let thispos=start+48
tagvar thispos, thispos, 16

fileseek editor, thispos
fileread editor GUID0_4
fileseek editor, thispos+4
fileread editor GUID4_2
fileseek editor, thispos+6
fileread editor GUID6_2
fileseek editor, thispos+8
fileread editor GUID8_2
fileseek editor, thispos+10
fileread editor GUID10_2
fileseek editor, thispos+12
fileread editor GUID12_4

let GUID_value="{"+HEX(GUID0_4)+"-"+HEX(GUID4_2)+"-"+HEX(GUID6_2)+"-"+HEX(text2data(data2textBE(GUID8_2)))+"-"+HEX(text2data(data2textBE(GUID10_2)))+HEX(text2data(data2textBE(GUID12_4)))+"}"
tagvar GUID_value, thispos, 16

filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>WIM GUID</p></td>"

filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=center colspan=2><p>",GUID_value,"</p></td>"
= filewrite browser "<td align=right><p></p></td>"

filewrite browser "</tr>"



= here are 24 bytes undocumented
call open_table
let this_section="Here be lions:"
call section_header
call type_headers


let thispos=start+64
tagvar thispos, thispos, 16
fileseek editor, thispos
fileread editor Unknown07

filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Undocumented 16 bytes:</p></td>"
= filewrite browser "<td align=right><p></p></td>"
= filewrite browser "<td align=right><p></p></td>"
filewrite browser "\n" :call BYTEOUT 16
= filewrite browser "</tr>"




call open_table
let this_section="WimOverlay_dat_entry_2:"
call section_header
call type_headers



let thispos=start+84
let thisposdesc="Unknown07:"
let thispostext="Should be 1"
call print_line_longword_DEC

let thispos=start+88
let thisposdesc="InnerStructureSize:"
let thispostext="Size of this structure"
call print_line_longword_DEC



let thispos=start+92
let thisposdesc="Unknown08:"
let thispostext="Should be 5"
call print_line_longword_DEC


let thispos=start+96
let thisposdesc="Unknown09:"
let thispostext="Should be 6"
call print_line_longword_DEC


let thispos=start+100
let thisposdesc="Unknown10:"
let thispostext="Should be 0"
call print_line_longword_DEC


let thispos=start+104
let thisposdesc="Unknown11:"
let thispostext="Should be 72"
call print_line_longword_DEC



let thispos=start+108
let thisposdesc="Unknown12:"
let thispostext="Should be 0"
call print_line_longword_DEC


let thispos=start+132
fileseek editor, thispos
fileread editor thisposvalue

IF DEC(thisposvalue) == DEC(BYTE(1))
let IsMBR=1
let thispos=start+112
tagvar thispos, thispos, 8
fileseek editor, thispos
fileread editor Bytesbefore


filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,8),"</p></td>"
filewrite browser "<td align=center><p>Bytes before partition/volume:</p></td>"
filewrite browser "<td align=right><p>",HEX(Bytesbefore),"</p></td>"
filewrite browser "<td align=right><p>",DEC(Bytesbefore),"</p></td>"
filewrite browser "<td align=center><p>","Sectors Before "+DEC(Bytesbefore/512),"</p></td>"
filewrite browser "</tr>"

let thispos=start+120
tagvar thispos, thispos, 8
fileseek editor, thispos
fileread editor padding64


filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,8),"</p></td>"
filewrite browser "<td align=center><p>64 bits padding :</p></td>"
filewrite browser "<td align=right><p>",HEX(padding64),"</p></td>"
filewrite browser "<td align=right><p>",DEC(padding64),"</p></td>"
filewrite browser "<td align=center><p>Should be 0 (MBR)</p></td>"
filewrite browser "</tr>"

ELSE

IF DEC(thisposvalue) == DEC(BYTE(0))

let thispos=start+112
tagvar thispos, thispos, 16
fileseek editor, thispos
fileread editor GUID0_4
fileseek editor, thispos+4
fileread editor GUID4_2
fileseek editor, thispos+6
fileread editor GUID6_2
fileseek editor, thispos+8
fileread editor GUID8_2
fileseek editor, thispos+10
fileread editor GUID10_2
fileseek editor, thispos+12
fileread editor GUID12_4

let GUID_value="{"+HEX(GUID0_4)+"-"+HEX(GUID4_2)+"-"+HEX(GUID6_2)+"-"+HEX(text2data(data2textBE(GUID8_2)))+"-"+HEX(text2data(data2textBE(GUID10_2)))+HEX(text2data(data2textBE(GUID12_4)))+"}"
tagvar GUID_value, thispos, 16
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>GPT Unique GUID</p></td>"

filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=center colspan=2><p>",GUID_value,"</p></td>"
= filewrite browser "<td align=right><p></p></td>"

filewrite browser "</tr>"
ENDIF
ENDIF


let thispos=start+128
let thisposdesc="Unknown13:"
let thispostext="Should be 0"
call print_line_longword_DEC

let thispos=start+132
let thisposdesc="DiskPartInfo:"
let thispostext="IF 0 GPT; IF 1 MBR"
call print_line_longword_DEC


IF DEC(IsMBR) == DEC(BYTE(1))

let thispos=start+136
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor Signature, 4
let Sigvalue=TEXT2DATA(Signature)
tagvar Sigvalue, thispos, 4
let SigvalueBE=TEXT2DATABE(Signature)
tagvar SigvalueBE, thispos, 4

filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>Disk Signature:</p></td>"
filewrite browser "<td align=right><p>",Sigvalue,"</p></td>"
filewrite browser "<td align=right><p></p></td>"
IF Sigvalue==0x00000000 :filewrite browser "<td align=center><p>NO signature</p></td>":ELSE :filewrite browser "<td align=center><p>OK, reversed ",HEX(SigvalueBE),"</p></td>" :ENDIF
filewrite browser "</tr>"

let thispos=start+140
let thisposdesc="Unknown14:"
let thispostext="Should be 0"
call print_line_longword_DEC

let thispos=start+144
let thisposdesc="Unknown15:"
let thispostext="Should be 0"
call print_line_longword_DEC

let thispos=start+148
let thisposdesc="Unknown16:"
let thispostext="Should be 0"
call print_line_longword_DEC


let thispos=start+152
let thisposdesc="Unknown17:"
let thispostext="Should be 0"
call print_line_longword_DEC

ELSE

IF DEC(IsMBR) == DEC(BYTE(0))

let thispos=start+136
tagvar thispos, thispos, 16
fileseek editor, thispos
fileread editor GUID0_4
fileseek editor, thispos+4
fileread editor GUID4_2
fileseek editor, thispos+6
fileread editor GUID6_2
fileseek editor, thispos+8
fileread editor GUID8_2
fileseek editor, thispos+10
fileread editor GUID10_2
fileseek editor, thispos+12
fileread editor GUID12_4

let GUID_value="{"+HEX(GUID0_4)+"-"+HEX(GUID4_2)+"-"+HEX(GUID6_2)+"-"+HEX(text2data(data2textBE(GUID8_2)))+"-"+HEX(text2data(data2textBE(GUID10_2)))+HEX(text2data(data2textBE(GUID12_4)))+"}"
tagvar GUID_value, thispos, 16
filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>GPT Disk GUID</p></td>"

filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=center colspan=2><p>",GUID_value,"</p></td>"
= filewrite browser "<td align=right><p></p></td>"

filewrite browser "</tr>"

let thispos=start+152
let thisposdesc="Unknown17:"
let thispostext="Should be 0"
call print_line_longword_DEC

ENDIF
ENDIF


let thispos=start+PathOffsetPos
= let thispos=start+156
let thisposdesc="Unknown18:"
let thispostext="Should be 0"
call print_line_longword_DEC

let thispos=start+PathOffsetPos+4
= let thispos=start+156
let thisposdesc="Unknown19:"
let thispostext="Should be 0"
call print_line_longword_DEC

let thispos=start+PathOffsetPos+8
= let thispos=start+156
let thisposdesc="Unknown20:"
let thispostext="Should be 0"
call print_line_longword_DEC



let thispos=start+PathOffsetPos+12
tagvar thispos, thispos, WimPathSize-12
= here is the path
= read a string starting at thispos  of length WimPathSize
local myreadstring
  var len word res text p dword
  len = WimPathSize-12
=  p = filepos(editor)
p = thispos
fileread editor res len
    res = textconvert(res, TEXTCONVERT_UNICODE, TEXTCONVERT_ANSI)
    tagvar res p len
  return res
endlocal

filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>(relative) Wim Path:</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=center><p>",#myreadstring,"</p></td>"
filewrite browser "</tr>"


= here is a seoparator




call close_table


end


@@open_table

filewrite browser "<body bgcolor=#CCCCCC text=black link=blue vlink=purple alink=red>"
filewrite browser "<table border=1>"

return

@@section_header

filewrite browser "<tr>"
filewrite browser "<td align=left colspan=6><p><font color=blue><b><u>",this_section,"</u></b></font></p></td>"
filewrite browser "</tr>"

return

@@type_headers

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

return

@@print_line_longword_DEC
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor thisposvalue

filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>",thisposdesc,"</p></td>"
filewrite browser "<td align=right><p>",HEX(thisposvalue),"</p></td>"
filewrite browser "<td align=right><p>",DEC(thisposvalue),"</p></td>"
filewrite browser "<td align=center><p>",thispostext,"</p></td>"
filewrite browser "</tr>"

return

@@print_line_longword_HEX

filewrite browser "<tr>"
filewrite browser "<td align=center><p>",DEC(thispos),"</p></td>"
filewrite browser "<td align=center><p>",HEX(thispos,0,4),"</p></td>"
filewrite browser "<td align=center><p>",thisposdesc,"</p></td>"
filewrite browser "<td align=right><p>",HEX(thisposvalue),"</p></td>"
filewrite browser "<td align=right><p></p></td>"
filewrite browser "<td align=center><p>",thispostext,"</p></td>"
filewrite browser "</tr>"

return


@@BYTEOUT:= output a byte

filewrite browser "<td align=center colspan=3><p>"
var w byte w1 byte
pop w
repeat
  fileread editor w1
  filewrite browser HEX(w1)
  inc w -1
  if w > 0
    filewrite browser " "
  endif
until w == 0
filewrite browser "</p></td>"

return




@@close_table

filewrite browser "</table>"
filewrite browser "<br>"

return

@@THE_END
