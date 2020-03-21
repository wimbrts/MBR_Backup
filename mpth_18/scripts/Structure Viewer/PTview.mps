option title, "PTview by jaclaz"
=
=
=	Tiny Hexer script for MBR Partition Table view in
=	mirkes.de's tiny hex editor
=
=	by jaclaz, 29 November 2009


option GlobalVars, 1
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

var Entry byte
var Bcyl0 word
var temptext text
var tempref varref

var Boot byte
var Type byte

var bytevar byte
var wordvar word
var BCyl word
var BCyl_temp byte
var Bhead byte
var BSec word
var BSec_temp byte
var ECyl word
var ECyl_temp byte
var Ehead byte
var ESec word
var ESec_temp byte
var StartSector longword
var NumSectors longword
var B_line text

=filewrite browser CURRENTFILE


filesetprop browser, 'accepttags', 1
filewrite browser "<br>"
filesetprop browser, 'accepttags', 0

let pos_0=start-start
tagvar pos_0, pos_0, 1


filesetprop browser, 'accepttags', 1
filewrite browser "<p><font color=blue><b><u>Partition Table Data</u></b></font></p>"
filewrite browser "<br>"
filewrite browser "<p>Start position: ",start,"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Position 0 of open file: ",pos_0,"</p>"
filewrite browser "<br>"
filewrite browser "<p>As seen in Beeblebrox: "
filewrite browser "<a href=http://students.cs.byu.edu/~codyb/>http://students.cs.byu.edu/~codyb/</p>"
filewrite browser "<body bgcolor=#CCCCCC text=black link=blue vlink=purple alink=red>"
filewrite browser "<table border=1>"
filewrite browser "<tr><b>"
filewrite browser "<td width=100 align=center><p><b>Entry</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>Type</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>Boot</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>&nbsp;bCyl&nbsp;</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>bHead</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>bSect</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>&nbsp;eCyl&nbsp;</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>eHead</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>eSec</b></p></td>"
filewrite browser "<td width=100 align=center><p><b>&nbsp;</b></p></td>"
filewrite browser "<td width=300 align=center><p><b>&nbsp;StartSector&nbsp;</b></p></td>"
filewrite browser "<td width=300 align=center><p><b>&nbsp;NumSectors&nbsp;</b></p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0

Let Entry=0
let pos_0=start+0
call Part_loop

Let Entry=1
let pos_0=start+16
call Part_loop

Let Entry=2
let pos_0=start+32
call Part_loop

Let Entry=3
let pos_0=start+48
call Part_loop


end

@@Part_loop
let thispos=pos_0+446
tagvar Entry, thispos, 16

let thispos=pos_0+450
fileseek editor, thispos
tagvar thispos, thispos, 1
fileread editor Type

let thispos=pos_0+446
tagvar thispos, thispos, 1
fileseek editor, thispos
fileread editor Boot

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

let bytevar=BSec_temp
let BSec_temp=BSec_temp<<2
let BSec_temp=BSec_temp>>2
tagvar BSec_temp, thispos, 1
let Bsec=BSec_temp

let thispos=pos_0+447
fileseek editor, thispos
tagvar thispos, thispos, 1
fileread editor BHead

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

let bytevar=ESec_temp
let ESec_temp=ESec_temp<<2
let ESec_temp=ESec_temp>>2
tagvar ESec_temp, thispos, 1
let Esec=ESec_temp

let thispos=pos_0+451
fileseek editor, thispos
tagvar thispos, thispos, 1
fileread editor EHead

let thispos=pos_0+454
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor StartSector

let thispos=pos_0+458
tagvar thispos, thispos, 4
fileseek editor, thispos
fileread editor NumSectors

filesetprop browser, 'accepttags', 1
filewrite browser "<tr>"
filewrite browser "<td align=center><p>#",DEC(Entry),"</p></td>"
filewrite browser "<td align=center><p>",HEX(Type),"</p></td>"
filewrite browser "<td align=center><p>",HEX(Boot),"</p></td>"
filewrite browser "<td align=right><p>",DEC(bcyl),"</p></td>"
filewrite browser "<td align=right><p>",DEC(BHead),"</p></td>"
filewrite browser "<td align=right><p>",DEC(bSec),"</p></td>"
filewrite browser "<td align=right><p>",DEC(eCyl),"</p></td>"
filewrite browser "<td align=right><p>",DEC(eHead),"</p></td>"
filewrite browser "<td align=right><p>",DEC(eSec),"</p></td>"
filewrite browser "<td align=center><p>&nbsp;</p></td>"
filewrite browser "<td align=right><p>",DEC(StartSector),"</p></td>"
filewrite browser "<td align=right><p>",DEC(NumSectors),"</p></td>"
filewrite browser "</tr>"
filesetprop browser, 'accepttags', 0

return
@@THE_END
