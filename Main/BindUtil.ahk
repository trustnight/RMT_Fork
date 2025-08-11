#Requires AutoHotkey v2.0

BindKey() {
    BindPauseHotkey()
    BindShortcut(MySoftData.KillMacroHotkey, OnKillAllMacro)
    BindShortcut(ToolCheckInfo.ToolCheckHotKey, OnToolCheckHotkey)
    BindShortcut(ToolCheckInfo.ToolTextFilterHotKey, OnToolTextFilterScreenShot)
    BindShortcut(ToolCheckInfo.ScreenShotHotKey, OnToolScreenShot)
    BindShortcut(ToolCheckInfo.FreePasteHotKey, OnToolFreePaste)
    BindShortcut(ToolCheckInfo.ToolRecordMacroHotKey, OnHotToolRecordMacro)
    BindScrollHotkey("~WheelUp", OnChangeSrollValue)
    BindScrollHotkey("~WheelDown", OnChangeSrollValue)
    BindScrollHotkey("~+WheelUp", OnChangeSrollValue)
    BindScrollHotkey("~+WheelDown", OnChangeSrollValue)
    BindTabHotKey()
    OnExit(OnExitSoft)
}

BindPauseHotkey() {
    global MySoftData
    if (MySoftData.PauseHotkey != "") {
        key := "$*~" MySoftData.PauseHotkey
        Hotkey(key, OnPauseHotkey, "S")
    }
}

OnPauseHotkey(*) {
    global MySoftData ; 访问全局变量
    MySoftData.IsPause := !MySoftData.IsPause
    MySoftData.PauseToggleCtrl.Value := MySoftData.IsPause
    OnKillAllMacro()
    if (MySoftData.IsPause)
        TraySetIcon("Images\Soft\IcoPause.ico")
    else
        TraySetIcon("Images\Soft\rabit.ico")
    Suspend(MySoftData.IsPause)
}

OnKillAllMacro(*) {
    global MySoftData ; 访问全局变量

    loop MySoftData.TableInfo.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        KillSingleTableMacro(tableItem)
        for index, value in tableItem.ModeArr {
            isWork := tableItem.IsWorkArr[index]
            if (isWork) {
                workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkArr[index])
                MyWorkPool.PostMessage(WM_STOP_MACRO, workPath, 0, 0)
                return
            }
        }
    }

    KillSingleTableMacro(MySoftData.SpecialTableItem)
    SetTimer(TimingChecker, 0)
}

OnToolCheckHotkey(*) {
    global ToolCheckInfo
    ToolCheckInfo.IsToolCheck := !ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck

    if (ToolCheckInfo.IsToolCheck) {
        ToolCheckInfo.MouseInfoTimer := Timer(SetToolCheckInfo, 100)
        ToolCheckInfo.MouseInfoTimer.On()
    }
    else
        ToolCheckInfo.MouseInfoTimer := ""
}

OnToolTextFilterScreenShot(*) {
    if (MySoftData.ScreenShotTypeCtrl.Value == 1) {
        A_Clipboard := ""  ; 清空剪贴板
        Run("ms-screenclip:")
        SetTimer(OnToolTextCheckScreenShot, 500)  ; 每 500 毫秒检查一次剪贴板
    }
    else {
        EnableSelectAerea(OnToolTextFilterGetArea)
    }
}

OnToolScreenShot(*) {
    if (MySoftData.ScreenShotTypeCtrl.Value == 1) {
        Run("ms-screenclip:")
    }
    else {
        EnableSelectAerea(OnToolScreenShotGetArea)
    }
}

OnToolScreenShotGetArea(x1, y1, x2, y2) {
    width := X2 - X1
    height := Y2 - Y1
    pBitmap := Gdip_BitmapFromScreen(X1 "|" Y1 "|" width "|" height)
    Gdip_SetBitmapToClipboard(pBitmap)
    Gdip_DisposeImage(pBitmap)
}

OnToolFreePaste(*) {
    MyFreePasteGui.ShowGui()
}

OnHotToolRecordMacro(isHotkey, *) {
    action := OnToolRecordMacro.Bind(isHotkey)
    SetTimer(action, -1)
}

OnToolRecordMacro(isHotkey, *) {
    global ToolCheckInfo, MySoftData
    spacialKeyArr := ["NumpadEnter"]
    if (isHotkey) {
        LastState := ToolCheckInfo.ToolCheckRecordMacroCtrl.Value
        ToolCheckInfo.ToolCheckRecordMacroCtrl.Value := !LastState
    }

    if (MySoftData.MacroEditGui != "") {
        MySoftData.RecordToggleCon.Value := ToolCheckInfo.IsToolRecord
    }
    state := ToolCheckInfo.ToolCheckRecordMacroCtrl.Value
    if (state) {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        ToolCheckInfo.RecordMacroStr := ""
        ToolCheckInfo.RecordLastTime := GetCurMSec()
        ToolCheckInfo.RecordLastMousePos := [mouseX, mouseY]

        if (ToolCheckInfo.RecordJoyValue)
            SetTimer(RecordJoy, -1)

        SetTimer(RecordMouseTrail, -1)
    }

    StateSymbol := state ? "On" : "Off"
    loop 255 {
        key := Format("$*~vk{:X}", A_Index)
        if (ToolCheckInfo.RecordSpecialKeyMap.Has(A_Index)) {
            keyName := GetKeyName(Format("vk{:X}", A_Index))
            key := Format("$*~sc{:X}", GetKeySC(keyName))
        }

        try {
            Hotkey(key, OnRecordMacroKeyDown, StateSymbol)
            Hotkey(key " Up", OnRecordMacroKeyUp, StateSymbol)
        }
        catch {
            continue
        }
    }

    loop spacialKeyArr.Length {
        key := Format("$*~sc{:X}", GetKeySC(spacialKeyArr[A_Index]))
        Hotkey(key, OnRecordMacroKeyDown, StateSymbol)
        Hotkey(key " Up", OnRecordMacroKeyUp, StateSymbol)
    }

    if (!state) {
        OnFinishRecordMacro()
    }
}

RecordMouseTrail() {
    loop {
        if (!ToolCheckInfo.ToolCheckRecordMacroCtrl.Value)
            return
        IsTrail := true
        span := GetCurMSec() - ToolCheckInfo.RecordLastTime
        if (ToolCheckInfo.RecordMouseValue && IsTrail) {
            CoordMode("Mouse", "Screen")
            MouseGetPos &mouseX, &mouseY
            if (ToolCheckInfo.RecordLastMousePos[1] != mouseX || ToolCheckInfo.RecordLastMousePos[2] != mouseY) {   ;鼠标位置发生改变
                len := Abs(ToolCheckInfo.RecordLastMousePos[1] - mouseX)
                len += Abs(ToolCheckInfo.RecordLastMousePos[2] - mouseY)
                if (len <= 10) {
                    Sleep(200)
                    continue
                }

                speed := 93
                IsRelative := ToolCheckInfo.RecordMouseRelativeValue
                symbol := IsRelative ? "_" speed "_1" : "_" speed
                targetX := mouseX
                targetY := mouseY
                if (IsRelative) {   ;相对位移，坐标变化
                    targetX := mouseX - ToolCheckInfo.RecordLastMousePos[1]
                    targetY := mouseY - ToolCheckInfo.RecordLastMousePos[2]
                }
                ToolCheckInfo.RecordMacroStr .= "移动_" targetX "_" targetY symbol ","
                ToolCheckInfo.RecordLastMousePos := [mouseX, mouseY]
            }
        }
        Sleep(200)
    }

}
OnRecordMacroKeyDown(*) {

    key := StrReplace(A_ThisHotkey, "$", "")
    key := StrReplace(key, "*~", "")
    keyName := GetKeyName(key)
    OnRecordAddMacroStr(keyName, true)
}

OnRecordMacroKeyUp(*) {
    key := StrReplace(A_ThisHotkey, "$", "")
    key := StrReplace(key, "*~", "")
    key := StrReplace(key, " Up", "")
    keyName := GetKeyName(key)
    OnRecordAddMacroStr(keyName, false)
}

OnRecordAddMacroStr(keyName, isDown) {
    span := GetCurMSec() - ToolCheckInfo.RecordLastTime
    keySymbol := isDown ? 1 : 2
    ToolCheckInfo.RecordLastTime := GetCurMSec()
    IsMouse := keyName == "LButton" || keyName == "RButton" || keyName == "MButton"

    if (IsMouse && ToolCheckInfo.RecordMouseValue) {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        if (ToolCheckInfo.RecordLastMousePos[1] != mouseX || ToolCheckInfo.RecordLastMousePos[2] != mouseY) {   ;鼠标位置发生改变
            speed := Max(100 - Integer(span * 0.02), 90)
            IsRelative := ToolCheckInfo.RecordMouseRelativeValue
            symbol := IsRelative ? "_" speed "_1" : "_" speed
            targetX := mouseX
            targetY := mouseY
            if (IsRelative) {   ;相对位移，坐标变化
                targetX := mouseX - ToolCheckInfo.RecordLastMousePos[1]
                targetY := mouseY - ToolCheckInfo.RecordLastMousePos[2]
            }
            ToolCheckInfo.RecordMacroStr .= "移动_" targetX "_" targetY symbol ","
            ToolCheckInfo.RecordLastMousePos := [mouseX, mouseY]
        }
    }

    ToolCheckInfo.RecordMacroStr .= "间隔_" span ","
    ToolCheckInfo.RecordMacroStr .= "按键_" keyName "_" keySymbol ","
}

OnFinishRecordMacro() {
    macro := Trim(ToolCheckInfo.RecordMacroStr, ",")
    if (MySoftData.MacroEditGui != "") {
        MySoftData.MacroEditCon.Value .= macro
    }
    ToolCheckInfo.ToolTextCtrl.Value := macro
    A_Clipboard := macro
}

OnChangeSrollValue(*) {
    wParam := InStr(A_ThisHotkey, "Down") ? 1 : 0
    lParam := 0
    msg := GetKeyState("Shift") ? 0x114 : 0x115
    MySoftData.SB.ScrollMsg(wParam, lParam, msg, MySoftData.MyGui.Hwnd)
}

;绑定热键
OnExitSoft(*) {
    global MyPToken, MyChineseOcr
    Gdip_Shutdown(MyPToken)
    MyChineseOcr := ""
    MyEnglishOcr := ""
    MyWorkPool.Clear()
}

BindTabHotKey() {
    tableIndex := 0
    loop MySoftData.TabNameArr.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        tableIndex := A_Index
        for index, value in tableItem.ModeArr {
            if (tableItem.TKArr.Length < index || tableItem.TKArr[index] == "" || (Integer)(tableItem.ForbidArr[index]))
                continue

            if (tableItem.MacroArr.Length < index || tableItem.MacroArr[index] == "")
                continue

            key := "$*" tableItem.TKArr[index]
            actionArr := GetMacroAction(tableIndex, index)
            isJoyKey := RegExMatch(tableItem.TKArr[index], "Joy")
            isHotstring := SubStr(tableItem.TKArr[index], 1, 1) == ":"
            curProcessName := tableItem.ProcessNameArr.Length >= index ? tableItem.ProcessNameArr[index] : ""

            if (curProcessName != "") {
                processInfo := Format("ahk_exe {}", curProcessName)
                HotIfWinActive(processInfo)
            }

            if (isJoyKey) {
                MyJoyMacro.AddMacro(tableItem.TKArr[index], actionArr[1], curProcessName)
            }
            else if (isHotstring) {
                Hotstring(tableItem.TKArr[index], actionArr[1])
            }
            else {
                if (actionArr[1] != "")
                    Hotkey(key, actionArr[1])

                if (actionArr[2] != "")
                    Hotkey(key " up", actionArr[2])
            }

            if (curProcessName != "") {
                HotIfWinActive
            }
        }
    }
}

GetMacroAction(tableIndex, index) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[index]
    tableSymbol := GetTableSymbol(tableIndex)
    actionDown := ""
    actionUp := ""

    if (tableSymbol == "Normal") {
        actionDown := GetClosureActionNew(tableIndex, index, OnTriggerKeyDown)
        actionUp := GetClosureActionNew(tableIndex, index, OnTriggerKeyUp)
    }
    else if (tableSymbol == "String") {
        actionDown := GetClosureActionNew(tableIndex, index, TriggerMacroHandler)
    }
    else if (tableSymbol == "Replace") {
        actionDown := GetClosureAction(tableItem, macro, index, OnReplaceDownKey)
        actionUp := GetClosureAction(tableItem, macro, index, OnReplaceUpKey)
    }
    return [actionDown, actionUp]
}

OnTriggerKeyDown(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]

    if (tableItem.TriggerTypeArr[itemIndex] == 1) { ;按下触发
        if (SubStr(tableItem.TKArr[itemIndex], 1, 1) != "~")
            LoosenModifyKey(tableItem.TKArr[itemIndex])
        TriggerMacroHandler(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 3) { ;松开停止
        TriggerMacroHandler(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 4) {  ;开关
        if (tableItem.IsWorkArr[itemIndex]) {       ;关闭开关
            MySubMacroStopAction(tableIndex, itemIndex)
            return
        }
        OnToggleTriggerMacro(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 5) {    ;长按
        Sleep(tableItem.HoldTimeArr[itemIndex])

        keyCombo := LTrim(tableItem.TKArr[itemIndex], "~")
        if (AreKeysPressed(keyCombo))
            TriggerMacroHandler(tableIndex, itemIndex)
    }
}

;松开停止
OnTriggerKeyUp(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    isWork := tableItem.IsWorkArr[itemIndex]
    if (tableItem.TriggerTypeArr[itemIndex] == 2 && !isWork) { ;松开触发
        TriggerMacroHandler(tableIndex, itemIndex)
    }
    else if (tableItem.TriggerTypeArr[itemIndex] == 3) {  ;松开停止
        if (isWork) {
            workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkArr[itemIndex])
            MyWorkPool.PostMessage(WM_STOP_MACRO, workPath, 0, 0)
            return
        }

        KillTableItemMacro(tableItem, itemIndex)
    }
}

OnToggleTriggerMacro(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]
    hasWork := MyWorkPool.CheckHasWork()

    if (hasWork) {
        workPath := MyWorkPool.Get()
        workIndex := MyWorkPool.GetWorkIndex(workPath)
        tableItem.IsWorkArr[itemIndex] := workIndex
        MyWorkPool.PostMessage(WM_TR_MACRO, workPath, tableIndex, itemIndex)
        return
    }

    isTrigger := tableItem.ToggleStateArr[itemIndex]
    if (!isTrigger) {
        tableItem.ToggleStateArr[itemIndex] := true
        action := OnTriggerMacroKeyAndInit.Bind(tableItem, macro, itemIndex)
        tableItem.ToggleActionArr[itemIndex] := action
        SetTimer(action, -1)
    }
    else {
        action := tableItem.ToggleActionArr[itemIndex]
        if (action == "")
            return

        KillTableItemMacro(tableItem, itemIndex)
        SetTimer(action, 0)
    }
}

TriggerMacroHandler(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]
    isWork := tableItem.IsWorkArr[itemIndex]
    hasWork := MyWorkPool.CheckHasWork()
    if (isWork)
        return

    if (hasWork) {
        workPath := MyWorkPool.Get()
        workIndex := MyWorkPool.GetWorkIndex(workPath)
        tableItem.IsWorkArr[itemIndex] := workIndex
        MyWorkPool.PostMessage(WM_TR_MACRO, workPath, tableIndex, itemIndex)
    }
    else {
        OnTriggerMacroKeyAndInit(tableItem, macro, itemIndex)
    }
}
