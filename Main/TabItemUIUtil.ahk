#Requires AutoHotkey v2.0

;添加正常按键宏UI
LoadTabConent(index) {
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
    tableItem.AllConArr.Push(ItemConInfo(con))

    con := MyGui.Add("Text", Format("x{} y{} w80", MySoftData.TabPosX + 120 + offsetPosx, tableItem.underPosY), "循环次数")
    tableItem.AllConArr.Push(ItemConInfo(con))
    con := MyGui.Add("Text", Format("x{} y{} w550", MySoftData.TabPosX + 205 + offsetPosx, tableItem.underPosY), "宏指令")
    tableItem.AllConArr.Push(ItemConInfo(con))
    con := MyGui.Add("Text", Format("x{} y{} w550", MySoftData.TabPosX + 515, tableItem.underPosY), "宏按键类型")
    tableItem.AllConArr.Push(ItemConInfo(con))
    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 690, tableItem.underPosY), "指定前台触发")
    tableItem.AllConArr.Push(ItemConInfo(con))

    UpdateUnderPosY(index, 20)
    LoadTabItem(index)
}

LoadTabItem(index) {
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

        newColorCon := MyGui.Add("Pic", Format("x{} y{} w{} h27", TabPosX + 10, tableItem.underPosY, 29),
        "Images\Soft\GreenColor.png")
        newColorCon.Visible := false
        newIndexCon := MyGui.Add("Text", Format("x{} y{} w{} +BackgroundTrans", TabPosX + 10, tableItem.underPosY + 5,
            30), A_Index ".")

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

        newModeControl := MyGui.Add("DropDownList", Format("x{} y{} w60 Center", TabPosX + 520, tableItem.underPosY), [
            "虚拟", "拟真"])
        newModeControl.value := tableItem.ModeArr[A_Index]

        newForbidControl := MyGui.Add("Checkbox", Format("x{} y{}", TabPosX + 590, tableItem.underPosY + 4), "禁用")
        newForbidControl.value := tableItem.ForbidArr[A_Index]

        MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 650, tableItem.underPosY + 4), "前台:")
        newProcessNameControl := MyGui.Add("Edit", Format("x{} y{} w140", TabPosX + 690, tableItem.underPosY), "")
        newProcessNameControl.value := tableItem.ProcessNameArr.Length >= A_Index ? tableItem.ProcessNameArr[A_Index] :
            ""
        con := MyGui.Add("Button", Format("x{} y{} w40 h29", TabPosX + 832, tableItem.underPosY - 1), "编辑")
        con.OnEvent("Click", OnItemEditFrontInfo.Bind(tableItem, A_Index))

        newMacroBtnControl := MyGui.Add("Button", Format("x{} y{} w61", TabPosX + 520, tableItem.underPosY + 30),
        "宏指令")
        newMacroBtnControl.OnEvent("Click", GetTableClosureAction(EditMacroAction, tableItem, A_Index))
        newDeleteBtnControl := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 585, tableItem.underPosY + 30),
        "删除")
        newDeleteBtnControl.OnEvent("Click", GetTableClosureAction(OnTableDelete, tableItem, A_Index))

        newRemarkTipControl := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 650, tableItem.underPosY + 37), "备注:"
        )
        newRemarkControl := MyGui.Add("Edit", Format("x{} y{} w181", TabPosX + 690, tableItem.underPosY + 32), ""
        )
        newRemarkControl.value := tableItem.RemarkArr.Length >= A_Index ? tableItem.RemarkArr[A_Index] : ""

        con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 875, tableItem.underPosY), "↑")
        con.OnEvent("Click", OnTableMoveUp.Bind(tableItem, A_Index))
        con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 875, tableItem.underPosY + 32), "↓")
        con.OnEvent("Click", OnTableMoveDown.Bind(tableItem, A_Index))

        tableItem.MacroBtnConArr.Push(newMacroBtnControl)
        tableItem.RemarkConArr.Push(newRemarkControl)
        tableItem.RemarkTipConArr.Push(newRemarkTipControl)
        tableItem.LoopCountConArr.Push(newLoopCountControl)
        tableItem.TKConArr.Push(newTkControl)
        tableItem.MacroConArr.Push(newInfoControl)
        tableItem.KeyBtnConArr.Push(newKeyBtnControl)
        tableItem.DeleteBtnConArr.Push(newDeleteBtnControl)
        tableItem.ModeConArr.Push(newModeControl)
        tableItem.ForbidConArr.Push(newForbidControl)
        tableItem.ProcessNameConArr.Push(newProcessNameControl)
        tableItem.IndexConArr.Push(newIndexCon)
        tableItem.ColorConArr.push(newColorCon)
        tableItem.ColorStateArr.push(0)
        tableItem.TriggerTypeConArr.Push(newTriggerTypeCon)
        UpdateUnderPosY(index, heightValue)
    }
}

OnAddTabItem(*) {
    global MySoftData
    TableIndex := MySoftData.TabCtrl.Value
    if (!CheckIfAddSetTable(TableIndex)) {
        MsgBox("该页签不可添加配置啊喂")
        return
    }

    ; MySoftData.SB.ResetVerticalValue()
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
    tableItem.ModeArr.Push(1)
    tableItem.ForbidArr.Push(0)
    tableItem.ProcessNameArr.Push("")
    tableItem.RemarkArr.Push("")
    tableItem.LoopCountArr.Push("1")
    tableItem.HoldTimeArr.Push(500)
    tableItem.SerialArr.Push(FormatTime(, "HHmmss"))
    tableItem.TimingSerialArr.Push(GetSerialStr("Timing"))
    tableItem.IsWorkIndexArr.Push(0)

    heightValue := 70
    TKPosY := tableItem.underPosY + 10
    InfoHeight := 60
    index := tableItem.ModeArr.Length

    MySoftData.TabCtrl.UseTab(TableIndex)

    newColorCon := MyGui.Add("Pic", Format("x{} y{} w{} h27", TabPosX + 10, tableItem.underPosY, 29),
    "Images\Soft\GreenColor.png")
    newColorCon.Visible := false
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

    newModeControl := MyGui.Add("DropDownList", Format("x{} y{} w60", TabPosX + 520, tableItem.underPosY), ["虚拟", "拟真"])
    newModeControl.value := 1
    newForbidControl := MyGui.Add("Checkbox", Format("x{} y{}", TabPosX + 590, tableItem.underPosY + 4), "禁用")
    newForbidControl.value := 0

    MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 650, tableItem.underPosY + 4), "前台:")
    newProcessNameControl := MyGui.Add("Edit", Format("x{} y{} w140", TabPosX + 690, tableItem.underPosY), "")
    newProcessNameControl.value := ""
    con := MyGui.Add("Button", Format("x{} y{} w40 h29", TabPosX + 832, tableItem.underPosY - 1), "编辑")
    con.OnEvent("Click", OnItemEditFrontInfo.Bind(tableItem, index))

    newMacroBtnControl := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 520, tableItem.underPosY + 30),
    "宏指令")
    newDeleteBtnControl := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 585, tableItem.underPosY + 30),
    "删除")
    newMacroBtnControl.OnEvent("Click", GetTableClosureAction(EditMacroAction, tableItem, index))
    newDeleteBtnControl.OnEvent("Click", GetTableClosureAction(OnTableDelete, tableItem, index))

    newRemarkTipCon := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 650, tableItem.underPosY + 37), "备注:"
    )
    newRemarkControl := MyGui.Add("Edit", Format("x{} y{} w181", TabPosX + 690, tableItem.underPosY + 32), "")
    con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 875, tableItem.underPosY), "↑")
    con.OnEvent("Click", OnTableMoveUp.Bind(tableItem, index))
    con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 875, tableItem.underPosY + 32), "↓")
    con.OnEvent("Click", OnTableMoveDown.Bind(tableItem, index))

    tableItem.LoopCountConArr.Push(newLoopCountControl)
    tableItem.MacroBtnConArr.Push(newMacroBtnControl)
    tableItem.RemarkConArr.Push(newRemarkControl)
    tableItem.RemarkTipConArr.Push(newRemarkTipCon)
    tableItem.KeyBtnConArr.Push(newKeyBtnControl)
    tableItem.DeleteBtnConArr.Push(newDeleteBtnControl)
    tableItem.TKConArr.Push(newTkControl)
    tableItem.MacroConArr.Push(newInfoControl)
    tableItem.ModeConArr.Push(newModeControl)
    tableItem.ForbidConArr.Push(newForbidControl)
    tableItem.ProcessNameConArr.Push(newProcessNameControl)
    tableItem.IndexConArr.Push(newIndexCon)
    tableItem.ColorConArr.push(newColorCon)
    tableItem.ColorStateArr.push(0)
    tableItem.TriggerTypeConArr.Push(newTriggerTypeCon)

    UpdateUnderPosY(TableIndex, heightValue)

    MySoftData.TabCtrl.UseTab()
    height := GetTabHeight()
    MySoftData.TabCtrl.Move(MySoftData.TabPosX, MySoftData.TabPosY, 910, 520)
    ; MySoftData.SB.UpdateScrollBars()
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")

    RefreshGui()
}

RefreshTabContent(tableItem) {
    for index, value in tableItem.AllConArr {
        value.UpdatePos(tableItem.OffSetPosY)
    }
}
