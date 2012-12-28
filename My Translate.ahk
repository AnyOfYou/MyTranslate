#Include CodeXChange.ahk
#Include URLDownloadToVar.ahk
#Include JSON.ahk

Menu,Tray,NoStandard
Menu,Tray,Add,&TranslationSource
Menu,Tray,Add,&ReadWord
Menu,Tray,Add,&RunOnWindowsBoot
Menu,Tray,Add,&HideTrayIcon
Menu,Tray,Add,&About
Menu,Tray,Add,E&xit

;��ȡ�����ļ��������Ƿ���ʾ����ͼ��.
IniRead, HideTrayIcon, %A_ScriptDir%\Config.ini, Others, HideTrayIcon
if (HideTrayIcon != 1)
{
	Menu TRAY,Icon
}
if (HideTrayIcon = 1)
{
	Menu TRAY,NoIcon
}


IniRead,GOOGLE_SOURCE,%A_ScriptDir%\Config.ini,Translation,GOOGLE_SOURCE
IniRead,YOUDAO_SOURCE,%A_ScriptDir%\Config.ini,Translation,YOUDAO_SOURCE

IniRead,TranslationSource,%A_ScriptDir%\Config.ini,Translation,TranslationSource
{
if global TranslationSource = global GOOGLE_SOURCE
{
	Menu,tray,Rename,&TranslationSource,Google &Translation Source
}
if global TranslationSource = global YOUDAO_SOURCE
{
	Menu,tray,Rename,&TranslationSource,YouDao &Translation Source
}
}
;��ȡ�����ļ��������Ƿ�ѡisReadWord
IniRead, isReadWord, %A_ScriptDir%\Config.ini, Translation, isReadWord
if (isReadWord = 1)
{
	Menu, tray, Check,&ReadWord
}

IniRead, k_HotkeyTranslate, %A_ScriptDir%\Config.ini, Hotkeys, TranslateHotkey
IniRead, k_HotkeyCopyResult, %A_ScriptDir%\Config.ini, Hotkeys, CopyResultHotKey



Hotkey, %k_HotkeyTranslate%, Translate
Hotkey, %k_HotkeyCopyResult%, CopyResult
Return


&HideTrayIcon:
MsgBox,��������ͼ��֮����������ʾͼ��,�뵽����Ŀ¼���ҵ�Config.ini,���ı��༭����,��Others�µ�HideTrayIcon��ֵ��Ϊ0����.
iniWrite, 1, %A_ScriptDir%\Config.ini, Others,HideTrayIcon
Reload
Return

&RunOnWindowsBoot:
MsgBox,��������Ϣ��ӵ�ע�����ʵ����Windows����,�����ð�ȫ�����������ò���.
RegWrite,REG_SZ,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Run,%A_SCRIPTNAME%,%A_ScriptFullPath%
if (ErrorLevel =1)
{
	MsgBox,������Ϣ���ʧ��,�Ƿ񱻰�ȫ�����ֹ?
}
else
{
	Msgbox,������Ϣ��ӳɹ�.�Ժ���������������λ��,���������������Ϣ.
}
Return

&About:
Msgbox,һ���ǳ������ķ���ű�.����ʵ�����ܷ���,�Լ��Զ�ʶ���з�Ӣ,Ӣ����.`n��Google������е��ʵ�������Դ.`nSmallG
Return

&ReadWord:
Menu, Tray, ToggleCheck, &ReadWord
if (isReadWord =1)
{
	isReadWord = 0
	iniWrite, 0, %A_ScriptDir%\Config.ini, Translation,isReadWord
}
else
{
	isReadWord = 1
	iniWrite, 1, %A_ScriptDir%\Config.ini, Translation,isReadWord
}
return

&TranslationSource:
{
	if global TranslationSource = global GOOGLE_SOURCE
	{
		Menu,tray,Rename,Google &Translation Source,YouDao &Translation Source
		TranslationSource := global YOUDAO_SOURCE
		iniWrite,%TranslationSource%, %A_ScriptDir%\Config.ini, Translation,TranslationSource
	}
	else if global TranslationSource = global YOUDAO_SOURCE
	{
		Menu,tray,Rename,YouDao &Translation Source,Google &Translation Source
		TranslationSource := global GOOGLE_SOURCE
		iniWrite,%TranslationSource%, %A_ScriptDir%\Config.ini, Translation,TranslationSource
	}
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
	;InputBox����͸��,�����Զ����GUI
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


;���������.
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


;���뷽��.
Translate(word)
{
	global GOOGLE_SOURCE
	global YOUDAO_SOURCE
	global TranslationSource
	;�����ж�����Ϊ���Ļ���Ӣ��,���޸���Ӧ��Url��ַ(Google�ķ��뷽��,�ͷ��������õ�)
	AscClipboard:=Asc(word)


	IfExist,%A_SCRIPTDIR%\tts.mp3
	{
		FileDelete,%A_SCRIPTDIR%\tts.mp3
	}


	;�е�
	if global TranslationSource = global YOUDAO_SOURCE
	{
		KEYFROM=YDTranslateTest
		APIKEY=1826356811

		utf8_word:=Ansi2UTF8(word)
		url_word:=UrlEncode(utf8_word)

		URLDownloadToVar("http://fanyi.youdao.com/openapi.do?keyfrom=" . KEYFROM . "&key=" . APIKEY . "&type=data&doctype=json&version=1.1&q=" . url_word,urldata)
		;MsgBox,% UTF82Ansi(urldata)
		translation := json(urldata, "translation")
		;MsgBox,% UTF82Ansi(translation)
		;basic := json(urldata, "basic")
		;MsgBox,% UTF82Ansi(basic)
		;basic_phonetic := json(urldata, "basic.phonetic")
		;MsgBox,% UTF82Ansi(basic_phonetic)
		;basic_explains := json(urldata, "basic.explains")
		;MsgBox,% UTF82Ansi(basic_explains)
		;query :=json(urldata, "query")
		;MsgBox,% UTF82Ansi(query)
		;web :=json(urldata, "web")
		;MsgBox,% UTF82Ansi(web)

		Result := UTF82Ansi(translation)
		;�Ƴ���������ַ�
		Result := SubStr(Result,3,StrLen(Result)-4)
		ToolTip,% Result
		SetTimer, RemoveToolTip,3000
	}

	;Google
	if global TranslationSource =global GOOGLE_SOURCE
	{
		global Source
		global DownLoadSourceDoneFlag = 0
		global DownLoadSourceTimeOut = 0
		global TheURL
		;�ж��ַ���Ӣ��
		If AscClipboard > 123
		{
			word := Ansi2UTF8(word)
			TheURL = http://translate.google.cn/?hl=en&sl=zh-CN&tl=en&q=%word%
		}
		else
		{
			TheURL = http://translate.google.cn/?hl=en&sl=en&tl=zh-CN&q=%word%
		}
		SetTimer,DownLoadSource
		;ÿ��һ��ʱ��ȥ�ж��Ƿ��������.������һ����ʱ�����Ϊ��ʱ.��û�к����Ĵ���(����UrlDownLoad)
		While DownLoadSourceDoneFlag = 0
		{
			Sleep,100
			;ֻ�����жϳ�ʱ,�����ж��Ƿ����
			SourceWaitTime++
			if SourceWaitTime > 10
			{
				;��ʶ�Ѿ��������
				DownLoadSourceTimeOut = 1
				;�ı��ʶ,����ѭ��
				DownLoadSourceDoneFlag = 1
			}
		}
		;����ֻ��Ҫ�ж��Ƿ�ʱ,��Ϊִ�е�����ͱ���Source�Ѿ����������
		If !DownLoadSourceTimeOut
		{
			;URLDownloadToVar(TheURL,Source)
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
				;��ToolTip��ʾ��ʱ�Ƴ�,����ʾ�����ʱ��?
				SetTimer, RemoveToolTip,3000
			}
			else
			{
				MsgBox,,Error,% Result
			}
		}
	}

	global isReadWord
	if isReadWord = 1
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
		;�ڲ��Ž�������Ƴ�ToolTip,�󲿷�����ȽϺ���,�������ȡ������Ƶ,���ȡ��ʱ��Ƚϳ�?
		;��SoundPlay��û�в����������,��û�а취����ɾ�������ʱ�ļ���
		While DownLoadTTSDoneFlag = 0
		{
			Sleep,100
			TTSWaitTime++
			if TTSWaitTime > 30
			{
				;��ʶ�Ѿ��������
				DownLoadTTSTimeOut = 1
				;�ı��ʶ,����ѭ��
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

;������������ȫ�ֵ�LastResult��
global LastResult := Result
Source =
Result = 
}


DownLoadSource:
SetTimer,DownLoadSource,Off
URLDownloadToVar(TheURL,Source)
DownLoadSourceDoneFlag = 1
;�������Ӳ����ڵ�ʱ���ֱ�ӷ���,������Ҫ�ж�
If Source = 0
{
	DownLoadSourceTimeOut = 1
}
Return

;Ŀǰ�������TTS��ʱ��ʱ��Ƚϳ�,��������,���ǻ��ǻᲥ��,���Կ������ɺ�������ж�Source��ʱһ��ȥ�ж�TTS�ĳ�ʱ,���ڳ�ʱ�������ʾ
DownLoadTTS:
SetTimer,DownLoadTTS,Off
URLDownloadToFile,%SpeechUrl%,%A_SCRIPTDIR%\tts.mp3
DownLoadTTSDoneFlag = 1
;�����Ƿ���Ҫ�ж����ص�tts�ļ���������?
Return


;�Ƴ�ToolTip.
RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return