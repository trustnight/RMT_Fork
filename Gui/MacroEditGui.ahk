#Requires AutoHotkey v2.0
#Include IntervalGui.ahk
#Include KeyGui.ahk
#Include MouseMoveGui.ahk
#Include SearchGui.ahk
#Include SearchProGui.ahk
#Include FileGui.ahk
#Include CompareGui.ahk
#Include MMProGui.ahk
#Include OutputGui.ahk
#Include StopGui.ahk
#Include VariableGui.ahk
#Include SubMacroGui.ahk
#Include OperationGui.ahk
#Include BGMouseGui.ahk
#Include ExVariableGui.ahk
#Include RMTCMDGui.ahk

class MacroEditGui {
    __new() {
        this.Gui := ""
        this.ShowSaveBtn := false
        this.SureFocusCon := ""
        this.VariableObjArr := []
        this.isContextEdit := false
        this.RecordToggleCon := ""

        this.SureBtnAction := ""
        this.SaveBtnAction := ""
        this.SaveBtnCtrl := {}
        this.CmdBtnConMap := map()
        this.SubGuiMap := map()
        this.NeedCommandInterval := false
        this.MacroTreeViewCon := ""
        this.EditModeType := 1  ;1添加指令 2修改当前指令 3向上插入指令 4 向下插入指令
        this.CutItemID := ""  ;当前操作itemID
        this.LastItemID := "" ;最后的itemID
        this.RecordMacroCon := ""
        this.DefaultFocusCon := ""
        this.SubMacroLastIndex := 0

        this.RecordKeyboardArr := []
        this.RecordNodeArr := []

        this.InitSubGui()
    }

    InitSubGui() {
        this.IntervalGui := IntervalGui()
        this.IntervalGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("间隔", this.IntervalGui)

        this.KeyGui := KeyGui()
        this.KeyGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("按键", this.KeyGui)

        this.MoveMoveGui := MouseMoveGui()
        this.MoveMoveGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("移动", this.MoveMoveGui)

        this.SearchGui := SearchGui()
        this.SearchGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("搜索", this.SearchGui)

        this.SearchProGui := SearchProGui()
        this.SearchProGui.MacroEditGui := this
        this.SearchProGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("搜索Pro", this.SearchProGui)

        this.FileGui := FileGui()
        this.FileGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("文件", this.FileGui)

        this.CompareGui := CompareGui()
        this.CompareGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.CompareGui.MacroEditGui := this
        this.SubGuiMap.Set("如果", this.CompareGui)

        this.MMProGui := MMProGui()
        this.MMProGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("移动Pro", this.MMProGui)

        this.OutputGui := OutputGui()
        this.OutputGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("输出", this.OutputGui)

        this.StopGui := StopGui()
        this.StopGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("终止", this.StopGui)

        this.VariableGui := VariableGui()
        this.VariableGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("变量", this.VariableGui)

        this.ExVariableGui := ExVariableGui()
        this.ExVariableGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("变量提取", this.ExVariableGui)

        this.SubMacroGui := SubMacroGui()
        this.SubMacroGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("子宏", this.SubMacroGui)

        this.OperationGui := OperationGui()
        this.OperationGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("运算", this.OperationGui)

        this.BGMouseGui := BGMouseGui()
        this.BGMouseGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("后台鼠标", this.BGMouseGui)

        this.RMTCMDGui := RMTCMDGui()
        this.RMTCMDGui.SureBtnAction := (CommandStr) => this.OnSubGuiSureBtnClick(CommandStr)
        this.SubGuiMap.Set("RMT指令", this.RMTCMDGui)
    }

    ShowGui(CommandStr, ShowSaveBtn) {
        global MySoftData
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        MySoftData.RecordToggleCon := this.RecordMacroCon
        this.Init(CommandStr, ShowSaveBtn)
    }

    AddGui() {
        MyGui := Gui(, "指令编辑器")
        this.Gui := MyGui
        MyGui.SetFont("S10 W550 Q2", MySoftData.FontType)

        PosX := 10
        PosY := 10
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", PosX, PosY, 800, 170), "当前宏指令")
        PosY += 15
        this.MacroTreeViewCon := MyGui.Add("TreeView", Format("x{} y{} w{} h{}", PosX + 5, PosY, 790, 150), "")

        PosX := 20
        PosY += 160
        this.RecordMacroCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{}", PosX, PosY - 3, 110, 20), "指令并联录制")
        this.RecordMacroCon.Value := false
        this.RecordMacroCon.OnEvent("Click", (*) => this.OnChangeRecordMode())

        PosX += 120
        isHotKey := CheckIsHotKey(ToolCheckInfo.ToolRecordMacroHotKey)
        CtrlType := isHotKey ? "Hotkey" : "Text"
        con := MyGui.Add(CtrlType, Format("x{} y{} w{} h{}", posX, posY - 3, 100, 20), ToolCheckInfo.ToolRecordMacroHotKey
        )
        con.Enabled := false

        PosY += 20
        PosX := 10
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", 10, PosY, 800, 150), "指令选项")

        PosY += 20
        PosX := 20
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "间隔")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.IntervalGui))
        this.CmdBtnConMap.Set("间隔", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "按键")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.KeyGui))
        this.CmdBtnConMap.Set("按键", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "搜索")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.SearchGui))
        this.CmdBtnConMap.Set("搜索", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "搜索Pro")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.SearchProGui))
        this.CmdBtnConMap.Set("搜索Pro", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "移动")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.MoveMoveGui))
        this.CmdBtnConMap.Set("移动", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "移动Pro")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.MMProGui))
        this.CmdBtnConMap.Set("移动Pro", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "输出")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.OutputGui))
        this.CmdBtnConMap.Set("输出", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "文件")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.FileGui))
        this.CmdBtnConMap.Set("文件", btnCon)

        PosY += 35
        PosX := 20
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "变量")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.VariableGui))
        this.CmdBtnConMap.Set("变量", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "变量提取")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.ExVariableGui))
        this.CmdBtnConMap.Set("变量提取", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "运算")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.OperationGui))
        this.CmdBtnConMap.Set("运算", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "如果")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.CompareGui))
        this.CmdBtnConMap.Set("如果", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "终止")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.StopGui))
        this.CmdBtnConMap.Set("终止", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "子宏")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.SubMacroGui))
        this.CmdBtnConMap.Set("子宏", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "后台鼠标")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.BGMouseGui))
        this.CmdBtnConMap.Set("后台鼠标", btnCon)

        PosX += 100
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 30, 80), "RMT指令")
        btnCon.SetFont((Format("S{} W{} Q{}", 12, 400, 5)))
        btnCon.OnEvent("Click", (*) => this.OnOpenSubGui(this.RMTCMDGui))
        this.CmdBtnConMap.Set("RMT指令", btnCon)

        PosX := 20
        PosY += 110
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "Backspace")
        btnCon.OnEvent("Click", (*) => this.Backspace())

        PosX += 200
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "清空指令")
        btnCon.OnEvent("Click", (*) => this.ClearStr())

        PosX += 200
        btnCon := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "确定")
        btnCon.OnEvent("Click", (*) => this.OnSureBtnClick())

        PosX += 200
        this.SaveBtnCtrl := MyGui.Add("Button", Format("x{} y{} h{} w{} center", PosX, PosY, 40, 100), "应用并保存")
        this.SaveBtnCtrl.OnEvent("Click", (*) => this.OnSaveBtnClick())

        MyGui.Show(Format("w{} h{}", 820, 420))
    }

    Init(CommandStr, ShowSaveBtn) {
        this.ShowSaveBtn := ShowSaveBtn
        this.SubMacroLastIndex := 0
        this.SaveBtnCtrl.Visible := this.ShowSaveBtn
        this.InitTreeView(CommandStr)
    }

    Backspace() {

    }

    ClearStr() {

    }

    OnSaveBtnClick() {
        macroStr := this.GetMacroStr()
        action := this.SureBtnAction
        action(macroStr)

        this.SureBtnAction := ""
        this.Gui.Hide()

        action := this.SaveBtnAction
        action()
        this.SureFocusCon.Focus()
    }

    OnSureBtnClick() {
        macroStr := this.GetMacroStr()
        action := this.SureBtnAction
        action(macroStr)

        this.SureBtnAction := ""
        this.Gui.Hide()
        this.SureFocusCon.Focus()
    }

    OnChangeRecordMode() {
        state := this.RecordMacroCon.Value
        OnToolRecordMacro()
    }

    InitTreeView(CommandStr) {
        cmdArr := SplitMacro(CommandStr)
        this.MacroTreeViewCon.Delete()
        for cmdStr in cmdArr {
            root := this.MacroTreeViewCon.Add(cmdStr)
            ; this.TreeAddBranch(root, cmdStr)
        }
    }

    TreeAddBranch(root, cmdStr) {
        paramArr := StrSplit(cmdStr, "_")
        IsSearch := StrCompare(paramArr[1], "搜索", false) == 0
        IsSearchPro := StrCompare(paramArr[1], "搜索Pro", false) == 0
        IsIf := StrCompare(paramArr[1], "如果", false) == 0
        if (!IsSearch && !IsSearchPro && !IsIf)
            return

        if (IsSearch || IsSearchPro) {

        }
    }

    ;打开子指令编辑器
    OnOpenSubGui(subGui, modeType := 1) {
        this.EditModeType := modeType
        if (modeType == 2) {
            CommandStr := this.MacroTreeViewCon.GetText(this.CutItemID)
            subGui.ShowGui(CommandStr)
            return
        }

        if ObjHasOwnProp(subGui, "VariableObjArr") {
            macroStr := this.GetMacroStr()
            VariableObjArr := GetGuiVariableObjArr(macroStr, this.VariableObjArr)
            subGui.VariableObjArr := VariableObjArr
        }

        subGui.ShowGui("")
    }

    ;确定子指令编辑器
    OnSubGuiSureBtnClick(CommandStr) {
        if (this.EditModeType == 1) {
            this.OnAddCmd(CommandStr)
        }
        else if (this.EditModeType == 2) {
            this.OnModifyCmd(CommandStr)
        }
        else if (this.EditModeType == 3) {
            this.OnPreInsertCmd(CommandStr)
        }
        else if (this.EditModeType == 4) {
            this.OnNextInsertCmd(CommandStr)
        }
    }

    ;添加指令
    OnAddCmd(CommandStr) {
        root := this.MacroTreeViewCon.Add(CommandStr)
        ; this.TreeAddBranch(root, CommandStr)
    }

    ;插入指令
    OnPreInsertCmd(CommandStr) {

    }

    ;插入指令
    OnNextInsertCmd(CommandStr) {

    }

    ;修改指令
    OnModifyCmd(CommandStr) {

    }

    GetMacroStr() {
        macroStr := ""
        rootItemID := this.MacroTreeViewCon.GetChild(0)
        while (rootItemID) {
            cmdStr := this.MacroTreeViewCon.GetText(rootItemID)
            macroStr .= cmdStr ","
            rootItemID := this.MacroTreeViewCon.GetNext(rootItemID)
        }
        macroStr := Trim(macroStr, ",")
        return macroStr
    }
}
