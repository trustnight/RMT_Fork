#Requires AutoHotkey v2.0
#Include MacroEditGui.ahk

class CompareProGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""
        this.MacroGui := ""
        this.VariableObjArr := []
        this.FocusCon := ""

        this.CompareTypeStrArr := ["大于", "大于等于", "等于", "小于等于",
            "小于", "字符包含", "变量存在"]
        this.ItemMap := Map()

        this.Data := ""
        this.VariNameCon := ""
    }

    ShowGui(cmd) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        this.Init(cmd)
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "如果Pro指令编辑")
        this.Gui := MyGui
        MyGui.SetFont("S10 W550 Q2", MySoftData.FontType)

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "快捷方式:")
        PosX += 70
        con := MyGui.Add("Hotkey", Format("x{} y{} w{}", PosX, PosY - 3, 70), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{}", PosX, PosY - 5, 80), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosX += 90
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 50), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY - 2, 80, 20), "变量:")

        PosX += 45
        this.VariNameCon := MyGui.Add("ComboBox", Format("x{} y{} w{}", PosX, PosY - 5, 120), [])

        PosX := 10
        PosY += 30
        this.LVCon := MyGui.Add("ListView", Format("x{} y{} w450 h250 -LV0x10 NoSort", PosX, PosY), ["条件", "指令"])
        this.LVCon.OnEvent("ContextMenu", this.ShowContextMenu.Bind(this))
        this.LVCon.OnEvent("DoubleClick", this.OnDoubleClick.Bind(this))
        ; 设置列宽（单位：px）
        this.LVCon.ModifyCol(1, 160) ; 第一列宽度
        this.LVCon.ModifyCol(2, 260) ; 自动填充剩余宽度

        PosY += 265
        PosX := 180
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())
        this.FocusCon := btnCon

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 470, 400))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : GetSerialStr("ComparePro")
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetCompareProData(this.SerialStr)

        this.VariNameCon.Delete()
        this.VariNameCon.Add(this.VariableObjArr)
        this.VariNameCon.Text := this.Data.VariName
        this.LVCon.Delete()
        loop this.Data.MacroArr.Length {
            condiStr := this.CompareTypeStrArr[this.Data.CompareTypeArr[A_Index]] " " this.Data.VariableArr[A_Index]
            macro := this.Data.MacroArr[A_Index]
            item := this.LVCon.Add(, condiStr, macro)
            this.ItemMap[item] := A_Index
        }
        item := this.LVCon.Add(, "以上都不是", this.Data.DefaultMacro)
        this.ItemMap[item] := this.Data.MacroArr.Length + 1
    }

    Refresh() {
        this.LVCon.Opt("-Redraw")
        count := this.LVCon.GetCount()
        LVKeys := Map()
        loop count {
            row := count - A_Index + 1
            key := this.LVCon.GetText(row, 1)
            value := this.LVCon.GetText(row, 2)
            if !MySoftData.VariableMap.Has(key)
                this.LVCon.Delete(row)
            else if (String(MySoftData.VariableMap[key]) != value)
                this.LVCon.Delete(row)
            else
                LVKeys[key] := True
        }

        ; 3) 添加 Map 中有但 LV 没有的项
        for key, value in MySoftData.VariableMap {
            if !LVKeys.Has(key) {
                this.LVCon.Add(, key, value)
            }
        }
        this.LVCon.Opt("+Redraw")
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            Hotkey("!l", MacroAction, "On")
        }
        else {
            Hotkey("!l", MacroAction, "Off")
        }
    }

    ShowContextMenu(ctrl, item, isRightClick, x, y) {
        if (item == 0)
            return
        MsgBox(this.ItemMap[item])
    }

    OnDoubleClick(ctrl, item) {
        if (item == 0)
            return
        MsgBox(this.ItemMap[item])
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveCompareProData()
        this.ToggleFunc(false)
        CommandStr := this.GetCommandStr()
        action := this.SureBtnAction
        action(CommandStr)
        this.Gui.Hide()
    }

    CheckIfValid() {
        return true
    }

    TriggerMacro() {
        this.SaveCompareProData()
        CommandStr := this.GetCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.KilledArr[1] := false
        tableItem.PauseArr[1] := 0
        tableItem.ActionCount[1] := 0
        tableItem.VariableMapArr[1] := Map()
        tableItem.index := 1

        OnComparePro(tableItem, CommandStr, 1)
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "如果Pro_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }

        return CommandStr
    }

    GetCompareProData(SerialStr) {
        saveStr := IniRead(CompareProFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := CompareProData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveCompareProData() {
        this.Data.VariName := this.VariNameCon.Text
        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, CompareProFile, IniSection, this.Data.SerialStr)
        if (MySoftData.DataCacheMap.Has(this.Data.SerialStr)) {
            MySoftData.DataCacheMap.Delete(this.Data.SerialStr)
        }
    }
}
