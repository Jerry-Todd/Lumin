local a={...}local b={}local c=require require=function(d)local e=d:gsub('%.'
,'_')if b[e]then return b[e]()end return c(d)end function b.main(...)local f=
{}local g=false f.CreateBasicView=require("views.basic")f.CreateSection=require(
"views.section")f.CreateScrollSection=require("views.scroll")f.CreateButton=
require("views.button")f.CreateLabel=require("views.label")f.CreateTextInput=
require("views.textinput")local h=nil function f.setMainView(i)h=i end local
function j(k)if not k or(term.native and k==term.native())then return nil,false
end local l=k.setTextScale~=nil local m=nil if peripheral and peripheral.getName
then local n,o=pcall(peripheral.getName,k)if n and type(o)=="string"then m=
o l=true end end if not m and l and peripheral and peripheral.getNames then
local p={}for q,o in ipairs(peripheral.getNames())do if peripheral.getType(
o)=="monitor"then table.insert(p,o)end end if#p==1 then m=p[1]end end return
m,l end function f.Start(r)g=false local s=term.current()local m,l=j(s)parallel
.waitForAll(r,function()parallel.waitForAny(function()while not g do sleep(
0)end term.setBackgroundColor(colors.black)term.setTextColor(colors.white)term
.clear()term.setCursorPos(1,1)end,function()local t=os.startTimer(0.5)while
true do local u,v,x,y=os.pullEvent()if not l and term.current()~=s then s=term
.current()m,l=j(s)end if u=="mouse_click"and h then h.handleClick(1,x,y)elseif
u=="monitor_touch"and h then if(m and v==m)or(not m and l)then h.handleClick(
1,x,y)end elseif u=="mouse_scroll"and h and h.handleScroll then h.handleScroll(
v,x,y)elseif(u=="char"or u=="key"or u=="paste")and h and h.handleTextEvent then
h.handleTextEvent(u,v)elseif u=="timer"and v==t then if h and h.handleTextEvent
then h.handleTextEvent("blink")end t=os.startTimer(0.5)end end end)end)end function
f.Stop()g=true end return f end function b.views_basic(...)return function(
w)if not w then w={}end local i={}i.active=w.active~=false i.x=w.x or 1 i.y=
w.y or 1 i.backgroundColor=w.backgroundColor or colors.black i.textColor=w.
textColor or colors.white i.draw=nil i.drawInWindow=function(x)local y=term
.current()local z=i.windowParent~=y if z and i.window then i.window.setVisible(
false)i.window=nil end local aa,ab=y.getSize()local ac=i.x+(i.parentOffsetX
or 0)local ad=i.y+(i.parentOffsetY or 0)local ae=ac>aa or ad>ab or ac+i.width
-1<1 or ad+i.height-1<1 if ae then if i.window then i.window.setVisible(false
)end return end if not i.window then i.window=window.create(y,ac,ad,i.width
,i.height)i.windowParent=y else i.window.reposition(ac,ad,i.width,i.height)
end local af=i.window term.redirect(af)af.setVisible(false)af.setBackgroundColor(
i.backgroundColor)af.setTextColor(i.textColor)af.clear()x()af.redraw()af.setVisible(
true)term.redirect(y)end i.redraw=function()if not i.draw or not i.windowParent
then return end local ag=term.current()term.redirect(i.windowParent)i.draw(
)term.redirect(ag)end i.setBackgroundColor=function(ah)i.backgroundColor=ah
end i.setTextColor=function(ah)i.textColor=ah end i.setPos=function(x,y)i.x=
x i.y=y end i.setX=function(x)i.x=x end i.setY=function(y)i.y=y end i.movePos=
function(ai,aj)i.x=i.x+ai i.y=i.y+aj end i.setSize=function(width,height)i.
width=width i.height=height end return i end end function b.views_button(...
)local CreateLabel=require("views.label")return function(w)if not w then w=
{}end local i=CreateLabel(w)i.onClick=w.onClick or function(ak,x,y)end i.handleClick=
function(ak,x,y)if not i.active then return end local al=x>=i.x and x<i.x+i
.width and y>=i.y and y<i.y+i.height if al then i.onClick(ak,x,y)end end return
i end end function b.views_label(...)local CreateBasicView=require("views.basic"
)return function(w)if not w then w={}end local i=CreateBasicView(w)i.text=tostring(
w.text)or""i.width=w.width or#i.text i.height=w.height or 1 i.setText=function(
text)i.text=text end i.draw=function()if not i.active then return end i.drawInWindow(
function()term.setCursorPos(1,1)term.setBackgroundColor(i.backgroundColor)term
.setTextColor(i.textColor)term.write(i.text)end)end return i end end function
b.views_scroll(...)local CreateSection=require("views.section")return function(
w)if not w then w={}end local i=CreateSection(w)i.text=tostring(w.text)or""
i.width=w.width or#i.text i.height=w.height or 1 i.scrollLimit=w.scrollLimit
i.scrollbarBackgroundColor=w.scrollbarBackgroundColor or colors.gray i.scrollbarForegroundColor=
w.scrollbarForegroundColor or colors.lightGray i.scrollPosition=0 local function
ao()local ap=0 for q,aq in ipairs(i.children)do ap=math.max(ap,aq.y+(aq.height
or 1)-1)end return ap end local function ar()local as=math.max(0,ao()-i.height
)if i.scrollLimit then as=math.min(as,math.max(0,i.scrollLimit))end return as
end i.handleScroll=function(at,x,y)if not i.active then return end local au=
x-i.x+1 local av=y-i.y+1 local al=au>=1 and au<=i.width and av>=1 and av<=i
.height if not al then return end local aw=math.max(0,math.min(ar(),i.scrollPosition
+at))if aw~=i.scrollPosition then i.scrollPosition=aw i.redraw()end end i.handleClick=
function(ak,x,y)if not i.active then return end local au=x-i.x+1 local av=y
-i.y+1 if au<1 or au>i.width or av<1 or av>i.height then return end local as=
ar()if au==i.width and as>0 then local aw=math.floor((av-1)/math.max(1,i.height
-1)*as+0.5)if aw~=i.scrollPosition then i.scrollPosition=aw i.redraw()end return
end local ax=av+i.scrollPosition for q,aq in ipairs(i.children)do if aq.handleClick
then aq.handleClick(ak,au,ax)end end end i.draw=function()if not i.active then
return end i.scrollPosition=math.min(i.scrollPosition,ar())i.drawInWindow(function(
)for q,aq in ipairs(i.children)do if aq.draw then aq.parentOffsetY=-i.scrollPosition
aq.draw()end end local as=ar()if as>0 then local ap=ao()local ay=math.max(1
,math.floor(i.height*i.height/ap))local az=math.floor(i.scrollPosition/as*(
i.height-ay))+1 for y=1,i.height do term.setCursorPos(i.width,y)if y>=az and
y<az+ay then term.setBackgroundColor(i.scrollbarForegroundColor)else term.setBackgroundColor(
i.scrollbarBackgroundColor)end term.write(" ")end end end)end return i end end
function b.views_section(...)local CreateBasicView=require("views.basic")return
function(w)if not w then w={}end local i=CreateBasicView(w)i.children={}local
ba,bb=term.getSize()i.width=w.width or ba i.height=w.height or bb i.addChildren=
function(...)local children={...}for q,aq in ipairs(children)do table.insert(
i.children,aq)end end i.removeChild=function(aq)for bc,bd in ipairs(i.children
)do if bd==aq then table.remove(i.children,bc)break end end end i.clear=function(
)i.children={}end i.handleClick=function(ak,x,y)if not i.active then return
end local au=x-i.x+1 local av=y-i.y+1 for q,aq in ipairs(i.children)do if aq
.handleClick then aq.handleClick(ak,au,av)end end end i.handleScroll=function(
at,x,y)if not i.active then return end local au=x-i.x+1 local av=y-i.y+1 for
q,aq in ipairs(i.children)do if aq.handleScroll then aq.handleScroll(at,au,
av)end end end i.handleTextEvent=function(u,be)if not i.active then return end
for q,aq in ipairs(i.children)do if aq.handleTextEvent then aq.handleTextEvent(
u,be)end end end i.draw=function()if not i.active then return end i.drawInWindow(
function()for q,aq in ipairs(i.children)do if aq.draw then aq.draw()end end
end)end return i end end function b.views_textinput(...)local CreateBasicView=
require("views.basic")return function(w)if not w then w={}end local i=CreateBasicView(
w)i.text=w.text==nil and""or tostring(w.text)i.placeholderText=w.placeholderText
==nil and""or tostring(w.placeholderText)i.placeholderTextColor=w.placeholderTextColor
or colors.gray i.width=w.width or math.max(1,#i.text)i.height=w.height or 1
i.maxLength=w.maxLength i.cursorPosition=#i.text+1 i.focused=false i.cursorVisible=
false i.onChange=w.onChange or function(text)end i.onSubmit=w.onSubmit or function(
text)end i.onFocus=w.onFocus or function()end i.onBlur=w.onBlur or function(
)end local function bf()return math.max(1,i.cursorPosition-i.width+1)end local
function redraw()if i.redraw then i.redraw()end end local function bg(text)
if not i.focused or text==""then return end local bh=i.maxLength and i.maxLength
-#i.text or#text if bh<=0 then return end if#text>bh then text=text:sub(1,bh
)end i.text=i.text:sub(1,i.cursorPosition-1)..text..i.text:sub(i.cursorPosition
)i.cursorPosition=i.cursorPosition+#text i.cursorVisible=true i.onChange(i.
text)redraw()end i.setText=function(text)i.text=tostring(text or"")if i.maxLength
then i.text=i.text:sub(1,i.maxLength)end i.cursorPosition=#i.text+1 redraw(
)end i.handleClick=function(ak,x,y)if not i.active then return end local al=
x>=i.x and x<i.x+i.width and y>=i.y and y<i.y+i.height local bi=i.focused i
.focused=al if al then local bj=bf()i.cursorPosition=math.min(#i.text+1,bj+
x-i.x)i.cursorVisible=true if not bi then i.onFocus()end elseif bi then i.cursorVisible=
false i.onBlur()end redraw()end i.handleTextEvent=function(u,be)if not i.active
or not i.focused then return end if u=="char"or u=="paste"then bg(be)elseif
u=="key"then local bk=i.text if be==keys.backspace and i.cursorPosition>1 then
i.text=i.text:sub(1,i.cursorPosition-2)..i.text:sub(i.cursorPosition)i.cursorPosition=
i.cursorPosition-1 elseif be==keys.delete and i.cursorPosition<=#i.text then
i.text=i.text:sub(1,i.cursorPosition-1)..i.text:sub(i.cursorPosition+1)elseif
be==keys.left then i.cursorPosition=math.max(1,i.cursorPosition-1)elseif be
==keys.right then i.cursorPosition=math.min(#i.text+1,i.cursorPosition+1)elseif
be==keys.home then i.cursorPosition=1 elseif be==keys["end"]then i.cursorPosition=
#i.text+1 elseif be==keys.enter then i.onSubmit(i.text)return else return end
i.cursorVisible=true if i.text~=bk then i.onChange(i.text)end redraw()elseif
u=="blink"then i.cursorVisible=not i.cursorVisible redraw()end end i.draw=function(
)if not i.active then return end i.drawInWindow(function()term.setCursorPos(
1,1)local bl=i.text==""local bm=i.text if bl then bm=i.placeholderText end local
bj=bf()bm=bm:sub(bj,bj+i.width-1)if i.focused and i.cursorVisible then local
bn=i.cursorPosition-bj+1 if bn>=1 and bn<=i.width then local bo=bl and i.placeholderTextColor
or i.textColor term.setTextColor(bo)term.write(bm:sub(1,bn-1))term.setTextColor(
i.textColor)term.write("_")term.setTextColor(bo)term.write(bm:sub(bn+1))else
term.setTextColor(bl and i.placeholderTextColor or i.textColor)term.write(bm
)end else term.setTextColor(bl and i.placeholderTextColor or i.textColor)term
.write(bm)end end)end return i end end return b.main(a)