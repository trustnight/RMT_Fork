#Requires AutoHotkey v2.0

;资源保存
OnSaveSetting(*) {
    global MySoftData
    MyWorkPool.Clear()
    loop MySoftData.TabNameArr.Length {
        SaveTableItemInfo(A_Index)
    }

    IniWrite(MySoftData.HoldFloatCtrl.Value, IniFile, IniSection, "HoldFloat")
    IniWrite(MySoftData.PreIntervalFloatCtrl.Value, IniFile, IniSection, "PreIntervalFloat")
    IniWrite(MySoftData.IntervalFloatCtrl.Value, IniFile, IniSection, "IntervalFloat")
    IniWrite(MySoftData.CoordXFloatCon.Value, IniFile, IniSection, "CoordXFloat")
    IniWrite(MySoftData.CoordYFloatCon.Value, IniFile, IniSection, "CoordYFloat")
    IniWrite(MySoftData.PauseHotkeyCtrl.Value, IniFile, IniSection, "PauseHotkey")
    IniWrite(MySoftData.KillMacroHotkeyCtrl.Value, IniFile, IniSection, "KillMacroHotkey")
    IniWrite(true, IniFile, IniSection, "LastSaved")
    IniWrite(MySoftData.ShowWinCtrl.Value, IniFile, IniSection, "IsExecuteShow")
    IniWrite(MySoftData.BootStartCtrl.Value, IniFile, IniSection, "IsBootStart")
    IniWrite(MySoftData.MutiThreadNumCtrl.Value, IniFile, IniSection, "MutiThreadNum")
    IniWrite(MySoftData.NoVariableTipCtrl.Value, IniFile, IniSection, "NoVariableTip")
    IniWrite(MySoftData.CMDTipCtrl.Value, IniFile, IniSection, "CMDTip")
    IniWrite(MySoftData.ScreenShotTypeCtrl.Value, IniFile, IniSection, "ScreenShotType")
    IniWrite(ToolCheckInfo.ToolCheckHotKeyCtrl.Value, IniFile, IniSection, "ToolCheckHotKey")
    IniWrite(ToolCheckInfo.ToolRecordMacroHotKeyCtrl.Value, IniFile, IniSection, "RecordMacroHotKey")
    IniWrite(ToolCheckInfo.ToolTextFilterHotKeyCtrl.Value, IniFile, IniSection, "ToolTextFilterHotKey")
    IniWrite(ToolCheckInfo.ScreenShotHotKeyCtrl.Value, IniFile, IniSection, "ScreenShotHotKey")
    IniWrite(ToolCheckInfo.FreePasteHotKeyCtrl.Value, IniFile, IniSection, "FreePasteHotKey")
    IniWrite(ToolCheckInfo.RecordKeyboardCtrl.Value, IniFile, IniSection, "RecordKeyboardValue")
    IniWrite(ToolCheckInfo.RecordMouseCtrl.Value, IniFile, IniSection, "RecordMouseValue")
    IniWrite(ToolCheckInfo.RecordJoyCtrl.Value, IniFile, IniSection, "RecordJoyValue")
    IniWrite(ToolCheckInfo.RecordMouseRelativeCtrl.Value, IniFile, IniSection, "RecordMouseRelativeValue")
    IniWrite(ToolCheckInfo.OCRTypeCtrl.Value, IniFile, IniSection, "OCRType")
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")
    IniWrite(MySoftData.FontTypeCtrl.Text, IniFile, IniSection, "FontType")
    IniWrite(true, IniFile, IniSection, "HasSaved")

    MySoftData.CMDPosX := IniWrite(MySoftData.CMDPosX, IniFile, IniSection, "CMDPosX")
    MySoftData.CMDPosY := IniWrite(MySoftData.CMDPosY, IniFile, IniSection, "CMDPosY")
    MySoftData.CMDWidth := IniWrite(MySoftData.CMDWidth, IniFile, IniSection, "CMDWidth")
    MySoftData.CMDHeight := IniWrite(MySoftData.CMDHeight, IniFile, IniSection, "CMDHeight")
    MySoftData.CMDLineNum := IniWrite(MySoftData.CMDLineNum, IniFile, IniSection, "CMDLineNum")
    MySoftData.CMDBGColor := IniWrite(MySoftData.CMDBGColor, IniFile, IniSection, "CMDBGColor")
    MySoftData.CMDTransparency := IniWrite(MySoftData.CMDTransparency, IniFile, IniSection, "CMDTransparency")
    MySoftData.CMDFontColor := IniWrite(MySoftData.CMDFontColor, IniFile, IniSection, "CMDFontColor")
    MySoftData.CMDFontSize := IniWrite(MySoftData.CMDFontSize, IniFile, IniSection, "CMDFontSize")

    SaveWinPos()
    Reload()
}

OnTableDelete(tableItem, index) {
    if (tableItem.ModeArr.Length == 0) {
        return
    }
    result := MsgBox("是否删除当前宏", "提示", 1)
    if (result == "Cancel")
        return

    deleteMacro := tableItem.MacroArr.Length >= index ? tableItem.MacroArr[index] : ""

    MySoftData.BtnAdd.Enabled := false
    tableItem.ModeArr.RemoveAt(index)
    tableItem.ForbidArr.RemoveAt(index)
    tableItem.HoldTimeArr.RemoveAt(index)
    if (tableItem.TKArr.Length >= index)
        tableItem.TKArr.RemoveAt(index)
    if (tableItem.MacroArr.Length >= index)
        tableItem.MacroArr.RemoveAt(index)
    if (tableItem.ProcessNameArr.Length >= index)
        tableItem.ProcessNameArr.RemoveAt(index)
    if (tableItem.LoopCountArr.Length >= index)
        tableItem.LoopCountArr.RemoveAt(index)
    if (tableItem.RemarkArr.Length >= index)
        tableItem.RemarkArr.RemoveAt(index)
    if (tableItem.SerialArr.Length >= index)
        tableItem.SerialArr.RemoveAt(index)
    if (tableItem.TimingSerialArr.Length >= index)
        tableItem.TimingSerialArr.RemoveAt(index)
    tableItem.IndexConArr.RemoveAt(index)
    tableItem.TriggerTypeConArr.RemoveAt(index)
    tableItem.ModeConArr.RemoveAt(index)
    tableItem.ForbidConArr.RemoveAt(index)
    tableItem.TKConArr.RemoveAt(index)
    tableItem.InfoConArr.RemoveAt(index)
    tableItem.ProcessNameConArr.RemoveAt(index)
    tableItem.LoopCountConArr.RemoveAt(index)
    tableItem.RemarkConArr.RemoveAt(index)

    OnSaveSetting()
}

OnTableEditMacro(tableItem, index) {
    macro := tableItem.InfoConArr[index].Value
    MyMacroGui.SureBtnAction := (sureMacro) => tableItem.InfoConArr[index].Value := sureMacro
    MyMacroGui.ShowGui(macro, true)
}

OnTableEditReplaceKey(tableItem, index) {
    replaceKey := tableItem.InfoConArr[index].Value
    MyReplaceKeyGui.SureBtnAction := (sureReplaceKey) => tableItem.InfoConArr[index].Value := sureReplaceKey
    MyReplaceKeyGui.ShowGui(replaceKey)
}

OnTableEditTriggerKey(tableItem, index) {
    triggerKey := tableItem.TKConArr[index].Value
    MyTriggerKeyGui.SureBtnAction := (sureTriggerKey) => tableItem.TKConArr[index].Value := sureTriggerKey
    args := TriggerKeyGuiArgs()
    args.IsToolEdit := false
    args.tableItem := tableItem
    args.tableIndex := index
    MyTriggerKeyGui.ShowGui(triggerKey, args)
}

OnTableEditTiming(tableItem, index) {
    SerialStr := tableItem.TimingSerialArr[index]
    MyTimingGui.ShowGui(SerialStr)
}

OnTableEditTriggerStr(tableItem, index) {
    triggerStr := tableItem.TKConArr[index].Value
    MyTriggerStrGui.SureBtnAction := (sureTriggerStr) => tableItem.TKConArr[index].Value := sureTriggerStr
    MyTriggerStrGui.ShowGui(triggerStr, true)
}

OnEditCMDTipGui() {
    MyCMDTipSettingGui.ShowGui()
}

OnTableMoveUp(tableItem, index, *) {
    if (index == 1) {
        MsgBox("上面有元素吗，你就上移动！！！")
        return
    }
    SwapTableContent(tableItem, index, index - 1)
}

OnTableMoveDown(tableItem, index, *) {
    lastIndex := tableItem.ModeArr.length
    if (lastIndex == index) {
        MsgBox("下面有元素吗，你就下移！！！")
        return
    }
    SwapTableContent(tableItem, index, index + 1)
}

SwapTableContent(tableItem, indexA, indexB) {
    SwapArrValue(tableItem.ModeConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.ForbidConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.HoldTimeArr, indexA, indexB)
    SwapArrValue(tableItem.TKConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.InfoConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.TriggerTypeConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.SerialArr, indexA, indexB)
    SwapArrValue(tableItem.LoopCountConArr, indexA, indexB, 3)
    SwapArrValue(tableItem.RemarkConArr, indexA, indexB, 2)
}

SwapArrValue(Arr, indexA, indexB, valueType := 1) {
    if (valueType == 3) {
        temp := Arr[indexA].Text
        Arr[indexA].Text := Arr[indexB].Text
        Arr[indexB].Text := temp
    }
    else if (valueType == 2) {
        temp := Arr[indexA].Value
        Arr[indexA].Value := Arr[indexB].Value
        Arr[indexB].Value := temp
    }
    else {
        temp := Arr[indexA]
        Arr[indexA] := Arr[indexB]
        Arr[indexB] := temp
    }
}

ResetWinPosAndRefreshGui(*) {
    IniWrite(false, IniFile, IniSection, "IsSavedWinPos")
    MySoftData.IsSavedWinPos := false
    RefreshGui()
}

BindSave() {
    MyTriggerKeyGui.SaveBtnAction := OnSaveSetting
    MyTriggerStrGui.SaveBtnAction := OnSaveSetting
    MyMacroGui.SaveBtnAction := OnSaveSetting
}

OnToolAlwaysOnTop(*) {
    global MySoftData, ToolCheckInfo
    state := ToolCheckInfo.AlwaysOnTopCtrl.Value
    if (state) {
        MySoftData.MyGui.Opt("+AlwaysOnTop")
    }
    else {
        MySoftData.MyGui.Opt("-AlwaysOnTop")
    }
}

InitFilePath() {
    if (!DirExist(A_WorkingDir "\Setting")) {
        DirCreate(A_WorkingDir "\Setting")
    }
    if (!DirExist(A_WorkingDir "\Setting\" MySoftData.CurSettingName)) {
        DirCreate(A_WorkingDir "\Setting\" MySoftData.CurSettingName)
    }

    if (!DirExist(A_WorkingDir "\Setting\" MySoftData.CurSettingName "\Images\ScreenShot")) {
        DirCreate(A_WorkingDir "\Setting\" MySoftData.CurSettingName "\Images\ScreenShot")
    }

    if (!DirExist(A_WorkingDir "\Images")) {
        DirCreate(A_WorkingDir "\Images")
    }
    if (!DirExist(A_WorkingDir "\Images\Soft")) {
        DirCreate(A_WorkingDir "\Images\Soft")
    }

    if (!DirExist(A_WorkingDir "\Images\ScreenShot")) {
        DirCreate(A_WorkingDir "\Images\ScreenShot")
    }

    if (!DirExist(A_WorkingDir "\Images\FreePaste")) {
        DirCreate(A_WorkingDir "\Images\FreePaste")
    }

    FileInstall("Images\Soft\WeiXin.png", "Images\Soft\WeiXin.png", 1)
    FileInstall("Images\Soft\ZhiFuBao.png", "Images\Soft\ZhiFuBao.png", 1)
    FileInstall("Images\Soft\rabit.ico", "Images\Soft\rabit.ico", 1)
    FileInstall("Images\Soft\IcoPause.ico", "Images\Soft\IcoPause.ico", 1)

    global VBSPath := A_WorkingDir "\VBS\PlayAudio.vbs"
    global MacroFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\MacroFile.ini"
    global SearchFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\SearchFile.ini"
    global SearchProFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\SearchProFile.ini"
    global CompareFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\CompareFile.ini"
    global MMProFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\MMProFile.ini"
    global TimingFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\TimingFile.ini"
    global FileFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\FileFile.ini"
    global OutputFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\OutputFile.ini"
    global StopFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\StopFile.ini"
    global VariableFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\VariableFile.ini"
    global ExVariableFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\ExVariableFile.ini"
    global SubMacroFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\SubMacroFile.ini"
    global OperationFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\OperationFile.ini"
    global BGMouseFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\BGMouseFile.ini"
}

SubMacroStopAction(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkArr[itemIndex])
    tableItem.IsWorkArr[itemIndex] := false
    MyWorkPool.PostMessage(WM_STOP_MACRO, workPath, 0, 0)
}

TriggerSubMacro(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]
    hasWork := MyWorkPool.CheckHasWork()

    if (hasWork) {
        workPath := MyWorkPool.Get()
        workIndex := MyWorkPool.GetWorkIndex(workPath)
        tableItem.IsWorkArr[itemIndex] := workIndex
        MyWorkPool.PostMessage(WM_TR_MACRO, workPath, tableIndex, itemIndex)
    }
    else {
        action := OnTriggerMacroKeyAndInit.Bind(tableItem, macro, itemIndex)
        SetTimer(action, -1)
    }
}

SetGlobalVariable(Name, Value, ignoreExist) {
    global MySoftData
    if (ignoreExist && MySoftData.VariableMap.Has(Name))
        return
    MySoftData.VariableMap[Name] := Value
    hasWork := MyWorkPool.CheckHasWork()
    if (hasWork) {
        loop MyWorkPool.maxSize {
            workPath := A_ScriptDir "\Thread\Work" A_Index ".exe"
            str := Format("SetVari_{}_{}", Name, Value)
            MyWorkPool.SendMessage(WM_COPYDATA, workPath, str)
        }
    }
}

DelGlobalVariable(Name) {
    global MySoftData
    if (MySoftData.VariableMap.Has(Name))
        MySoftData.VariableMap.Delete(Name)
    hasWork := MyWorkPool.CheckHasWork()
    if (hasWork) {
        loop MyWorkPool.maxSize {
            workPath := A_ScriptDir "\Thread\Work" A_Index ".exe"
            str := Format("DelVari_{}", Name)
            MyWorkPool.PostMessage(WM_COPYDATA, workPath, str)
        }
    }
}

CMDReport(CMDStr) {
    MyCMDTipGui.ShowGui(CMDStr)
}

ExcuteRMTCMDAction(cmdStr) {
    if (cmdStr == "截图") {
        OnToolScreenShot()
    }
    else if (cmdStr == "截图提取文本") {
        OnToolTextFilterScreenShot()
    }
    else if (cmdStr == "自由贴") {
        OnToolFreePaste()
    }
    else if (cmdStr == "关闭指令显示窗口") {
        MyCMDTipGui.Gui.Hide()
    }
    else if (cmdStr == "切换指令显示开关") {
        MySoftData.CMDTipCtrl.Value := !MySoftData.CMDTipCtrl.Value
        MySoftData.CMDTip := MySoftData.CMDTipCtrl.Value
        if (!MySoftData.CMDTipCtrl.Value) {
            style := WinGetStyle(MyCMDTipGui.Gui.Hwnd)
            isVisible := (style & 0x10000000)  ; 0x10000000 = WS_VISIBLE
            if (isVisible)
                MyCMDTipGui.Gui.Hide()
        }
    }
    else if (cmdStr == "全局暂停") {
        OnPauseHotkey()
    }
    else if (cmdStr == "终止所有宏") {
        OnKillAllMacro()
    }
    else if (cmdStr == "重载") {
        MenuReload()
    }
}

ScreenShot(X1, Y1, X2, Y2, FileName) {
    width := X2 - X1
    height := Y2 - Y1
    pBitmap := Gdip_BitmapFromScreen(X1 "|" Y1 "|" width "|" height)
    Gdip_SaveBitmapToFile(pBitmap, FileName)
    ; 释放位图资源
    Gdip_DisposeImage(pBitmap)
}

OnToolTextFilterGetArea(x1, y1, x2, y2) {
    filePath := A_WorkingDir "\Images\ScreenShot\TextFilter.png"
    ScreenShot(x1, y1, x2, y2, filePath)
    ocr := ToolCheckInfo.OCRTypeCtrl.Value == 1 ? MyChineseOcr : MyEnglishOcr
    param := RapidOcr.OcrParam()
    param.boxScoreThresh := 0.4  ; 降低置信度阈值，保留更多候选框
    result := ocr.ocr_from_file(filePath, param)
    ToolCheckInfo.ToolTextCtrl.Value := result
    A_Clipboard := result
}

OnToolTextCheckScreenShot() {
    ; 如果剪贴板中有图像
    if DllCall("IsClipboardFormatAvailable", "uint", 8)  ; 8 是 CF_BITMAP 格式
    {
        filePath := A_WorkingDir "\Images\ScreenShot\TextFilter.png"
        SaveClipToBitmap(filePath)
        ocr := ToolCheckInfo.OCRTypeCtrl.Value == 1 ? MyChineseOcr : MyEnglishOcr
        param := RapidOcr.OcrParam()
        param.boxScoreThresh := 0.4  ; 降低置信度阈值，保留更多候选框
        result := ocr.ocr_from_file(filePath, param)
        ToolCheckInfo.ToolTextCtrl.Value := result
        A_Clipboard := result
        ; 停止监听
        SetTimer(, 0)
    }
}

EnableSelectAerea(action) {
    Hotkey("LButton", (*) => SelectArea(action), "On")
    Hotkey("LButton Up", (*) => DisSelectArea(action), "On")
}

DisSelectArea(action) {
    Hotkey("LButton", (*) => SelectArea(action), "Off")
    Hotkey("LButton Up", (*) => DisSelectArea(action), "Off")
}

SelectArea(action) {
    ; 获取起始点坐标
    startX := startY := endX := endY := 0
    CoordMode("Mouse", "Screen")
    MouseGetPos(&startX, &startY)

    ; 创建 GUI 用于绘制矩形框
    MyGui := Gui("+ToolWindow -Caption +AlwaysOnTop -DPIScale")
    MyGui.BackColor := "Red"
    WinSetTransColor(" 150", MyGui)
    MyGui.Opt("+LastFound")
    GuiHwnd := WinExist()

    ; 显示初始 GUI
    MyGui.Show("NA x" startX " y" startY " w1 h1")

    ; 跟踪鼠标移动
    while GetKeyState("LButton", "P") {
        CoordMode("Mouse", "Screen")
        MouseGetPos(&endX, &endY)
        width := Abs(endX - startX)
        height := Abs(endY - startY)
        x := Min(startX, endX)
        y := Min(startY, endY)

        MyGui.Show("NA x" x " y" y " w" width " h" height)
    }
    ; 销毁 GUI
    MyGui.Destroy()
    ; 返回坐标

    x1 := Min(startX, endX)
    y1 := Min(startY, endY)
    x2 := Max(startX, endX)
    y2 := Max(startY, endY)
    action(x1, y1, x2, y2)
}

; 语言播报
; spovice:=ComObject("sapi.spvoice")
; spovice.Speak("世界你好")
; spovice.Speak("You can read simple text.")
