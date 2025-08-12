;窗口&UI刷新
InitUI() {
    global MySoftData
    MyGui := Gui()
    MyGui.Title := "RMTv1.0.7"
    MyGui.SetFont("S10 W550 Q2", MySoftData.FontType)
    MySoftData.MyGui := MyGui

    AddUI()
    CustomTrayMenu()
    OnOpen()
}

OnOpen() {
    global MySoftData
    if (!MySoftData.AgreeAgreement) {
        AgreeAgreementStr :=
            '1. 本软件按"原样"提供，开发者不承担因使用、修改或分发导致的任何法律责任。`n2. 严禁用于违法用途，包括但不限于:游戏作弊、未经授权的系统访问或数据篡改`n3. 使用者需自行承担所有风险，开发者对因违反法律或第三方条款导致的后果概不负责。`n4. 通过使用本软件，您确认：不会将其用于任何非法目的、已充分了解并接受所有潜在法律风险、同意免除开发者因滥用行为导致的一切追责权利`n若不同意上述条款，请立即停止使用本软件。'
        result := MsgBox(AgreeAgreementStr, "免责声明", "4")
        if (result == "No")
            ExitApp()
        IniWrite(true, IniFile, IniSection, "AgreeAgreement")
    }

    if (!MySoftData.IsExecuteShow && !MySoftData.IsLastSaved)
        return

    RefreshGui()    ;不同的分辨率滑动条会异常，两次ShowGUI后才正常，
    RefreshGui()
    IniWrite(false, IniFile, IniSection, "LastSaved")
}

RefreshGui() {
    MySoftData.MyGui.Show(Format("w{} h{} center", 1050, 540))
}

RefreshToolUI() {
    global ToolCheckInfo

    ToolCheckInfo.ToolMousePosCtrl.Value := ToolCheckInfo.PosStr
    ToolCheckInfo.ToolProcessNameCtrl.Value := ToolCheckInfo.ProcessName
    ToolCheckInfo.ToolProcessTileCtrl.Value := ToolCheckInfo.ProcessTile
    ToolCheckInfo.ToolProcessPidCtrl.Value := ToolCheckInfo.ProcessPid
    ToolCheckInfo.ToolProcessClassCtrl.Value := ToolCheckInfo.ProcessClass
    ToolCheckInfo.ToolProcessIdCtrl.Value := ToolCheckInfo.ProcessId
    ToolCheckInfo.ToolColorCtrl.Value := ToolCheckInfo.Color
    ToolCheckInfo.ToolMouseWinPosCtrl.Value := ToolCheckInfo.WinPosStr
}

;UI元素相关函数
AddUI() {
    global MySoftData
    MyGui := MySoftData.MyGui
    AddOperBtnUI()
    MySoftData.TabPosY := 10
    MySoftData.TabPosX := 130
    MySoftData.TabCtrl := MyGui.Add("Tab3", Format("x{} y{} w{} Choose{}", MySoftData.TabPosX, MySoftData.TabPosY, 910,
        MySoftData.TableIndex), MySoftData.TabNameArr)

    loop MySoftData.TabNameArr.Length {
        MySoftData.TabCtrl.UseTab(A_Index)
        func := GetUIAddFunc(A_Index)
        func(A_Index)
    }
    MySoftData.TabCtrl.UseTab()
    height := GetTabHeight()
    MySoftData.TabCtrl.Move(MySoftData.TabPosX, MySoftData.TabPosY, 910, height)

    SB := ScrollBar(MyGui, 100, 100)
    MySoftData.SB := SB
    SB.AddFixedControls(MySoftData.FixedCons)
}

AddOperBtnUI() {
    MyGui := MySoftData.MyGui
    posY := 10
    con := MyGui.Add("GroupBox", Format("x{} y{} w{} h{} center", 10, posY, 110, 95), "当前配置")
    MySoftData.FixedCons.Push(con)
    MySoftData.GroupFixedCons.Push(con)

    ; 当前配置
    posY += 25
    con := MyGui.Add("Text", Format("x{} y{} w{} h{} Center", 15, posY, 100, 40), MySoftData.CurSettingName)
    MySoftData.FixedCons.Push(con)
    posY += 30
    con := MyGui.Add("Button", Format("x{} y{} w{} h{} center", 15, posY, 100, 30), "配置管理")
    con.OnEvent("Click", (*) => MySettingMgrGui.ShowGui())
    MySoftData.FixedCons.Push(con)

    posY += 50
    con := MyGui.Add("GroupBox", Format("x{} y{} w{} h{} center", 10, posY, 110, 415), "全局操作")
    MySoftData.FixedCons.Push(con)
    MySoftData.GroupFixedCons.Push(con)

    posY += 25
    ; 休眠
    MySoftData.PauseToggleCtrl := MyGui.Add("CheckBox", Format("x{} y{} w{} h{}", 15, posY, 100, 20), "休眠")
    MySoftData.PauseToggleCtrl.Value := MySoftData.IsPause
    MySoftData.PauseToggleCtrl.OnEvent("Click", OnPauseHotkey)
    MySoftData.FixedCons.Push(MySoftData.PauseToggleCtrl)
    posY += 20
    CtrlType := GetHotKeyCtrlType(MySoftData.PauseHotkey)
    con := MyGui.Add(CtrlType, Format("x{} y{} w{}", 15, posY, 100), MySoftData.PauseHotkey)
    con.Enabled := false
    MySoftData.FixedCons.Push(con)
    posY += 40

    ;终止模块
    con := MyGui.Add("Button", Format("x{} y{} w{} h{} center", 15, posY, 100, 30), "终止所有宏")
    con.OnEvent("Click", OnKillAllMacro)
    MySoftData.FixedCons.Push(con)
    posY += 31
    CtrlType := GetHotKeyCtrlType(MySoftData.KillMacroHotkey)
    con := MyGui.Add(CtrlType, Format("x{} y{} w{}", 15, posY, 100), MySoftData.KillMacroHotkey)
    con.Enabled := false
    MySoftData.FixedCons.Push(con)
    posY += 40

    ReloadBtnCtrl := MyGui.Add("Button", Format("x{} y{} w{} h{} center", 15, posY, 100, 30), "重载")
    ReloadBtnCtrl.OnEvent("Click", MenuReload)
    MySoftData.FixedCons.Push(ReloadBtnCtrl)
    posY += 40

    MySoftData.BtnAdd := MyGui.Add("Button", Format("x{} y{} w{} h{} center", 15, posY, 100, 30), "新增宏")
    MySoftData.BtnAdd.OnEvent("Click", OnAddSetting)
    posY += 40

    ; posY := 250
    ; con := MyGui.Add("Picture", Format("x{} y{} w{} h{} center", 15, posY, 100, 100), "Images\Soft\WeiXin.png")
    ; MySoftData.FixedCons.Push(con)

    ; posY := 350
    ; con := MyGui.Add("Text", Format("x{} y{} w{} center", 15, posY, 100), "游戏项目")
    ; MySoftData.FixedCons.Push(con)
    ; con := MyGui.Add("Text", Format("x{} y{} w{} center", 15, posY + 20, 100), "为爱发电")
    ; MySoftData.FixedCons.Push(con)
    ; con := MyGui.Add("Text", Format("x{} y{} w{} center", 15, posY + 40, 100), "诚邀美术、程序")
    ; MySoftData.FixedCons.Push(con)
    ; con := MyGui.Add("Link", Format("x{} y{} w{} center", 25, posY + 60, 100),
    ; '<a href="https://www.bilibili.com/video/BV1jPwTe3EtB">项目演示链接</a>')
    ; MySoftData.FixedCons.Push(con)
    ; con := MyGui.Add("Text", Format("x{} y{} w{} center", 15, posY + 80, 100), "QQ:2660681757")
    ; MySoftData.FixedCons.Push(con)

    posY := 490
    MySoftData.BtnSave := MyGui.Add("Button", Format("x{} y{} w{} h{} center", 15, posY, 100, 30), "应用并保存")
    MySoftData.BtnSave.OnEvent("Click", OnSaveSetting)

    MySoftData.FixedCons.Push(MySoftData.BtnAdd)
    MySoftData.FixedCons.Push(MySoftData.BtnSave)

    MyTriggerKeyGui.SureFocusCon := MySoftData.BtnSave
    MyTriggerStrGui.SureFocusCon := MySoftData.BtnSave
    MyMacroGui.SureFocusCon := MySoftData.BtnSave
    MyReplaceKeyGui.SureFocusCon := MySoftData.BtnSave
}

GetUIAddFunc(index) {
    UIAddFuncArr := [AddMacroHotkeyUI, AddMacroHotkeyUI, AddMacroHotkeyUI, AddMacroHotkeyUI, AddMacroHotkeyUI,
        AddToolUI, AddSettingUI, AddHelpUI, AddRewardUI]
    return UIAddFuncArr[index]
}

;添加正常按键宏UI
AddMacroHotkeyUI(index) {
    global MySoftData
    tableItem := MySoftData.TableInfo[index]
    isNoTriggerKey := CheckIsNoTriggerKey(index)
    offsetPosx := isNoTriggerKey ? -60 : 0
    tableItem.underPosY := MySoftData.TabPosY
    ; 配置规则说明
    UpdateUnderPosY(index, 30)

    MyGui := MySoftData.MyGui
    con := MyGui.Add("Text", Format("x{} y{} w100", MySoftData.TabPosX + 20, tableItem.underPosY), "宏触发按键")
    con.Visible := !isNoTriggerKey

    MyGui.Add("Text", Format("x{} y{} w80", MySoftData.TabPosX + 120 + offsetPosx, tableItem.underPosY), "循环次数")
    MyGui.Add("Text", Format("x{} y{} w550", MySoftData.TabPosX + 205 + offsetPosx, tableItem.underPosY), "宏指令")
    MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 690, tableItem.underPosY), "前台进程触发（填写进程名）")

    UpdateUnderPosY(index, 20)
    LoadSavedSettingUI(index)
}

LoadSavedSettingUI(index) {
    tableItem := MySoftData.TableInfo[index]
    isMacro := CheckIsMacroTable(index)
    isNormal := CheckIsNormalTable(index)
    isSubMacro := CheckIsSubMacroTable(index)
    isNoTriggerKey := CheckIsNoTriggerKey(index)
    isTiming := CheckIsTimingMacroTable(index)
    curIndex := 0
    MyGui := MySoftData.MyGui
    TabPosX := MySoftData.TabPosX
    subMacroWidth := isNoTriggerKey ? 75 : 0
    isTriggerStr := CheckIsStringMacroTable(index)
    EditTriggerAction := isTriggerStr ? OnTableEditTriggerStr : OnTableEditTriggerKey
    EditTriggerAction := isTiming ? OnTableEditTiming : EditTriggerAction
    EditMacroAction := isMacro ? OnTableEditMacro : OnTableEditReplaceKey
    loop tableItem.ModeArr.Length {
        heightValue := 70
        InfoHeight := 60

        newIndexCon := MyGui.Add("Text", Format("x{} y{} w{}", TabPosX + 10, tableItem.underPosY + 5, 30), A_Index ".")
        newTriggerTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", TabPosX + 40, tableItem.underPosY, 70),
        ["按下", "松开", "松止", "开关", "长按"])
        newTriggerTypeCon.Value := tableItem.TriggerTypeArr.Length >= A_Index ? tableItem.TriggerTypeArr[A_Index] : 1
        newTriggerTypeCon.Enabled := isNormal
        newTriggerTypeCon.Visible := isNoTriggerKey ? false : true

        newTkControl := MyGui.Add("Edit", Format("x{} y{} w{} Center", TabPosX + 10, tableItem.underPosY + 33, 100,),
        "")
        newTkControl.Visible := isNoTriggerKey ? false : true
        newTkControl.Value := tableItem.TKArr.Length >= A_Index ? tableItem.TKArr[A_Index] : ""

        newLoopCountControl := MyGui.Add("ComboBox", Format("x{} y{} w60 R5 center", TabPosX + 115 - subMacroWidth,
            tableItem.underPosY),
        ["无限"])
        conValue := tableItem.LoopCountArr.Length >= A_Index ? tableItem.LoopCountArr[A_Index] : "1"
        conValue := conValue == "-1" ? "无限" : conValue
        newLoopCountControl.Text := conValue
        newLoopCountControl.Enabled := isMacro

        btnStr := isTiming ? "定时" : "触发键"
        newKeyBtnControl := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 115 - subMacroWidth, tableItem.underPosY +
            30), btnStr)
        newKeyBtnControl.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, A_Index))
        newKeyBtnControl.Enabled := !isSubMacro

        newInfoControl := MyGui.Add("Edit", Format("x{} y{} w{} h{}", TabPosX + 180 - subMacroWidth, tableItem.underPosY,
            335 + subMacroWidth,
            InfoHeight), "")
        newInfoControl.Value := tableItem.MacroArr.Length >= A_Index ? tableItem.MacroArr[A_Index] : ""

        newModeControl := MyGui.Add("Checkbox", Format("x{} y{}", TabPosX + 528, tableItem.underPosY), "游戏")
        newModeControl.value := tableItem.ModeArr[A_Index]
        newForbidControl := MyGui.Add("Checkbox", Format("x{} y{}", TabPosX + 590, tableItem.underPosY), "禁用")
        newForbidControl.value := tableItem.ForbidArr[A_Index]

        MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 650, tableItem.underPosY), "进程:")
        newProcessNameControl := MyGui.Add("Edit", Format("x{} y{} w180", TabPosX + 690, tableItem.underPosY), "")
        newProcessNameControl.value := tableItem.ProcessNameArr.Length >= A_Index ? tableItem.ProcessNameArr[A_Index] :
            ""

        newMacroBtnControl := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 520, tableItem.underPosY + 30),
        "宏指令")

        newDeleteBtnControl := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 585, tableItem.underPosY + 30),
        "删除")
        newMacroBtnControl.OnEvent("Click", GetTableClosureAction(EditMacroAction, tableItem, A_Index))
        newDeleteBtnControl.OnEvent("Click", GetTableClosureAction(OnTableDelete, tableItem, A_Index))
        newRemarkTipControl := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 650, tableItem.underPosY + 35), "备注:"
        )
        newRemarkControl := MyGui.Add("Edit", Format("x{} y{} w180", TabPosX + 690, tableItem.underPosY + 30), ""
        )
        newRemarkControl.value := tableItem.RemarkArr.Length >= A_Index ? tableItem.RemarkArr[A_Index] : ""

        con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 875, tableItem.underPosY), "↑")
        con.OnEvent("Click", OnTableMoveUp.Bind(tableItem, A_Index))
        con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 875, tableItem.underPosY + 30), "↓")
        con.OnEvent("Click", OnTableMoveDown.Bind(tableItem, A_Index))

        tableItem.MacroBtnConArr.Push(newMacroBtnControl)
        tableItem.RemarkConArr.Push(newRemarkControl)
        tableItem.RemarkTipConArr.Push(newRemarkTipControl)
        tableItem.LoopCountConArr.Push(newLoopCountControl)
        tableItem.TKConArr.Push(newTkControl)
        tableItem.InfoConArr.Push(newInfoControl)
        tableItem.KeyBtnConArr.Push(newKeyBtnControl)
        tableItem.DeleteBtnConArr.Push(newDeleteBtnControl)
        tableItem.ModeConArr.Push(newModeControl)
        tableItem.ForbidConArr.Push(newForbidControl)
        tableItem.ProcessNameConArr.Push(newProcessNameControl)
        tableItem.IndexConArr.Push(newIndexCon)
        tableItem.TriggerTypeConArr.Push(newTriggerTypeCon)
        UpdateUnderPosY(index, heightValue)
    }
}

OnAddSetting(*) {
    global MySoftData
    TableIndex := MySoftData.TabCtrl.Value
    if (!CheckIfAddSetTable(TableIndex)) {
        MsgBox("该页签不可添加配置啊喂")
        return
    }

    MySoftData.SB.ResetVerticalValue()
    MyGui := MySoftData.MyGui
    tableItem := MySoftData.TableInfo[TableIndex]
    TabPosX := MySoftData.TabPosX
    isMacro := CheckIsMacroTable(TableIndex)
    isNormal := CheckIsNormalTable(TableIndex)
    isSubMacro := CheckIsSubMacroTable(TableIndex)
    isNoTriggerKey := CheckIsNoTriggerKey(TableIndex)
    isTiming := CheckIsTimingMacroTable(TableIndex)
    subMacroWidth := isNoTriggerKey ? 75 : 0
    isTriggerStr := CheckIsStringMacroTable(TableIndex)
    EditTriggerAction := isTriggerStr ? OnTableEditTriggerStr : OnTableEditTriggerKey
    EditTriggerAction := isTiming ? OnTableEditTiming : EditTriggerAction
    EditMacroAction := isMacro ? OnTableEditMacro : OnTableEditReplaceKey
    tableItem.TKArr.Push("")
    tableItem.MacroArr.Push("")
    tableItem.ModeArr.Push(0)
    tableItem.ForbidArr.Push(0)
    tableItem.ProcessNameArr.Push("")
    tableItem.RemarkArr.Push("")
    tableItem.LoopCountArr.Push("1")
    tableItem.HoldTimeArr.Push(500)
    tableItem.SerialArr.Push(FormatTime(, "HHmmss"))
    tableItem.TimingSerialArr.Push(GetSerialStr("Timing"))
    tableItem.IsWorkArr.Push(0)

    heightValue := 70
    TKPosY := tableItem.underPosY + 10
    InfoHeight := 60
    index := tableItem.ModeArr.Length

    MySoftData.TabCtrl.UseTab(TableIndex)

    newIndexCon := MyGui.Add("Text", Format("x{} y{} w{}", TabPosX + 10, tableItem.underPosY + 5, 30), index ".")
    newTriggerTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", TabPosX + 40, tableItem.underPosY, 70), ["按下",
        "松开",
        "松止", "开关", "长按"])
    newTriggerTypeCon.Value := 1
    newTriggerTypeCon.Enabled := isNormal
    newTriggerTypeCon.Visible := isNoTriggerKey ? false : true

    newTkControl := MyGui.Add("Edit", Format("x{} y{} w{} Center", TabPosX + 10, tableItem.underPosY + 33, 100),
    "")
    newTkControl.Visible := isNoTriggerKey ? false : true

    newLoopCountControl := MyGui.Add("ComboBox", Format("x{} y{} w60 R5 center", TabPosX + 115 - subMacroWidth,
        tableItem.underPosY
    ), [
        "无限"])
    newLoopCountControl.Text := "1"
    newLoopCountControl.Enabled := isMacro

    btnStr := isTiming ? "定时" : "触发键"
    newKeyBtnControl := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 115 - subMacroWidth, tableItem.underPosY +
        30), btnStr)
    newKeyBtnControl.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, index))
    newKeyBtnControl.Enabled := !isSubMacro

    newInfoControl := MyGui.Add("Edit", Format("x{} y{} w{} h{}", TabPosX + 180 - subMacroWidth, tableItem.underPosY,
        335 + subMacroWidth, InfoHeight), "")

    newModeControl := MyGui.Add("Checkbox", Format("x{} y{}", TabPosX + 528, tableItem.underPosY), "游戏")
    newModeControl.value := 0
    newForbidControl := MyGui.Add("Checkbox", Format("x{} y{}", TabPosX + 590, tableItem.underPosY), "禁用")
    newForbidControl.value := 0

    MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 650, tableItem.underPosY), "进程:")
    newProcessNameControl := MyGui.Add("Edit", Format("x{} y{} w180", TabPosX + 690, tableItem.underPosY), "")
    newProcessNameControl.value := ""

    newMacroBtnControl := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 520, tableItem.underPosY + 30),
    "宏指令")
    newDeleteBtnControl := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 585, tableItem.underPosY + 30),
    "删除")
    newMacroBtnControl.OnEvent("Click", GetTableClosureAction(EditMacroAction, tableItem, index))
    newDeleteBtnControl.OnEvent("Click", GetTableClosureAction(OnTableDelete, tableItem, index))

    newRemarkTipCon := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 650, tableItem.underPosY + 35), "备注:"
    )
    newRemarkControl := MyGui.Add("Edit", Format("x{} y{} w180", TabPosX + 690, tableItem.underPosY + 30), "")
    con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 875, tableItem.underPosY), "↑")
    con.OnEvent("Click", OnTableMoveUp.Bind(tableItem, index))
    MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 875, tableItem.underPosY + 30), "↓")
    con.OnEvent("Click", OnTableMoveDown.Bind(tableItem, index))

    tableItem.LoopCountConArr.Push(newLoopCountControl)
    tableItem.MacroBtnConArr.Push(newMacroBtnControl)
    tableItem.RemarkConArr.Push(newRemarkControl)
    tableItem.RemarkTipConArr.Push(newRemarkTipCon)
    tableItem.KeyBtnConArr.Push(newKeyBtnControl)
    tableItem.DeleteBtnConArr.Push(newDeleteBtnControl)
    tableItem.TKConArr.Push(newTkControl)
    tableItem.InfoConArr.Push(newInfoControl)
    tableItem.ModeConArr.Push(newModeControl)
    tableItem.ForbidConArr.Push(newForbidControl)
    tableItem.ProcessNameConArr.Push(newProcessNameControl)
    tableItem.IndexConArr.Push(newIndexCon)
    tableItem.TriggerTypeConArr.Push(newTriggerTypeCon)

    UpdateUnderPosY(TableIndex, heightValue)

    MySoftData.TabCtrl.UseTab()
    height := GetTabHeight()
    MySoftData.TabCtrl.Move(MySoftData.TabPosX, MySoftData.TabPosY, 910, height)
    MySoftData.SB.UpdateScrollBars()
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")

    RefreshGui()
    RefreshGui()
}

AddSettingUI(index) {
    MyGui := MySoftData.MyGui
    posY := MySoftData.TabPosY
    posX := MySoftData.TabPosX

    posY += 30
    posX := MySoftData.TabPosX
    MyGui.Add("GroupBox", Format("x{} y{} w870 h140", posX + 10, posY), "快捷键修改")
    posY += 30
    con := MyGui.Add("Text", Format("x{} y{}", posX + 25, posY), "软件休眠:")
    CtrlType := GetHotKeyCtrlType(MySoftData.PauseHotkey)
    showCon := MyGui.Add(CtrlType, Format("x{} y{} w130", posX + 100, posY - 4), MySoftData.PauseHotkey)
    showCon.Enabled := false
    MySoftData.PauseHotkeyCtrl := MyGui.Add("Text", Format("x{} y{} w130", posX + 100, posY), MySoftData.PauseHotkey
    )
    MySoftData.PauseHotkeyCtrl.Visible := false
    con := MyGui.Add("Button", Format("x{} y{} w50", posX + 235, posY - 5), "编辑")
    con.OnEvent("Click", OnOpenEditHotkeyGui.Bind(showCon, MySoftData.PauseHotkeyCtrl, true))

    con := MyGui.Add("Text", Format("x{} y{}", posX + 315, posY), "终止宏:")
    CtrlType := GetHotKeyCtrlType(MySoftData.KillMacroHotkey)
    showCon := MyGui.Add(CtrlType, Format("x{} y{} w130", posX + 385, posY - 4), MySoftData.KillMacroHotkey)
    showCon.Enabled := false
    MySoftData.KillMacroHotkeyCtrl := MyGui.Add("Text", Format("x{} y{} w130", posX + 385, posY), MySoftData.KillMacroHotkey
    )
    MySoftData.KillMacroHotkeyCtrl.Visible := false
    con := MyGui.Add("Button", Format("x{} y{} center w50", posX + 520, posY - 5), "编辑")
    con.OnEvent("Click", OnOpenEditHotkeyGui.Bind(showCon, MySoftData.KillMacroHotkeyCtrl, false))

    MyGui.Add("Text", Format("x{} y{}", posX + 605, posY), "鼠标信息:")
    CtrlType := GetHotKeyCtrlType(ToolCheckInfo.ToolCheckHotkey)
    showCon := MyGui.Add(CtrlType, Format("x{} y{} w130", posX + 680, posY - 4), ToolCheckInfo.ToolCheckHotkey)
    showCon.Enabled := false
    ToolCheckInfo.ToolCheckHotKeyCtrl := MyGui.Add("Text", Format("x{} y{} w130", posX + 680, posY), ToolCheckInfo.ToolCheckHotkey
    )
    ToolCheckInfo.ToolCheckHotKeyCtrl.Visible := false
    con := MyGui.Add("Button", Format("x{} y{} center w50", posX + 815, posY - 5), "编辑")
    con.OnEvent("Click", OnOpenEditHotkeyGui.Bind(showCon, ToolCheckInfo.ToolCheckHotKeyCtrl, false))

    posY += 40
    con := MyGui.Add("Text", Format("x{} y{}", posX + 25, posY), "指令录制:")
    CtrlType := GetHotKeyCtrlType(ToolCheckInfo.ToolRecordMacroHotKey)
    showCon := MyGui.Add(CtrlType, Format("x{} y{} w130", posX + 100, posY - 4),
    ToolCheckInfo.ToolRecordMacroHotKey)
    showCon.Enabled := false
    ToolCheckInfo.ToolRecordMacroHotKeyCtrl := MyGui.Add("Text", Format("x{} y{} w130", posX + 100, posY),
    ToolCheckInfo.ToolRecordMacroHotKey)
    ToolCheckInfo.ToolRecordMacroHotKeyCtrl.Visible := false
    con := MyGui.Add("Button", Format("x{} y{} center w50", posX + 235, posY - 5), "编辑")
    con.OnEvent("Click", OnOpenEditHotkeyGui.Bind(showCon, ToolCheckInfo.ToolRecordMacroHotKeyCtrl, false))

    con := MyGui.Add("Text", Format("x{} y{}", posX + 315, posY), "文本提取:")
    CtrlType := GetHotKeyCtrlType(ToolCheckInfo.ToolTextFilterHotKey)
    showCon := MyGui.Add(CtrlType, Format("x{} y{} w130", posX + 385, posY - 4),
    ToolCheckInfo.ToolTextFilterHotKey)
    showCon.Enabled := false
    ToolCheckInfo.ToolTextFilterHotKeyCtrl := MyGui.Add("Text", Format("x{} y{} w130", posX + 385, posY),
    ToolCheckInfo.ToolTextFilterHotKey)
    ToolCheckInfo.ToolTextFilterHotKeyCtrl.Visible := false
    con := MyGui.Add("Button", Format("x{} y{} center w50", posX + 520, posY - 5), "编辑")
    con.OnEvent("Click", OnOpenEditHotkeyGui.Bind(showCon, ToolCheckInfo.ToolTextFilterHotKeyCtrl, false))

    MyGui.Add("Text", Format("x{} y{}", posX + 605, posY), "屏幕截图:")
    CtrlType := GetHotKeyCtrlType(ToolCheckInfo.ScreenShotHotKey)
    showCon := MyGui.Add(CtrlType, Format("x{} y{} w130", posX + 680, posY - 4),
    ToolCheckInfo.ScreenShotHotKey)
    showCon.Enabled := false
    ToolCheckInfo.ScreenShotHotKeyCtrl := MyGui.Add("Text", Format("x{} y{} w130", posX + 680, posY),
    ToolCheckInfo.ScreenShotHotKey)
    ToolCheckInfo.ScreenShotHotKeyCtrl.Visible := false
    con := MyGui.Add("Button", Format("x{} y{} center w50", posX + 815, posY - 5), "编辑")
    con.OnEvent("Click", OnOpenEditHotkeyGui.Bind(showCon, ToolCheckInfo.ScreenShotHotKeyCtrl, false))

    posY += 40
    con := MyGui.Add("Text", Format("x{} y{}", posX + 25, posY), "自由贴:")
    CtrlType := GetHotKeyCtrlType(ToolCheckInfo.FreePasteHotKey)
    showCon := MyGui.Add(CtrlType, Format("x{} y{} w130", posX + 100, posY - 4),
    ToolCheckInfo.FreePasteHotKey)
    showCon.Enabled := false
    ToolCheckInfo.FreePasteHotKeyCtrl := MyGui.Add("Text", Format("x{} y{} w130", posX + 100, posY),
    ToolCheckInfo.FreePasteHotKey)
    ToolCheckInfo.FreePasteHotKeyCtrl.Visible := false
    con := MyGui.Add("Button", Format("x{} y{} center w50", posX + 235, posY - 5), "编辑")
    con.OnEvent("Click", OnOpenEditHotkeyGui.Bind(showCon, ToolCheckInfo.FreePasteHotKeyCtrl, false))

    posY += 40
    posX := MySoftData.TabPosX
    MyGui.Add("GroupBox", Format("x{} y{} w870 h100", posX + 10, posY), "默认数值")
    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 25, posY), "按住时间浮动(%):")
    MySoftData.HoldFloatCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 145, posY - 4), MySoftData.HoldFloat
    )

    MyGui.Add("Text", Format("x{} y{}", posX + 315, posY), "每次间隔浮动(%):")
    MySoftData.PreIntervalFloatCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 440, posY - 4),
    MySoftData.PreIntervalFloat)

    MyGui.Add("Text", Format("x{} y{}", posX + 635, posY), "间隔指令浮动(%):")
    MySoftData.IntervalFloatCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 760, posY - 4), MySoftData.IntervalFloat
    )

    posY += 40
    MyGui.Add("Text", Format("x{} y{}", posX + 25, posY), "坐标X浮动(px):")
    MySoftData.CoordXFloatCon := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 145, posY - 4), MySoftData.CoordXFloat
    )

    MyGui.Add("Text", Format("x{} y{}", posX + 315, posY), "坐标Y浮动(px):")
    MySoftData.CoordYFloatCon := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 440, posY - 4),
    MySoftData.CoordYFloat)

    MyGui.Add("Text", Format("x{} y{}", posX + 635, posY), "多线程数(1~5):")
    MySoftData.MutiThreadNumCtrl := MyGui.Add("Edit", Format("x{} y{} w100 center", posX + 760, posY - 4), MySoftData
    .MutiThreadNum)

    posY += 40
    MyGui.Add("GroupBox", Format("x{} y{} w870 h100", posX + 10, posY), "开关选项")
    posY += 30
    MySoftData.ShowWinCtrl := MyGui.Add("CheckBox", Format("x{} y{}", posX + 25, posY), "运行后显示窗口")
    MySoftData.ShowWinCtrl.Value := MySoftData.IsExecuteShow
    MySoftData.ShowWinCtrl.OnEvent("Click", OnShowWinChanged)

    MySoftData.BootStartCtrl := MyGui.Add("CheckBox", Format("x{} y{}", posX + 315, posY), "开机自启")
    MySoftData.BootStartCtrl.Value := MySoftData.IsBootStart
    MySoftData.BootStartCtrl.OnEvent("Click", OnBootStartChanged)

    MySoftData.CMDTipCtrl := MyGui.Add("CheckBox", Format("x{} y{} -Wrap w15", posX + 635, posY), "")
    MySoftData.CMDTipCtrl.Value := MySoftData.CMDTip
    con := MyGui.Add("Button", Format("x{} y{}", posX + 635 + 15, posY - 5), "指令显示")
    con.OnEvent("Click", (*) => OnEditCMDTipGui())

    posY += 40
    MySoftData.NoVariableTipCtrl := MyGui.Add("CheckBox", Format("x{} y{}", posX + 25, posY), "无变量提醒")
    MySoftData.NoVariableTipCtrl.Value := MySoftData.NoVariableTip

    posY += 40
    MyGui.Add("GroupBox", Format("x{} y{} w870 h100", posX + 10, posY), "下拉框选项")
    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 25, posY), "软件字体：")
    MySoftData.FontTypeCtrl := MyGui.Add("DropDownList", Format("x{} y{} w180", posX + 100, posY - 5), [])
    MySoftData.FontTypeCtrl.Delete()
    MySoftData.FontTypeCtrl.Add(MySoftData.FontList)
    MySoftData.FontTypeCtrl.Text := MySoftData.FontType

    MyGui.Add("Text", Format("x{} y{}", posX + 315, posY), "软件截图方式：")
    MySoftData.ScreenShotTypeCtrl := MyGui.Add("DropDownList", Format("x{} y{} w100", posX + 410, posY - 5), ["微软截图",
        "RMT截图"])
    MySoftData.ScreenShotTypeCtrl.Value := MySoftData.ScreenShotType

    posY += 90
    tableItem := MySoftData.TableInfo[index]
    tableItem.UnderPosY := posY
}

AddRewardUI(index) {
    MyGui := MySoftData.MyGui
    posY := MySoftData.TabPosY
    posX := MySoftData.TabPosX

    posY += 40
    posX += 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 800, 60),
    "RMT(若梦兔)完全免费的开源软件，如果你觉得它提升了你的效率，欢迎请我喝杯咖啡~ `n你的打赏会让我更有动力持续更新和维护这个项目！")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 60
    posX := MySoftData.TabPosX + 100
    con := MyGui.Add("Picture", Format("x{} y{} w{} h{} center", posX, posY, 220, 220), "Images\Soft\WeiXin.png")
    con := MyGui.Add("Text", Format("x{} y{} w{} h{} center", posX, posY + 230, 220, 50), "微信打赏")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posX += 450
    con := MyGui.Add("Picture", Format("x{} y{} w{} h{} center", posX, posY, 220, 220), "Images\Soft\ZhiFuBao.png")
    con := MyGui.Add("Text", Format("x{} y{} w{} h{} center", posX, posY + 230, 220, 50), "支付宝打赏")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 300
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 860, 80),
    "当然，如果你暂时不方便，分享给朋友也是很棒的支持~`n开发不易，感谢你的每一份温暖！")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 35
    MySoftData.TableInfo[index].underPosY := posY
}

AddHelpUI(index) {
    MyGui := MySoftData.MyGui
    posY := MySoftData.TabPosY
    posX := MySoftData.TabPosX

    posY += 40
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{} Center", posX, posY, 700, 25),
    "免责声明")
    con.SetFont((Format("S{} W{} Q{}", 14, 600, 2)))

    posY += 25
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{} Center", posX, posY, 700, 35),
    "本文件是对 GNU Affero General Public License v3.0 的补充说明，不影响原协议效力")
    con.SetFont((Format("S{} W{} Q{}", 10, 600, 0)))

    posY += 40
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 800, 25),
    '1. 本软件按"原样"提供，开发者不承担因使用、修改或分发导致的任何法律责任。')
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 25
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 800, 25),
    '2. 严禁用于违法用途，包括但不限于:游戏作弊、未经授权的系统访问或数据篡改')
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 25
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 800, 25),
    '3. 使用者需自行承担所有风险，开发者对因违反法律或第三方条款导致的后果概不负责。')
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 25
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 800, 50),
    '4. 通过使用本软件，您确认：不会将其用于任何非法目的、已充分了解并接受所有潜在法律风险、同意免除开发者因滥用行为导致的一切追责权利')
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 50
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{} Center", posX, posY, 800, 35),
    "若不同意上述条款，请立即停止使用本软件。")
    con.SetFont((Format("cRed  S{} W{} Q{}", 12, 600, 0)))

    posY += 50
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 140, 35),
    "操作说明文档：")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))
    con := MyGui.Add("Link", Format("x{} y{} w{} h{}", posX + 140, posY, 500, 35),
    '<a href="https://zclucas.github.io/RMT/">帮助你快速上手，理解词条，10分钟秒变大神</a>')
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 30
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 140, 30),
    "国内开源网址：")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))
    con := MyGui.Add("Link", Format("x{} y{} w{} h{}", posX + 140, posY, 500, 30),
    '<a href="https://gitee.com/fateman/RMT">https://gitee.com/fateman/RMT</a>')
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 30
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 140, 30),
    "国外开源网址：")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))
    con := MyGui.Add("Link", Format("x{} y{} w{} h{}", posX + 140, posY, 500, 30),
    '<a href="https://github.com/zclucas/RMT">https://github.com/zclucas/RMT</a>')
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 30
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 140, 30),
    "软件检查更新：")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX + 140, posY, 500, 30),
    "浏览开源网址，查看右侧发行版处即可知道软件最新版本")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 30
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 140, 30),
    "软件交流QQ群：")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))
    con := MyGui.Add("Link", Format("x{} y{} w{} h{}", posX + 140, posY, 700, 30),
    '<a href="https://qm.qq.com/q/DgpDumEPzq">[1群]837661891</a>(已满)、<a href="https://qm.qq.com/q/uZszuxabPW">[2群]1050141694</a>'
    )
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 30
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 140, 30),
    "软件交流频道：")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))
    con := MyGui.Add("Link", Format("x{} y{} w{} h{}", posX + 140, posY, 700, 30),
    '<a href="https://pd.qq.com/s/5wyjvj7zw">pd63973680</a>(提交优化方案，使用心得分享，问题反馈)')
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 30
    posX := MySoftData.TabPosX + 15
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 140, 30),
    "软件开源协议：")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX + 140, posY, 500, 30), "AGPL-3.0")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))

    posY += 35
    MySoftData.TableInfo[index].underPosY := posY
}

AddToolUI(index) {
    global ToolCheckInfo

    MyGui := MySoftData.MyGui
    posY := MySoftData.TabPosY
    posX := MySoftData.TabPosX
    ; 配置规则说明
    posY += 35
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "鼠标信息：")

    isHotKey := CheckIsHotKey(ToolCheckInfo.ToolCheckHotkey)
    CtrlType := isHotKey ? "Hotkey" : "Text"
    con := MyGui.Add(CtrlType, Format("x{} y{} w{}", posX + 120, posY - 3, 130), ToolCheckInfo.ToolCheckHotkey)
    con.Enabled := false

    ToolCheckInfo.ToolCheckCtrl := MyGui.Add("CheckBox", Format("x{} y{}", posX + 260, posY, 60), "开关")
    ToolCheckInfo.ToolCheckCtrl.Value := ToolCheckInfo.IsToolCheck
    ToolCheckInfo.ToolCheckCtrl.OnEvent("Click", OnToolCheckHotkey)

    ToolCheckInfo.AlwaysOnTopCtrl := MyGui.Add("CheckBox", Format("x{} y{}", posX + 400, posY, 60), "窗口置顶")
    ToolCheckInfo.AlwaysOnTopCtrl.Value := false
    ToolCheckInfo.AlwaysOnTopCtrl.OnEvent("Click", OnToolAlwaysOnTop)

    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "屏幕坐标：")
    ToolCheckInfo.ToolMousePosCtrl := MyGui.Add("Edit", Format("x{} y{} w240", posX + 120, posY - 5), ToolCheckInfo.PosStr
    )

    MyGui.Add("Text", Format("x{} y{}", posX + 400, posY), "窗口坐标：")
    ToolCheckInfo.ToolMouseWinPosCtrl := MyGui.Add("Edit", Format("x{} y{} w240", posX + 480, posY - 5), ToolCheckInfo.ProcessName
    )

    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "进程标题：")
    ToolCheckInfo.ToolProcessTileCtrl := MyGui.Add("Edit", Format("x{} y{} w240", posX + 120, posY - 5), ToolCheckInfo.ProcessTile
    )

    MyGui.Add("Text", Format("x{} y{}", posX + 400, posY), "进程名：")
    ToolCheckInfo.ToolProcessNameCtrl := MyGui.Add("Edit", Format("x{} y{} w240", posX + 480, posY - 5), ToolCheckInfo.ProcessName
    )

    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "进程窗口类：")
    ToolCheckInfo.ToolProcessClassCtrl := MyGui.Add("Edit", Format("x{} y{} w240", posX + 120, posY - 5), ToolCheckInfo
    .ProcessClass
    )

    MyGui.Add("Text", Format("x{} y{}", posX + 400, posY), "进程PID:")
    ToolCheckInfo.ToolProcessPidCtrl := MyGui.Add("Edit", Format("x{} y{} w240", posX + 480, posY - 5), ToolCheckInfo.ProcessPid
    )

    posY += 30
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "句柄Id:")
    ToolCheckInfo.ToolProcessIdCtrl := MyGui.Add("Edit", Format("x{} y{} w240", posX + 120, posY - 5), ToolCheckInfo.ProcessId
    )

    MyGui.Add("Text", Format("x{} y{}", posX + 400, posY), "位置颜色：")
    ToolCheckInfo.ToolColorCtrl := MyGui.Add("Edit", Format("x{} y{} w240", posX + 480, posY - 5), ToolCheckInfo.Color
    )

    posY += 40
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "截图和自由贴：")

    isHotKey := CheckIsHotKey(ToolCheckInfo.ScreenShotHotKey)
    CtrlType := isHotKey ? "Hotkey" : "Text"
    con := MyGui.Add(CtrlType, Format("x{} y{} w{}", posX + 120, posY - 3, 130), ToolCheckInfo.ScreenShotHotKey
    )
    con.Enabled := false

    con := MyGui.Add("Button", Format("x{} y{} w{} h{}", posX + 260, posY - 5, 100, 25), "截图")
    con.OnEvent("Click", OnToolScreenShot)

    isHotKey := CheckIsHotKey(ToolCheckInfo.FreePasteHotKey)
    CtrlType := isHotKey ? "Hotkey" : "Text"
    con := MyGui.Add(CtrlType, Format("x{} y{} w{}", posX + 400, posY - 3, 130), ToolCheckInfo.FreePasteHotKey
    )
    con.Enabled := false

    con := MyGui.Add("Button", Format("x{} y{} w{} h{}", posX + 540, posY - 5, 100, 25), "自由贴")
    con.OnEvent("Click", OnToolFreePaste)

    posY += 40
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "指令录制：")

    isHotKey := CheckIsHotKey(ToolCheckInfo.ToolRecordMacroHotKey)
    CtrlType := isHotKey ? "Hotkey" : "Text"
    con := MyGui.Add(CtrlType, Format("x{} y{} w{} h{}", posX + 120, posY - 3, 130, 20), ToolCheckInfo.ToolRecordMacroHotKey
    )
    con.Enabled := false

    ToolCheckInfo.ToolCheckRecordMacroCtrl := MyGui.Add("CheckBox", Format("x{} y{}", posX + 260, posY, 60), "开关")
    ToolCheckInfo.ToolCheckRecordMacroCtrl.Value := ToolCheckInfo.IsToolRecord
    ToolCheckInfo.ToolCheckRecordMacroCtrl.OnEvent("Click", OnHotToolRecordMacro.Bind(false))

    con := MyGui.Add("Button", Format("x{} y{} w{} h{}", posX + 400, posY - 5, 100, 25), "录制选项")
    con.OnEvent("Click", OnClickToolRecordSettingBtn)

    posY += 40
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "图片文本提取：")

    isHotKey := CheckIsHotKey(ToolCheckInfo.ToolTextFilterHotKey)
    CtrlType := isHotKey ? "Hotkey" : "Text"
    con := MyGui.Add(CtrlType, Format("x{} y{} w{}", posX + 120, posY - 3, 130), ToolCheckInfo.ToolTextFilterHotKey
    )
    con.Enabled := false

    con := MyGui.Add("Button", Format("x{} y{} w{} h{}", posX + 260, posY - 5, 100, 25), "截图提取文本")
    con.OnEvent("Click", OnToolTextFilterScreenShot)

    con := MyGui.Add("Button", Format("x{} y{} w{} h{}", posX + 400, posY - 5, 120, 25), "从图片提取文本")
    con.OnEvent("Click", OnToolTextFilterSelectImage)

    posY += 25
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "相关选项：")

    MyGui.Add("Text", Format("x{} y{} w{}", PosX + 120, PosY, 110), "文本识别模型:")
    ToolCheckInfo.OCRTypeCtrl := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 260, PosY - 5, 100), [
        "中文",
        "英文"])
    ToolCheckInfo.OCRTypeCtrl.Value := ToolCheckInfo.OCRTypeValue

    posY += 40
    MyGui.Add("Text", Format("x{} y{}", posX + 20, posY), "录制的指令或提取的文本内容：")

    con := MyGui.Add("Button", Format("x{} y{} w{} h{}", posX + 260, posY - 5, 80, 25), "清空内容")
    con.OnEvent("Click", OnClearToolText)

    posY += 25
    ToolCheckInfo.ToolTextCtrl := MyGui.Add("Edit", Format("x{} y{} w{} h{}", posX + 20, posY, 800, 100), "")

    posY += 20
    MySoftData.TableInfo[index].underPosY := posY
}

SetToolCheckInfo() {
    global ToolCheckInfo
    CoordMode("Mouse", "Screen")
    MouseGetPos &mouseX, &mouseY, &winId
    ToolCheckInfo.PosStr := mouseX . "," . mouseY
    ToolCheckInfo.ProcessName := WinGetProcessName(winId)
    ToolCheckInfo.ProcessTile := WinGetTitle(winId)
    ToolCheckInfo.ProcessPid := WinGetPID(winId)
    ToolCheckInfo.ProcessClass := WinGetClass(winId)
    ToolCheckInfo.ProcessId := winId
    ToolCheckInfo.Color := StrReplace(PixelGetColor(mouseX, mouseY, "Slow"), "0x", "")

    WinPosArr := GetWinPos()
    ToolCheckInfo.WinPosStr := WinPosArr[1] . "," . WinPosArr[2]
    RefreshToolUI()
}

; 系统托盘优化
CustomTrayMenu() {
    A_TrayMenu.Insert("&Suspend Hotkeys", "显示窗口", (*) => RefreshGui())
    A_TrayMenu.Delete("&Pause Script")
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Default := "显示窗口"
    TraySetIcon(, , true)
}
