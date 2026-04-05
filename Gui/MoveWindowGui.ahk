#Requires AutoHotkey v2.0

class MoveWindowGui {
    __new() {
        this.ParentTile := ""
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""
        this.WinInfoCon := ""
        this.TargetXCon := ""
        this.TargetYCon := ""
        this.Data := ""
    }

    ShowGui(cmd) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }
        this.Init(cmd)
    }

    AddGui() {
        MyGui := Gui(, this.ParentTile GetLang("移动窗口编辑器"))
        this.Gui := MyGui
        MyGui.SetFont("S10 W550 Q2", MySoftData.FontType)

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 60), GetLang("快捷方式:"))
        PosX += 60
        con := MyGui.Add("Hotkey", Format("x{} y{} w{}", PosX, PosY - 3, 70), "!m")
        con.Enabled := false

        PosX += 80
        btnCon := MyGui.Add("Button", Format("x{} y{} w{}", PosX, PosY - 5, 70), GetLang("执行指令"))
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosX += 80
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 40), GetLang("备注:"))
        PosX += 40
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 130), "")

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), GetLang("窗口信息:"))
        PosX += 80
        this.WinInfoCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 190), "")

        PosX += 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{}", PosX, PosY - 5, 100), GetLang("编辑"))
        btnCon.OnEvent("Click", (*) => this.OnBindWinBtnClick())

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 60), GetLang("目标X："))
        PosX += 60
        this.TargetXCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 80), "0")

        PosX := 180
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 60), GetLang("目标Y："))
        PosX += 60
        this.TargetYCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 80), "0")

        PosX := 160
        PosY += 40
        con := MyGui.Add("Button", Format("x{} y{} w80", PosX, PosY - 5), GetLang("确定"))
        con.OnEvent("Click", (*) => this.OnSureBtnClick())

        MyGui.Show("w420 h180")
    }

    Init(cmd) {
        paramArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := paramArr.Length >= 1 ? paramArr[1] : GetCMDSerialStr("移动窗口")
        this.RemarkCon.Value := paramArr.Length >= 4 ? paramArr[4] : ""
        this.Data := GetMacroCMDData(this.SerialStr)
        this.WinInfoCon.Value := this.Data.WinInfo
        this.TargetXCon.Value := paramArr.Length >= 2 ? paramArr[2] : this.Data.TargetX
        this.TargetYCon.Value := paramArr.Length >= 3 ? paramArr[3] : this.Data.TargetY
    }

    OnBindWinBtnClick() {
        MyFrontInfoGui.ShowGui(this.WinInfoCon)
    }

    OnSureBtnClick() {
        if (!this.CheckIfValid())
            return

        this.Data.Remark := this.RemarkCon.Value
        this.Data.WinInfo := this.WinInfoCon.Value
        this.Data.TargetX := this.TargetXCon.Value
        this.Data.TargetY := this.TargetYCon.Value
        SaveMacroCMDData(this.Data)

        action := this.SureBtnAction
        action(this.GetCommandStr())
        this.Gui.Hide()
    }

    CheckIfValid() {
        if (this.WinInfoCon.Value == "") {
            MsgBox(GetLang("请先绑定窗口"))
            return false
        }
        if (!IsNumber(this.TargetXCon.Value) || !IsNumber(this.TargetYCon.Value)) {
            MsgBox(GetLang("目标坐标必须为数字"))
            return false
        }
        return true
    }

    GetCommandStr() {
        if (this.RemarkCon.Value != "")
            return Format("{}_{}_{}_{}", this.Data.SerialStr, this.TargetXCon.Value, this.TargetYCon.Value, this.RemarkCon.Value)
        else
            return Format("{}_{}_{}", this.Data.SerialStr, this.TargetXCon.Value, this.TargetYCon.Value)
    }

    TriggerMacro() {
        if (!this.CheckIfValid())
            return
        OnMoveWindow("", this.GetCommandStr(), 1)
    }
}

