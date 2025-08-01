#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Joy\SuperCvJoyInterface.ahk
#Include Joy\JoyMacro.ahk
#Include Plugins\RapidOcr\RapidOcr.ahk
#Include Plugins\WinClipAPI.ahk
#Include Plugins\WinClip.ahk
#Include Gui\TriggerKeyGui.ahk
#Include Gui\TriggerStrGui.ahk
#Include Gui\SettingMgrGui.ahk
#Include Gui\EditHotkeyGui.ahk
#Include Gui\FreePasteGui.ahk
#Include Gui\MacroEditGui.ahk
#Include Gui\ReplaceKeyGui.ahk
#Include Gui\ScrollBar.ahk
#Include Main\Gdip_All.ahk
#Include Main\DataClass.ahk
#Include Main\AssetUtil.ahk
#Include Main\RecordJoyUtil.ahk
#Include Main\HotkeyUtil.ahk
#Include Main\RMTUtil.ahk
#Include Main\WorkPool.ahk
#Include Main\UIUtil.ahk
#Include Main\JsonUtil.ahk
#Include Main\CompareUtil.ahk
SetWorkingDir A_ScriptDir
DetectHiddenWindows true
Persistent

global MySoftData := SoftData()
global IniFile := A_WorkingDir "\Setting\MainSettings.ini"
global ToolCheckInfo := ToolCheck()
global MyvJoy := SuperCvJoyInterface().GetMyvJoy()
global MyJoyMacro := JoyMacro()
global MyWinClip := WinClip()
global MyTriggerKeyGui := TriggerKeyGui()
global MyTriggerStrGui := TriggerStrGui()
global MyEditHotkeyGui := EditHotkeyGui()
global MyMacroGui := MacroEditGui()
global MyReplaceKeyGui := ReplaceKeyGui()
global MyFreePasteGui := FreePasteGui()
global MySettingMgrGui := SettingMgrGui()
global MySubMacroStopAction := SubMacroStopAction
global MyTriggerSubMacro := TriggerSubMacro
global MySetGlobalVariable := SetGlobalVariable
global MyDelGlobalVariable := DelGlobalVariable
    
LoadMainSetting()       ;加载配置
InitFilePath()          ;初始化文件路径
LoadCurMacroSetting()   ;加载当前配置宏
EditListen()        ;右键编辑数据监听
InitData()          ;初始化软件数据
InitUI()            ;初始化UI
BindSave()          ;绑定保存方法
BindKey()           ;绑定快捷键

;放后面初始化，因为这初始化时间比较长
global MyWorkPool := WorkPool()
global MyChineseOcr := RapidOcr(A_ScriptDir)
global MyEnglishOcr := RapidOcr(A_ScriptDir, 2)
global MyPToken := Gdip_Startup()
OpenCVLoadDll()