#Requires AutoHotkey v2.0

LoadItemFold(index) {
    tableItem := MySoftData.TableInfo[index]
    FoldInfo := tableItem.FoldInfo
    MyGui := MySoftData.MyGui
    tableItem.UnderPosY := MySoftData.TabPosY
    tableItem.FoldOffsetArr := []
    tableItem.FoldBtnArr := []
    UpdateUnderPosY(index, 30)
    for foldIndex, IndexSpanStr in FoldInfo.IndexSpanArr {
        tableItem.FoldOffsetArr.Push(0)
        LoadItemFoldTitle(index, foldIndex, tableItem.UnderPosY)
        UpdateUnderPosY(index, 55)
        IndexSpan := StrSplit(IndexSpanStr, "-")
        if (!FoldInfo.FoldStateArr[foldIndex])
            continue
        if (!IsInteger(IndexSpan[1]) || !IsInteger(IndexSpan[2]))
            continue

        LoadItemFoldTip(index, foldIndex, tableItem.UnderPosY)
        UpdateUnderPosY(index, 25)
        loop IndexSpan[2] - IndexSpan[1] + 1 {
            curIndex := A_Index + IndexSpan[1] - 1
            LoadTabItemUI(tableItem, curIndex, foldIndex, tableItem.UnderPosY)
            UpdateUnderPosY(index, 70)
        }
        UpdateUnderPosY(index, 5)
    }
}

LoadItemFoldTitle(tableIndex, foldIndex, PosY) {
    tableItem := MySoftData.TableInfo[tableIndex]
    FoldInfo := tableItem.FoldInfo
    MyGui := MySoftData.MyGui

    GroupHeight := GetFoldGroupHeight(FoldInfo, foldIndex)
    con := MyGui.Add("GroupBox", Format("x{} y{} w900 h{}", MySoftData.TabPosX + 10, posY + 2,
        GroupHeight))
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex, true))
    tableItem.AllGroup.Push(con)
    PosY += 20

    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 20, posY + 2), "备注：")
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex, true))

    con := MyGui.Add("Edit", Format("x{} y{} w150", MySoftData.TabPosX + 60, posY), FoldInfo.RemarkArr[
        foldIndex])
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex, true))

    con := MyGui.Add("Button", Format("x{} y{}", MySoftData.TabPosX + 230, posY - 3), "新增宏")
    con.OnEvent("Click", OnItemAddMacroBtnClick.Bind(tableIndex, FoldInfo, foldIndex))
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex, true))

    con := MyGui.Add("Button", Format("x{} y{}", MySoftData.TabPosX + 300, posY - 3), "新增模块")
    con.OnEvent("Click", OnItemAddFoldBtnClick.Bind(tableIndex, FoldInfo, foldIndex))
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex, true))

    con := MyGui.Add("Button", Format("x{} y{}", MySoftData.TabPosX + 385, posY - 3), "删除该模块")
    con.OnEvent("Click", OnItemDelFoldBtnClick.Bind(tableIndex, FoldInfo, foldIndex))
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex, true))

    con := MyGui.Add("CheckBox", Format("x{} y{}", MySoftData.TabPosX + 490, posY + 2), "禁用")
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex, true))

    btnStr := FoldInfo.FoldStateArr[foldIndex] ? "🞃" : "❯"
    con := MyGui.Add("Button", Format("x{} y{} +BackgroundTrans", MySoftData.TabPosX + 840, posY),
    btnStr)
    con.OnEvent("Click", OnFoldBtnClick.Bind(tableIndex, FoldInfo, foldIndex))
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex, true))
    tableItem.FoldBtnArr.InsertAt(foldIndex, con)
}

LoadItemFoldTip(tableIndex, foldIndex, PosY) {
    global MySoftData
    tableItem := MySoftData.TableInfo[tableIndex]
    isNoTriggerKey := CheckIsNoTriggerKey(tableIndex)
    offsetPosx := isNoTriggerKey ? -60 : 0

    MyGui := MySoftData.MyGui
    con := MyGui.Add("Text", Format("x{} y{} w100", MySoftData.TabPosX + 30, posY), "宏触发按键")
    con.Visible := !isNoTriggerKey
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex))

    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 130 + offsetPosx, posY), "循环次数")
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex))
    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 215 + offsetPosx, posY), "宏指令")
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex))
    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 525, posY), "宏按键类型")
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex))
    con := MyGui.Add("Text", Format("x{} y{}", MySoftData.TabPosX + 700, posY), "指定前台触发")
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex))
}

LoadTabItemUI(tableItem, itemIndex, foldIndex, PosY) {
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
    InfoHeight := 60

    colorCon := MyGui.Add("Pic", Format("x{} y{} w{} h27", TabPosX + 20, posY, 29),
    "Images\Soft\GreenColor.png")
    colorCon.Visible := false
    tableItem.AllConArr.Push(ItemConInfo(colorCon, tableItem, foldIndex))

    IndexCon := MyGui.Add("Text", Format("x{} y{} w{} +BackgroundTrans", TabPosX + 20, posY + 5,
        30), ItemIndex ".")
    tableItem.AllConArr.Push(ItemConInfo(IndexCon, tableItem, foldIndex))

    TriggerTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", TabPosX + 50, posY, 70),
    ["按下", "松开", "松止", "开关", "长按"])
    TriggerTypeCon.Value := tableItem.TriggerTypeArr[ItemIndex]
    TriggerTypeCon.Enabled := isNormal
    TriggerTypeCon.Visible := isNoTriggerKey ? false : true
    tableItem.AllConArr.Push(ItemConInfo(TriggerTypeCon, tableItem, foldIndex))

    TkCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", TabPosX + 20, posY + 33, 100,),
    "")
    TkCon.Visible := isNoTriggerKey ? false : true
    TkCon.Value := tableItem.TKArr[ItemIndex]
    tableItem.AllConArr.Push(ItemConInfo(TkCon, tableItem, foldIndex))

    LoopCon := MyGui.Add("ComboBox", Format("x{} y{} w60 R5 center", TabPosX + 125 - subMacroWidth,
        posY),
    ["无限"])
    conValue := tableItem.LoopCountArr[ItemIndex]
    conValue := conValue == "-1" ? "无限" : conValue
    LoopCon.Text := conValue
    LoopCon.Enabled := isMacro
    tableItem.AllConArr.Push(ItemConInfo(LoopCon, tableItem, foldIndex))

    btnStr := isTiming ? "定时" : "触发键"
    TKBtnCon := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 125 - subMacroWidth, posY +
        30), btnStr)
    TKBtnCon.OnEvent("Click", GetTableClosureAction(EditTriggerAction, tableItem, ItemIndex))
    TKBtnCon.Enabled := !isSubMacro
    tableItem.AllConArr.Push(ItemConInfo(TKBtnCon, tableItem, foldIndex))

    MacroCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", TabPosX + 190 - subMacroWidth, posY,
        335 + subMacroWidth,
        InfoHeight), "")
    MacroCon.Value := tableItem.MacroArr[ItemIndex]
    tableItem.AllConArr.Push(ItemConInfo(MacroCon, tableItem, foldIndex))

    ModeCon := MyGui.Add("DropDownList", Format("x{} y{} w60 Center", TabPosX + 530, posY), [
        "虚拟", "拟真"])
    ModeCon.value := tableItem.ModeArr[ItemIndex]
    tableItem.AllConArr.Push(ItemConInfo(ModeCon, tableItem, foldIndex))

    ForbidCon := MyGui.Add("Checkbox", Format("x{} y{}", TabPosX + 600, posY + 4), "禁用")
    ForbidCon.value := tableItem.ForbidArr[ItemIndex]
    tableItem.AllConArr.Push(ItemConInfo(ForbidCon, tableItem, foldIndex))

    con := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 660, posY + 4), "前台:")
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex))
    FrontCon := MyGui.Add("Edit", Format("x{} y{} w140", TabPosX + 700, posY), "")
    FrontCon.value := tableItem.FrontInfoArr[ItemIndex]
    tableItem.AllConArr.Push(ItemConInfo(FrontCon, tableItem, foldIndex))

    con := MyGui.Add("Button", Format("x{} y{} w40 h29", TabPosX + 842, posY - 1), "编辑")
    con.OnEvent("Click", OnItemEditFrontInfo.Bind(tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex))

    MacroBtnCon := MyGui.Add("Button", Format("x{} y{} w61", TabPosX + 530, posY + 30),
    "宏指令")
    MacroBtnCon.OnEvent("Click", GetTableClosureAction(EditMacroAction, tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(MacroBtnCon, tableItem, foldIndex))

    DelCon := MyGui.Add("Button", Format("x{} y{} w60", TabPosX + 595, posY + 30),
    "删除")
    DelCon.OnEvent("Click", GetTableClosureAction(OnTableDelete, tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(DelCon, tableItem, foldIndex))

    RemarkTipCon := MyGui.Add("Text", Format("x{} y{} w60", TabPosX + 660, posY + 37), "备注:"
    )
    tableItem.AllConArr.Push(ItemConInfo(RemarkTipCon, tableItem, foldIndex))

    RemarkCon := MyGui.Add("Edit", Format("x{} y{} w181", TabPosX + 700, posY + 32), ""
    )
    RemarkCon.value := tableItem.RemarkArr[ItemIndex]
    tableItem.AllConArr.Push(ItemConInfo(RemarkCon, tableItem, foldIndex))

    con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 885, posY), "↑")
    con.OnEvent("Click", OnTableMoveUp.Bind(tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex))
    con := MyGui.Add("Button", Format("x{} y{} w20 h28", TabPosX + 885, posY + 32), "↓")
    con.OnEvent("Click", OnTableMoveDown.Bind(tableItem, ItemIndex))
    tableItem.AllConArr.Push(ItemConInfo(con, tableItem, foldIndex))

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
}

;按钮事件
;增加宏配置
OnItemAddMacroBtnClick(tableIndex, foldInfo, foldIndex, *) {
    if (!foldInfo.FoldStateArr[foldIndex])  ;没开打的话，自动打开
        OnFoldBtnClick(tableIndex, foldInfo, foldIndex)

    isFirst := foldInfo.IndexSpanArr[foldIndex] == "无-无"
    curIndex := UpdateFoldInfo(foldInfo, foldIndex, true)
    tableItem := MySoftData.TableInfo[TableIndex]
    tableItem.TKArr.InsertAt(curIndex, "")
    tableItem.TriggerTypeArr.InsertAt(curIndex, 1)
    tableItem.MacroArr.InsertAt(curIndex, "")
    tableItem.ModeArr.InsertAt(curIndex, 1)
    tableItem.ForbidArr.InsertAt(curIndex, 0)
    tableItem.FrontInfoArr.InsertAt(curIndex, "")
    tableItem.RemarkArr.InsertAt(curIndex, "")
    tableItem.LoopCountArr.InsertAt(curIndex, "1")
    tableItem.HoldTimeArr.InsertAt(curIndex, 500)
    tableItem.SerialArr.InsertAt(curIndex, FormatTime(, "HHmmss"))
    tableItem.TimingSerialArr.InsertAt(curIndex, GetSerialStr("Timing"))
    tableItem.IsWorkIndexArr.InsertAt(curIndex, 0)

    PosY := 1000000
    for index, value in tableItem.AllConArr {
        if (foldIndex == value.FoldIndex && PosY > value.OriPosY)
            PosY := value.OriPosY
    }

    PosY += 55
    if (isFirst) {
        MySoftData.TabCtrl.UseTab(tableIndex)
        LoadItemFoldTip(tableIndex, foldIndex, PosY)
        LoadTabItemUI(tableItem, curIndex, foldIndex, PosY + 25)
        MySoftData.TabCtrl.UseTab()
    }
    else {
        IndexSpan := StrSplit(foldInfo.IndexSpanArr[foldIndex], "-")
        PosY += (IndexSpan[2] - IndexSpan[1]) * 70 + 25
        MySoftData.TabCtrl.UseTab(tableIndex)
        LoadTabItemUI(tableItem, curIndex, foldIndex, PosY)
        MySoftData.TabCtrl.UseTab()
    }

    afterHei := GetFoldGroupHeight(foldInfo, foldIndex)
    tableItem.AllGroup[foldIndex].Move(, , , afterHei)

    addHei := isFirst ? 100 : 70
    tableItem.FoldOffsetArr[foldIndex] += addHei
    MySlider.RefreshTab()
}

;增加宏模块
OnItemAddFoldBtnClick(tableIndex, foldInfo, index, *) {
    foldInfo.RemarkArr.InsertAt(index + 1, "")
    foldInfo.IndexSpanArr.InsertAt(index + 1, "无-无")
    foldInfo.FoldStateArr.InsertAt(index + 1, true)
    tableItem := MySoftData.TableInfo[tableIndex]

    ; RefreshTabContent(tableIndex)
    MySlider.RefreshTab()
}

OnItemDelFoldBtnClick(tableIndex, foldInfo, index, *) {
    if (foldInfo.IndexSpanArr.Length == 1) {
        MsgBox("最后一个模块，不可删除！！！")
    }
    foldInfo.RemarkArr.RemoveAt(index)
    foldInfo.IndexSpanArr.RemoveAt(index)
    foldInfo.FoldStateArr.RemoveAt(index)
    tableItem := MySoftData.TableInfo[tableIndex]

    ; RefreshTabContent(tableIndex)
    MySlider.SwitchTab(tableItem)
    UpdateItemConPos(tableItem, true)
}

OnFoldBtnClick(tableIndex, foldInfo, index, *) {
    tableItem := MySoftData.TableInfo[tableIndex]
    beforeHei := GetFoldGroupHeight(foldInfo, index)
    state := !foldInfo.FoldStateArr[index]
    foldInfo.FoldStateArr[index] := state
    afterHei := GetFoldGroupHeight(foldInfo, index)
    tableItem.FoldOffsetArr[index] += afterHei - beforeHei

    btnStr := FoldInfo.FoldStateArr[index] ? "🞃" : "❯"
    tableItem.FoldBtnArr[index].Text := btnStr

    tableItem.AllGroup[index].Move(, , , afterHei)

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

UpdateFoldInfo(FoldInfo, Index, IsAdd) {
    curMaxItemIndex := 0
    CurIndex := 0
    for foldIndex, IndexSpanStr in FoldInfo.IndexSpanArr {
        IndexSpan := StrSplit(IndexSpanStr, "-")
        if (foldIndex < Index) {
            if (IsInteger(IndexSpan[1]) && IsInteger(IndexSpan[2])) {
                curMaxItemIndex := IndexSpan[2]
            }
            continue
        }
        if (foldIndex == Index) {
            if (IsAdd) {
                ;已经存在后面数字加1
                if (IsInteger(IndexSpan[1]) && IsInteger(IndexSpan[2])) {
                    IndexSpan[2] := IndexSpan[2] + 1
                }
                else {  ;不存在直接初始化
                    IndexSpan[1] := curMaxItemIndex + 1
                    IndexSpan[2] := curMaxItemIndex + 1
                }
                FoldInfo.IndexSpanArr[foldIndex] := IndexSpan[1] "-" IndexSpan[2]
            }
            else {
                IndexSpan[2] := IndexSpan[2] - 1
                if (IndexSpan[2] < IndexSpan[1]) {
                    IndexSpan[1] := "无"
                    IndexSpan[2] := "无"
                }
                FoldInfo.IndexSpanArr[foldIndex] := IndexSpan[1] "-" IndexSpan[2]
            }
            CurIndex := IndexSpan[2]
        }
        if (foldIndex > Index) {
            Value := IsAdd ? 1 : -1
            if (IsInteger(IndexSpan[1]) && IsInteger(IndexSpan[2])) {
                IndexSpan[1] := IndexSpan[1] + Value
                IndexSpan[2] := IndexSpan[2] + Value
            }
        }
    }
    return CurIndex
}

;封装方法
GetFoldGroupHeight(FoldInfo, index) {
    height := 55
    if (!FoldInfo.FoldStateArr[index])
        return height
    IndexSpan := StrSplit(FoldInfo.IndexSpanArr[index], "-")
    if (!IsInteger(IndexSpan[1]) || !IsInteger(IndexSpan[2]))
        return height

    height := height + 30
    height := height + (IndexSpan[2] - IndexSpan[1] + 1) * 70
    return height
}

DestroyCtrl(ctrl) {
    if ctrl && ctrl.Hwnd
        DllCall("User32\DestroyWindow", "ptr", ctrl.Hwnd)
    ; 立刻丢弃引用，防止后续误用
    ctrl := ""
}
