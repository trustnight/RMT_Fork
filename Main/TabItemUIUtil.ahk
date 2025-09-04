#Requires AutoHotkey v2.0

LoadItemFold(index) {
    tableItem := MySoftData.TableInfo[index]
    FoldInfo := tableItem.FoldInfo
    MyGui := MySoftData.MyGui
    tableItem.UnderPosY := MySoftData.TabPosY
    UpdateUnderPosY(index, 30)
    for foldIndex, IndexSpanStr in FoldInfo.IndexSpanArr {
        GroupHeight := GetFoldGroupHeight(FoldInfo, foldIndex)
        con := MyGui.Add("GroupBox", Format("x{} y{} w900 h{}", MySoftData.TabPosX + 10, tableItem.UnderPosY + 2,
            GroupHeight))
        tableItem.AllConArr.Push(ItemConInfo(con))
        tableItem.AllGroup.Push(con)
        UpdateUnderPosY(index, 20)

        con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 20, tableItem.UnderPosY + 2), "备注：")
        tableItem.AllConArr.Push(ItemConInfo(con))

        con := MyGui.Add("Edit", Format("x{} y{} w150", MySoftData.TabPosX + 60, tableItem.UnderPosY), FoldInfo.RemarkArr[
            foldIndex])
        tableItem.AllConArr.Push(ItemConInfo(con))

        con := MyGui.Add("Button", Format("x{} y{}", MySoftData.TabPosX + 230, tableItem.UnderPosY - 3), "新增宏")
        tableItem.AllConArr.Push(ItemConInfo(con))

        con := MyGui.Add("Button", Format("x{} y{}", MySoftData.TabPosX + 300, tableItem.UnderPosY - 3), "新增模块")
        con.OnEvent("Click", OnItemAddFoldBtnClick.Bind(index, FoldInfo, foldIndex))
        tableItem.AllConArr.Push(ItemConInfo(con))

        con := MyGui.Add("Button", Format("x{} y{}", MySoftData.TabPosX + 385, tableItem.UnderPosY - 3), "删除该模块")
        con.OnEvent("Click", OnItemDelFoldBtnClick.Bind(index, FoldInfo, foldIndex))
        tableItem.AllConArr.Push(ItemConInfo(con))

        con := MyGui.Add("CheckBox", Format("x{} y{}", MySoftData.TabPosX + 490, tableItem.UnderPosY + 2), "禁用")
        tableItem.AllConArr.Push(ItemConInfo(con))

        btnStr := FoldInfo.FoldStateArr[foldIndex] ? "🞃" : "❯"
        con := MyGui.Add("Button", Format("x{} y{} +BackgroundTrans", MySoftData.TabPosX + 840, tableItem.UnderPosY),
        btnStr)
        con.OnEvent("Click", OnFoldBtnClick.Bind(index, FoldInfo, foldIndex))
        tableItem.AllConArr.Push(ItemConInfo(con))

        UpdateUnderPosY(index, 40)
        IndexSpan := StrSplit(IndexSpanStr, "-")
        if (!FoldInfo.FoldStateArr[foldIndex])
            continue
        if (!IsInteger(IndexSpan[1]) || !IsInteger(IndexSpan[2]))
            continue

        LoadItemFoldTitle(index)
        loop IndexSpan[2] - IndexSpan[1] + 1 {
            curIndex := A_Index + IndexSpan[1] - 1
            LoadTabItemUI(tableItem, curIndex, false)
        }
        UpdateUnderPosY(index, 10)
    }
}

LoadItemFoldTitle(index) {
    global MySoftData
    tableItem := MySoftData.TableInfo[index]
    isNoTriggerKey := CheckIsNoTriggerKey(index)
    offsetPosx := isNoTriggerKey ? -60 : 0

    MyGui := MySoftData.MyGui
    con := MyGui.Add("Text", Format("x{} y{} w100", MySoftData.TabPosX + 30, tableItem.underPosY), "宏触发按键")
    con.Visible := !isNoTriggerKey
    tableItem.AllConArr.Push(ItemConInfo(con))

    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 130 + offsetPosx, tableItem.underPosY), "循环次数")
    tableItem.AllConArr.Push(ItemConInfo(con))
    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 215 + offsetPosx, tableItem.underPosY), "宏指令")
    tableItem.AllConArr.Push(ItemConInfo(con))
    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 525, tableItem.underPosY), "宏按键类型")
    tableItem.AllConArr.Push(ItemConInfo(con))
    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 700, tableItem.underPosY), "指定前台触发")
    tableItem.AllConArr.Push(ItemConInfo(con))
    UpdateUnderPosY(index, 25)
}

GetFoldGroupHeight(FoldInfo, index) {
    height := 60
    if (!FoldInfo.FoldStateArr[index])
        return height
    IndexSpan := StrSplit(FoldInfo.IndexSpanArr[index], "-")
    if (!IsInteger(IndexSpan[1]) || !IsInteger(IndexSpan[2]))
        return height

    height := height + 30
    height := height + (IndexSpan[2] - IndexSpan[1] + 1) * 70
    return height
}

OnAddTabItem(*) {
    global MySoftData
    TableIndex := MySoftData.TabCtrl.Value
    if (!CheckIfAddSetTable(TableIndex)) {
        MsgBox("该页签不可添加配置啊喂")
        return
    }
    tableItem := MySoftData.TableInfo[TableIndex]
    tableItem.TKArr.Push("")
    tableItem.TriggerTypeArr.Push(1)
    tableItem.MacroArr.Push("")
    tableItem.ModeArr.Push(1)
    tableItem.ForbidArr.Push(0)
    tableItem.FrontInfoArr.Push("")
    tableItem.RemarkArr.Push("")
    tableItem.LoopCountArr.Push("1")
    tableItem.HoldTimeArr.Push(500)
    tableItem.SerialArr.Push(FormatTime(, "HHmmss"))
    tableItem.TimingSerialArr.Push(GetSerialStr("Timing"))
    tableItem.IsWorkIndexArr.Push(0)

    MySoftData.TabCtrl.UseTab(TableIndex)
    itemIndex := tableItem.ModeArr.Length
    LoadTabItemUI(tableItem, itemIndex, true)
    MySoftData.TabCtrl.UseTab()
    MySlider.RefreshTab()
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")
}

LoadTabItemUI(tableItem, itemIndex, isAdd) {
    MyGui := MySoftData.MyGui
    TabPosX := MySoftData.TabPosX
    tableIndex := tableItem.Index
    isMacro := CheckIsMacroTable(tableIndex)
    isNormal := CheckIsNormalTable(tableIndex)
    isSubMacro := CheckIsSubMacroTable(tableIndex)
    isNoTriggerKey := CheckIsNoTriggerKey(tableIndex)
    isTiming := CheckIsTimingMacroTable(tableIndex)
    subMacroWidth := isNoTriggerKey ? 75 : 0
    isTriggerStr := CheckIsStringMacroTable(tableIndex)
    EditTriggerAction := isTriggerStr ? OnTableEditTriggerStr : OnTableEditTriggerKey
    EditTriggerAction := isTiming ? OnTableEditTiming : EditTriggerAction
    EditMacroAction := isMacro ? OnTableEditMacro : OnTableEditReplaceKey
    HeightValue := 70
    InfoHeight := 60

    colorCon := MyGui.Add("Pic", Format("x{} y{} w{} h27", TabPosX + 20, tableItem.underPosY, 29),
    "Images\Soft\GreenColor.png")
    colorCon.Visible := false
    tableItem.AllConArr.Push(ItemConInfo(colorCon))

    IndexCon := MyGui.Add("Text", Format("x{} y{} w{} +BackgroundTrans", TabPosX + 20, tableItem.underPosY + 5,
        30), ItemIndex ".")
    tableItem.AllConArr.Push(ItemConInfo(IndexCon))

    TriggerTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", TabPosX + 50, tableItem.underPosY, 70),
    ["按下", "松开", "松止", "开关", "长按"])
    TriggerTypeCon.Value := tableItem.TriggerTypeArr.Length >= ItemIndex ? tableItem.TriggerTypeArr[ItemIndex] : 1
    TriggerTypeCon.Enabled := isNormal
    TriggerTypeCon.Visible := isNoTriggerKey ? false : true
    tableItem.AllConArr.Push(ItemConInfo(TriggerTypeCon))

    TkCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", TabPosX + 20, tableItem.underPosY + 33, 100,),
    "")
    TkCon.Visible := isNoTriggerKey ? false : true
    TkCon.Value := tableItem.TKArr.Length >= ItemIndex ? tableItem.TKArr[ItemIndex] : ""
    tableItem.AllConArr.Push(ItemConInfo(TkCon))

    LoopCon := MyGui.Add("ComboBox", Format("x{} y{} w60 R5 center", TabPosX + 125 - subMacroWidth,
        tableItem.underPosY),
    ["无限"])
    conValue := tableItem.LoopCountArr.Length >= ItemIndex ? tableItem.LoopCountArr[ItemIndex] : "1"
    conValue := conValue == "-1" ? "无限" : conValue
    LoopCon.Text := conValue
    LoopCon.Enabled := isMacro
    tableItem.AllConArr.Push(ItemConInfo(LoopCon))

    btnStr := isTiming ? "定时" : "触发键"
    TKBtnCon := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 125 - subMacroWidth, tableItem.underPosY +
        30), btnStr)
    TKBtnCon.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, ItemIndex))
    TKBtnCon.Enabled := !isSubMacro
    tableItem.AllConArr.Push(ItemConInfo(TKBtnCon))

    MacroCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", TabPosX + 190 - subMacroWidth, tableItem.underPosY,
        335 + subMacroWidth,
        InfoHeight), "")
    MacroCon.Value := tableItem.MacroArr.Length >= ItemIndex ? tableItem.MacroArr[ItemIndex] : ""
    tableItem.AllConArr.Push(ItemConInfo(MacroCon))

    ModeCon := MyGui.Add("DropDownList", Format("x{} y{} w60 Center", TabPosX + 530, tableItem.underPosY), [
        "虚拟", "拟真"])
    ModeCon.value := tableItem.ModeArr[ItemIndex]
    tableItem.AllConArr.Push(ItemConInfo(ModeCon))

    ForbidCon := MyGui.Add("Checkbox", Format("x{} y{}", TabPosX + 600, tableItem.underPosY + 4), "禁用")
    ForbidCon.value := tableItem.ForbidArr[ItemIndex]
    tableItem.AllConArr.Push(ItemConInfo(ForbidCon))

    con := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 660, tableItem.underPosY + 4), "前台:")
    tableItem.AllConArr.Push(ItemConInfo(con))
    FrontCon := MyGui.Add("Edit", Format("x{} y{} w140", TabPosX + 700, tableItem.underPosY), "")
    FrontCon.value := tableItem.FrontInfoArr.Length >= ItemIndex ? tableItem.FrontInfoArr[ItemIndex] :
        ""
    tableItem.AllConArr.Push(ItemConInfo(FrontCon))

    con := MyGui.Add("Button", Format("x{} y{} w40 h29", TabPosX + 842, tableItem.underPosY - 1), "编辑")
    con.OnEvent("Click", OnItemEditFrontInfo.Bind(tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(con))

    MacroBtnCon := MyGui.Add("Button", Format("x{} y{} w61", TabPosX + 530, tableItem.underPosY + 30),
    "宏指令")
    MacroBtnCon.OnEvent("Click", GetTableClosureAction(EditMacroAction, tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(MacroBtnCon))

    DelCon := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 595, tableItem.underPosY + 30),
    "删除")
    DelCon.OnEvent("Click", GetTableClosureAction(OnTableDelete, tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(DelCon))

    RemarkTipCon := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 660, tableItem.underPosY + 37), "备注:"
    )
    tableItem.AllConArr.Push(ItemConInfo(RemarkTipCon))

    RemarkCon := MyGui.Add("Edit", Format("x{} y{} w181", TabPosX + 700, tableItem.underPosY + 32), ""
    )
    RemarkCon.value := tableItem.RemarkArr.Length >= ItemIndex ? tableItem.RemarkArr[ItemIndex] : ""
    tableItem.AllConArr.Push(ItemConInfo(RemarkCon))

    con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 885, tableItem.underPosY), "↑")
    con.OnEvent("Click", OnTableMoveUp.Bind(tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(con))
    con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 885, tableItem.underPosY + 32), "↓")
    con.OnEvent("Click", OnTableMoveDown.Bind(tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(con))

    tableItem.MacroBtnConArr.Push(MacroBtnCon)
    tableItem.RemarkConArr.Push(RemarkCon)
    tableItem.RemarkTipConArr.Push(RemarkTipCon)
    tableItem.LoopCountConArr.Push(LoopCon)
    tableItem.TKConArr.Push(TkCon)
    tableItem.MacroConArr.Push(MacroCon)
    tableItem.KeyBtnConArr.Push(TKBtnCon)
    tableItem.DeleteBtnConArr.Push(DelCon)
    tableItem.ModeConArr.Push(ModeCon)
    tableItem.ForbidConArr.Push(ForbidCon)
    tableItem.ProcessNameConArr.Push(FrontCon)
    tableItem.IndexConArr.Push(IndexCon)
    tableItem.ColorConArr.push(colorCon)
    tableItem.ColorStateArr.push(0)
    tableItem.TriggerTypeConArr.Push(TriggerTypeCon)
    UpdateUnderPosY(tableIndex, HeightValue)
}

;按钮事件
OnItemAddMacroBtnClick(tableIndex, foldInfo, index, *) {
    IndexSpanStr := foldInfo.IndexSpanArr[index]
    IndexSpan := StrSplit(IndexSpanStr, "-")
    if (!IsInteger(IndexSpan[1]) || !IsInteger(IndexSpan[2])) {
        foldInfo.IndexSpanArr[index] :=
    }

}

OnItemAddFoldBtnClick(tableIndex, foldInfo, index, *) {
    foldInfo.RemarkArr.InsertAt(index + 1, "")
    foldInfo.IndexSpanArr.InsertAt(index + 1, "无-无")
    foldInfo.FoldStateArr.InsertAt(index + 1, true)

    RefreshTabContent(tableIndex)
}

OnItemDelFoldBtnClick(tableIndex, foldInfo, index, *) {
    if (foldInfo.IndexSpanArr.Length == 1) {
        MsgBox("最后一个模块，不可删除！！！")
    }
    foldInfo.RemarkArr.RemoveAt(index)
    foldInfo.IndexSpanArr.RemoveAt(index)
    foldInfo.FoldStateArr.RemoveAt(index)

    RefreshTabContent(tableIndex)
}

OnFoldBtnClick(tableIndex, foldInfo, index, *) {
    tableItem := MySoftData.TableInfo[tableIndex]
    state := !foldInfo.FoldStateArr[index]
    foldInfo.FoldStateArr[index] := state

    RefreshTabContent(tableIndex)
    MySlider.SwitchTab(tableItem)
    UpdateItemConPos(tableItem, true)
}

;刷新函数
UpdateItemConPos(tableItem, isDown) {
    if (isDown) {
        for index, value in tableItem.AllConArr {
            value.UpdatePos(tableItem.OffSetPosY)
        }
    }
    else {
        loop tableItem.AllConArr.Length {
            conInfo := tableItem.AllConArr[tableItem.AllConArr.Length - A_Index + 1]
            conInfo.UpdatePos(tableItem.OffSetPosY)
        }
    }
    for index, value in tableItem.AllGroup {
        value.Redraw()
    }
}

RefreshTabContent(tableIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    for index, value in tableItem.AllConArr {
        value.Con.Visible := false
    }
    tableItem.MacroBtnConArr := []
    tableItem.RemarkConArr := []
    tableItem.RemarkTipConArr := []
    tableItem.LoopCountConArr := []
    tableItem.TKConArr := []
    tableItem.MacroConArr := []
    tableItem.KeyBtnConArr := []
    tableItem.DeleteBtnConArr := []
    tableItem.ModeConArr := []
    tableItem.ForbidConArr := []
    tableItem.ProcessNameConArr := []
    tableItem.IndexConArr := []
    tableItem.ColorConArr := []
    tableItem.ColorStateArr := []
    tableItem.TriggerTypeConArr := []
    tableItem.AllConArr := []
    tableItem.AllGroup := []

    MySoftData.TabCtrl.UseTab(tableIndex)
    LoadItemFold(tableIndex)
    MySoftData.TabCtrl.UseTab()
}

UpdateFoldInfo(FoldInfo, index, isAdd, isEntire) {
    curMaxItemIndex := 0
    for foldIndex, IndexSpanStr in FoldInfo.IndexSpanArr {
        if (index > foldIndex) {

            continue
        }
        
    }
}

;封装方法
; Get
