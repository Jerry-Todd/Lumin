local a={...}local b={}local c=require require=function(d)local e=d:gsub('%.'
,'_')if b[e]then return b[e]()end return c(d)end function b.main(...)local f=
{}local g=false f.CreateBasicView=require("views.basic")f.CreateSection=require(
"views.section")f.CreateScrollSection=require("views.scroll")f.CreateButton=
require("views.button")f.CreateLabel=require("views.label")f.CreateTextInput=
require("views.textinput")local h=nil function f.setMainView(i)h=i end function
f.Start(j)g=false parallel.waitForAll(j,function()parallel.waitForAny(function(
)while not g do sleep(0)end term.setBackgroundColor(colors.black)term.setTextColor(
colors.white)term.clear()term.setCursorPos(1,1)end,function()local k=os.startTimer(
0.5)while true do local l,m,x,y=os.pullEvent()if l=="mouse_click"and h then
h.handleClick(1,x,y)elseif l=="mouse_scroll"and h and h.handleScroll then h
.handleScroll(m,x,y)elseif(l=="char"or l=="key"or l=="paste")and h and h.handleTextEvent
then h.handleTextEvent(l,m)elseif l=="timer"and m==k then if h and h.handleTextEvent
then h.handleTextEvent("blink")end k=os.startTimer(0.5)end end end)end)end function
f.Stop()g=true end return f end function b.views_basic(...)return function(
n)if not n then n={}end local i={}i.active=n.active~=false i.x=n.x or 1 i.y=
n.y or 1 i.backgroundColor=n.backgroundColor or colors.black i.textColor=n.
textColor or colors.white i.draw=nil i.drawInWindow=function(o)local p=term
.current()local q=i.windowParent~=p if q and i.window then i.window.setVisible(
false)i.window=nil end local r,s=p.getSize()local t=i.x+(i.parentOffsetX or
0)local u=i.y+(i.parentOffsetY or 0)local v=t>r or u>s or t+i.width-1<1 or u
+i.height-1<1 if v then if i.window then i.window.setVisible(false)end return
end if not i.window then i.window=window.create(p,t,u,i.width,i.height)i.windowParent=
p else i.window.reposition(t,u,i.width,i.height)end local w=i.window term.redirect(
w)w.setVisible(false)w.setBackgroundColor(i.backgroundColor)w.setTextColor(
i.textColor)w.clear()o()w.redraw()w.setVisible(true)term.redirect(p)end i.redraw=
function()if not i.draw or not i.windowParent then return end local x=term.
current()term.redirect(i.windowParent)i.draw()term.redirect(x)end i.setBackgroundColor=
function(y)i.backgroundColor=y end i.setTextColor=function(y)i.textColor=y end
i.setPos=function(x,y)i.x=x i.y=y end i.setX=function(x)i.x=x end i.setY=function(
y)i.y=y end i.movePos=function(z,aa)i.x=i.x+z i.y=i.y+aa end i.setSize=function(
width,height)i.width=width i.height=height end return i end end function b.
views_button(...)local CreateLabel=require("views.label")return function(n)
if not n then n={}end local i=CreateLabel(n)i.onClick=n.onClick or function(
m,x,y)end i.handleClick=function(m,x,y)if not i.active then return end local
ab=x>=i.x and x<i.x+i.width and y>=i.y and y<i.y+i.height if ab then i.onClick(
m,x,y)end end return i end end function b.views_label(...)local CreateBasicView=
require("views.basic")return function(n)if not n then n={}end local i=CreateBasicView(
n)i.text=tostring(n.text)or""i.width=n.width or#i.text i.height=n.height or
1 i.setText=function(text)i.text=text end i.draw=function()if not i.active then
return end i.drawInWindow(function()term.setCursorPos(1,1)term.setBackgroundColor(
i.backgroundColor)term.setTextColor(i.textColor)term.write(i.text)end)end return
i end end function b.views_scroll(...)local CreateSection=require("views.section"
)return function(n)if not n then n={}end local i=CreateSection(n)i.text=tostring(
n.text)or""i.width=n.width or#i.text i.height=n.height or 1 i.scrollLimit=n
.scrollLimit i.scrollbarBackgroundColor=n.scrollbarBackgroundColor or colors
.gray i.scrollbarForegroundColor=n.scrollbarForegroundColor or colors.lightGray
i.scrollPosition=0 local function ae()local af=0 for ag,ah in ipairs(i.children
)do af=math.max(af,ah.y+(ah.height or 1)-1)end return af end local function
ai()local aj=math.max(0,ae()-i.height)if i.scrollLimit then aj=math.min(aj,
math.max(0,i.scrollLimit))end return aj end i.handleScroll=function(ak,x,y)
if not i.active then return end local al=x-i.x+1 local am=y-i.y+1 local ab=
al>=1 and al<=i.width and am>=1 and am<=i.height if not ab then return end local
an=math.max(0,math.min(ai(),i.scrollPosition+ak))if an~=i.scrollPosition then
i.scrollPosition=an i.redraw()end end i.handleClick=function(m,x,y)if not i
.active then return end local al=x-i.x+1 local am=y-i.y+1 if al<1 or al>i.width
or am<1 or am>i.height then return end local aj=ai()if al==i.width and aj>0
then local an=math.floor((am-1)/math.max(1,i.height-1)*aj+0.5)if an~=i.scrollPosition
then i.scrollPosition=an i.redraw()end return end local ao=am+i.scrollPosition
for ag,ah in ipairs(i.children)do if ah.handleClick then ah.handleClick(m,al
,ao)end end end i.draw=function()if not i.active then return end i.scrollPosition=
math.min(i.scrollPosition,ai())i.drawInWindow(function()for ag,ah in ipairs(
i.children)do if ah.draw then ah.parentOffsetY=-i.scrollPosition ah.draw()end
end local aj=ai()if aj>0 then local af=ae()local ap=math.max(1,math.floor(i
.height*i.height/af))local aq=math.floor(i.scrollPosition/aj*(i.height-ap))
+1 for y=1,i.height do term.setCursorPos(i.width,y)if y>=aq and y<aq+ap then
term.setBackgroundColor(i.scrollbarForegroundColor)else term.setBackgroundColor(
i.scrollbarBackgroundColor)end term.write(" ")end end end)end return i end end
function b.views_section(...)local CreateBasicView=require("views.basic")return
function(n)if not n then n={}end local i=CreateBasicView(n)i.children={}local
ar,as=term.getSize()i.width=n.width or ar i.height=n.height or as i.addChildren=
function(...)local children={...}for ag,ah in ipairs(children)do table.insert(
i.children,ah)end end i.removeChild=function(ah)for at,au in ipairs(i.children
)do if au==ah then table.remove(i.children,at)break end end end i.clear=function(
)i.children={}end i.handleClick=function(m,x,y)if not i.active then return end
local al=x-i.x+1 local am=y-i.y+1 for ag,ah in ipairs(i.children)do if ah.handleClick
then ah.handleClick(m,al,am)end end end i.handleScroll=function(ak,x,y)if not
i.active then return end local al=x-i.x+1 local am=y-i.y+1 for ag,ah in ipairs(
i.children)do if ah.handleScroll then ah.handleScroll(ak,al,am)end end end i
.handleTextEvent=function(l,av)if not i.active then return end for ag,ah in
ipairs(i.children)do if ah.handleTextEvent then ah.handleTextEvent(l,av)end
end end i.draw=function()if not i.active then return end i.drawInWindow(function(
)for ag,ah in ipairs(i.children)do if ah.draw then ah.draw()end end end)end
return i end end function b.views_textinput(...)local CreateBasicView=require(
"views.basic")return function(n)if not n then n={}end local i=CreateBasicView(
n)i.text=n.text==nil and""or tostring(n.text)i.placeholderText=n.placeholderText
==nil and""or tostring(n.placeholderText)i.placeholderTextColor=n.placeholderTextColor
or colors.gray i.width=n.width or math.max(1,#i.text)i.height=n.height or 1
i.maxLength=n.maxLength i.cursorPosition=#i.text+1 i.focused=false i.cursorVisible=
false i.onChange=n.onChange or function(text)end i.onSubmit=n.onSubmit or function(
text)end i.onFocus=n.onFocus or function()end i.onBlur=n.onBlur or function(
)end local function aw()return math.max(1,i.cursorPosition-i.width+1)end local
function redraw()if i.redraw then i.redraw()end end local function ax(text)
if not i.focused or text==""then return end local ay=i.maxLength and i.maxLength
-#i.text or#text if ay<=0 then return end if#text>ay then text=text:sub(1,ay
)end i.text=i.text:sub(1,i.cursorPosition-1)..text..i.text:sub(i.cursorPosition
)i.cursorPosition=i.cursorPosition+#text i.cursorVisible=true i.onChange(i.
text)redraw()end i.setText=function(text)i.text=tostring(text or"")if i.maxLength
then i.text=i.text:sub(1,i.maxLength)end i.cursorPosition=#i.text+1 redraw(
)end i.handleClick=function(m,x,y)if not i.active then return end local ab=
x>=i.x and x<i.x+i.width and y>=i.y and y<i.y+i.height local az=i.focused i
.focused=ab if ab then local ba=aw()i.cursorPosition=math.min(#i.text+1,ba+
x-i.x)i.cursorVisible=true if not az then i.onFocus()end elseif az then i.cursorVisible=
false i.onBlur()end redraw()end i.handleTextEvent=function(l,av)if not i.active
or not i.focused then return end if l=="char"or l=="paste"then ax(av)elseif
l=="key"then local bb=i.text if av==keys.backspace and i.cursorPosition>1 then
i.text=i.text:sub(1,i.cursorPosition-2)..i.text:sub(i.cursorPosition)i.cursorPosition=
i.cursorPosition-1 elseif av==keys.delete and i.cursorPosition<=#i.text then
i.text=i.text:sub(1,i.cursorPosition-1)..i.text:sub(i.cursorPosition+1)elseif
av==keys.left then i.cursorPosition=math.max(1,i.cursorPosition-1)elseif av
==keys.right then i.cursorPosition=math.min(#i.text+1,i.cursorPosition+1)elseif
av==keys.home then i.cursorPosition=1 elseif av==keys["end"]then i.cursorPosition=
#i.text+1 elseif av==keys.enter then i.onSubmit(i.text)return else return end
i.cursorVisible=true if i.text~=bb then i.onChange(i.text)end redraw()elseif
l=="blink"then i.cursorVisible=not i.cursorVisible redraw()end end i.draw=function(
)if not i.active then return end i.drawInWindow(function()term.setCursorPos(
1,1)local bc=i.text==""local bd=i.text if bc then bd=i.placeholderText end local
ba=aw()bd=bd:sub(ba,ba+i.width-1)if i.focused and i.cursorVisible then local
be=i.cursorPosition-ba+1 if be>=1 and be<=i.width then local bf=bc and i.placeholderTextColor
or i.textColor term.setTextColor(bf)term.write(bd:sub(1,be-1))term.setTextColor(
i.textColor)term.write("_")term.setTextColor(bf)term.write(bd:sub(be+1))else
term.setTextColor(bc and i.placeholderTextColor or i.textColor)term.write(bd
)end else term.setTextColor(bc and i.placeholderTextColor or i.textColor)term
.write(bd)end end)end return i end end return b.main(a)