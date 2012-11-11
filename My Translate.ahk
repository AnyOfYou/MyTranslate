Menu, Tray, NoStandard
Menu, Tray, Add,&ReadWord
Menu,Tray,Add,RunOnWindowsBoot
Menu,Tray,Add,HideTrayIcon
Menu,Tray,add,&About
Menu,Tray,Add,E&xit

;读取配置文件来决定是否显示托盘图标.
IniRead, HideTrayIcon, %A_ScriptDir%\Config.ini, Others, HideTrayIcon
if (HideTrayIcon != 1)
{
	Menu TRAY,Icon
}
if (HideTrayIcon = 1)
{
	Menu TRAY,NoIcon
}
;读取配置文件来决定是否勾选isReadWord
IniRead, isReadWord, %A_ScriptDir%\Config.ini, Others, isReadWord
if (isReadWord = 1)
{
	Menu, tray, Check,&ReadWord
}

IniRead, k_HotkeyTranslate, %A_ScriptDir%\Config.ini, Hotkeys, TranslateHotkey
IniRead, k_HotkeyCopyResult, %A_ScriptDir%\Config.ini, Hotkeys, CopyResultHotKey



Hotkey, %k_HotkeyTranslate%, Translate
Hotkey, %k_HotkeyCopyResult%, CopyResult
Return


HideTrayIcon:
MsgBox,隐藏托盘图标之后若想再显示图标,请到程序目录下找到Config.ini,用文本编辑器打开,将Others下的HideTrayIcon的值改为0即可.
iniWrite, 1, %A_ScriptDir%\Config.ini, Others,HideTrayIcon
Reload
Return

RunOnWindowsBoot:
MsgBox,将程序信息添加到注册表以实现随Windows启动,请设置安全防护软件允许该操作.
RegWrite,REG_SZ,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Run,%A_SCRIPTNAME%,%A_ScriptFullPath%
if (ErrorLevel =1)
{
	MsgBox,启动信息添加失败,是否被安全软件阻止?
}
else
{
	Msgbox,启动信息添加成功.以后软件如果被更改了位置,请重新添加启动信息.
}
Return

&About:
Msgbox,一个轻量的翻译脚本.可以实现智能发音,以及自动识别中翻英,英翻中.`n目前在翻译时有小概率随机出现错误的结果,不用理会,确定即可.`nSmallG
Return

&ReadWord:
Menu, Tray, ToggleCheck, &ReadWord
if (isReadWord =1)
{
	isReadWord = 0
	iniWrite, 0, %A_ScriptDir%\Config.ini, Others,isReadWord
}
else
{
	isReadWord = 1
	iniWrite, 1, %A_ScriptDir%\Config.ini, Others,isReadWord
}
return


E&xit:
ExitApp
Return





Translate:
SoundPlay,Nonexistent.wav
IfExist,%A_SCRIPTDIR%\tts.mp3
{
	FileDelete,%A_SCRIPTDIR%\tts.mp3
}
ClipSaved := ClipboardAll
Clipboard =
Send ^c
ClipWait,0.2
If ErrorLevel = 0
{
	IsText := DllCall("IsClipboardFormatAvailable", "UInt", 1, "UInt")
	if IsText
	{
		Translate(Clipboard)
	}
	else
	{
		ToolTip,Is Not Text
		SetTimer, RemoveToolTip,3000
	}
}
else
{
	;InputBox不能透明,改用自定义的GUI
	;InputBox,InputText,Translate,,,200,100
	Gui,Font,s11,Arial
	Gui, Add, Edit, y15 W180 R1 vWord
	Gui,Font
	Gui, Add, Button, DEFAULT W70 X60, OK
	Gui, Show,xCenter yCenter, Translate
	WinSet, Transparent, 150,Translate ahk_class AutoHotkeyGUI
	Return
}
Clipboard := ClipSaved
ClipSaved = 
Return


ButtonOK:
Gui, Submit
Gui, Destroy
If (Word !="")
{
	Translate(Word)
}
Return


;存入剪贴板.
#IfWinNotActive,Warcraft III ahk_class Warcraft III
CopyResult:
if (LastResult <> "")
{
	Clipboard = %LastResult%
	ToolTip,Copy`n%Clipboard%`nDone
	SetTimer, RemoveToolTip,3000
}
else
{
ToolTip,Null
SetTimer, RemoveToolTip,3000
}
Return
#IfWinNotActive


;翻译方法.
Translate(word)
{
IfExist,%A_SCRIPTDIR%\tts.mp3
{
	FileDelete,%A_SCRIPTDIR%\tts.mp3
}
AscClipboard:=Asc(word)
global TheURL
If AscClipboard > 123
	{
		word := encode(word)
		TheURL = http://translate.google.cn/?hl=en&sl=zh-CN&tl=en&q=%word%
	}
	else
	{
		TheURL = http://translate.google.cn/?hl=en&sl=en&tl=zh-CN&q=%word%
	}
global Source
global DownLoadSourceDoneFlag = 0
global DownLoadSourceTimeOut = 0
SetTimer,DownLoadSource
;每隔一段时间去判断是否下载完毕.当到达一定的时间后设为超时.但没有后续的处理(对于UrlDownLoad)
While DownLoadSourceDoneFlag = 0
{
	Sleep,100
	;只可以判断超时,不能判断是否断线
	SourceWaitTime++
	if SourceWaitTime > 10
	{
	;标识已经下载完毕
	DownLoadSourceTimeOut = 1
	;改变标识,跳出循环
	DownLoadSourceDoneFlag = 1
	}
}
;这里只需要判断是否超时,因为执行到这里就表明Source已经下载完成了
If !DownLoadSourceTimeOut
{
;Source := URLDownloadToVar(TheURL)
;MsgBox,%Source%
Str1 = onmouseout="this.style.backgroundColor='#fff'">
FirNum := InStr(Source,Str1,false,0)
;MsgBox % FirNum
Str2 := "</span>"
SecNum := InStr(Source,Str2,false,FirNum)
;MsgBox % SecNum

Result := SubStr(Source, FirNum+StrLen(Str1) ,SecNum-FirNum-StrLen(Str1)) 

;RE = onmouseout="this.style.backgroundColor='#fff'">.*</span></span></div></div><div id=spell-place-holder style="display:none">
;RegExMatch(Source,RE,FoundStr)
;MsgBox,% FoundStr
;Result := SubStr(FoundStr,48,StrLen(FoundStr)-StrLen(RE)+2)
if (StrLen(Result) < 300)
{
ToolTip,% Result
;在ToolTip显示后定时移除,在显示长句的时候?
SetTimer, RemoveToolTip,3000
}
else
{
	MsgBox,,Error,% Result
}

global LastResult := Result

global isReadWord
if isReadWord =1
{
global SpeechUrl
If AscClipboard > 123
{
	SpeechUrl = http://translate.google.cn/translate_tts?ie=UTF-8&q=%Result%&sl=zh-CN&tl=en&total=1&idx=0&textlen=4&prev=input
}
else
{
	SpeechUrl = http://translate.google.cn/translate_tts?ie=UTF-8&q=%word%&sl=zh-CN&tl=en&total=1&idx=0&textlen=4&prev=input
}
;Msgbox,% SpeechUrl
;URLDownloadToFile,%SpeechUrl%,%A_SCRIPTDIR%\tts.mp3
;SoundPlay,%A_SCRIPTDIR%\tts.mp3
global DownLoadTTSDoneFlag = 0
global DownLoadTTSTimeOut = 0
SetTimer,DownLoadTTS
;在播放结束后才移除ToolTip,大部分情况比较合理,但如果获取不到音频,或获取的时间比较长?
;在SoundPlay后没有参数的情况下,是没有办法立即删除这个临时文件的
While DownLoadTTSDoneFlag = 0
{
	Sleep,100
	TTSWaitTime++
	if TTSWaitTime > 30
	{
	;标识已经下载完毕
	DownLoadTTSTimeOut = 1
	;改变标识,跳出循环
	DownLoadTTSDoneFlag = 1
	}
}
If !DownLoadTTSTimeOut
{
	SoundPlay,%A_SCRIPTDIR%\tts.mp3
	;FileDelete,%A_SCRIPTDIR%\tts.mp3
}
else
{
	ToolTip,DownLoad TTS TimeOut
	SetTimer, RemoveToolTip,3000
}
}
}
else
{
	ToolTip,DownLoad Source TimeOut
	SetTimer, RemoveToolTip,3000
}
Source =
Result = 
}

DownLoadSource:
SetTimer,DownLoadSource,Off
Source := URLDownloadToVar(TheURL)
DownLoadSourceDoneFlag = 1
;网络连接不存在的时候会直接返回,所以需要判断
If Source = 0
{
	DownLoadSourceTimeOut = 1
}
Return

;目前如果下载TTS的时候时间比较长,不会阻塞,但是还是会播放,可以考虑做成和上面的判断Source超时一样去判断TTS的超时,并在超时后给予提示
DownLoadTTS:
SetTimer,DownLoadTTS,Off
URLDownloadToFile,%SpeechUrl%,%A_SCRIPTDIR%\tts.mp3
DownLoadTTSDoneFlag = 1
;这里是否需要判断下载的tts文件有无问题?
Return


RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return



Encode(str, enc="UTF-8")
{
   hex := "00", func := "msvcrt\" . (A_IsUnicode ? "swprintf" : "sprintf")
   VarSetCapacity(buff, size:=StrPut(str, enc)), StrPut(str, &buff, enc)
   While (code := NumGet(buff, A_Index - 1, "UChar")) && DllCall(func, "Str", hex, "Str", "%%%02X", "UChar", code, "Cdecl")
   encoded .= hex
   Return encoded
}