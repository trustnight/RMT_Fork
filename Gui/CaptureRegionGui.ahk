#Requires AutoHotkey v2.0

class CaptureRegionGui {
    __new() {
        this.ParentTile := ""
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""
        this.CaptureNameCon := ""
        this.StartPosXCon := ""
        this.StartPosYCon := ""
        this.EndPosXCon := ""
        this.EndPosYCon := ""
        this.Data := ""
        this.SelectToggleCon := ""
        this.MousePosCon := ""
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
        MyGui := Gui(, this.ParentTile GetLang("抓图编辑器"))
        this.Gui := MyGui
        MyGui.SetFont("S10 W550 Q2", MySoftData.FontType)

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 60), GetLang("快捷方式:"))
        PosX += 60
        con := MyGui.Add("Hotkey", Format("x{} y{} w{}", PosX, PosY - 3, 70), "!c")
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
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), GetLang("抓图名称:"))
        PosX += 80
        this.CaptureNameCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 150), "")
        PosX += 160
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 200), GetLang("(默认从captureregion1开始)"))

        PosY += 30
        PosX := 10
        this.SelectToggleCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Left", PosX, PosY, 150, 25), GetLang("左键框选区域"))
        this.SelectToggleCon.OnEvent("Click", (*) => this.OnClickSelectToggle())
        PosX += 160
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 50), "F1")
        PosX += 60
        MyGui.Add("Text", Format("x{} y{} h{} Center", PosX, PosY + 3, 25), GetLang("框选区域"))

        PosY += 30
        PosX := 10
        this.MousePosCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 230, 20), GetLang("当前鼠标坐标：0,0"))
        SetTimer ObjBindMethod(this, "RefreshMouseInfo"), 100

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), GetLang("起始坐标X："))
        PosX += 80
        this.StartPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 80), "0")
        PosX := 180
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), GetLang("起始坐标Y："))
        PosX += 80
        this.StartPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 80), "0")

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), GetLang("终止坐标X："))
        PosX += 80
        this.EndPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 80), A_ScreenWidth)
        PosX := 180
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), GetLang("终止坐标Y："))
        PosX += 80
        this.EndPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 80), A_ScreenHeight)

        PosX := 160
        PosY += 40
        con := MyGui.Add("Button", Format("x{} y{} w80", PosX, PosY - 5), GetLang("确定"))
        con.OnEvent("Click", (*) => this.OnSureBtnClick())

        MyGui.OnEvent("Close", (*) => this.OnClose())
        MyGui.Show("w500 h250")
        
        ; 注册 F1 热键
        Hotkey("F1", (*) => this.OnF1(), "On")
        this.HotkeyRegistered := true
    }

    Init(cmd) {
        paramArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := paramArr.Length >= 1 ? paramArr[1] : GetCMDSerialStr("抓图")
        this.RemarkCon.Value := paramArr.Length >= 6 ? paramArr[6] : ""
        this.Data := GetMacroCMDData(this.SerialStr)
        this.CaptureNameCon.Value := paramArr.Length >= 2 ? paramArr[2] : this.Data.CaptureName
        this.StartPosXCon.Value := paramArr.Length >= 3 ? paramArr[3] : this.Data.StartPosX
        this.StartPosYCon.Value := paramArr.Length >= 4 ? paramArr[4] : this.Data.StartPosY
        this.EndPosXCon.Value := paramArr.Length >= 5 ? paramArr[5] : this.Data.EndPosX
        this.EndPosYCon.Value := paramArr.Length >= 6 ? paramArr[6] : this.Data.EndPosY
    }

    OnClickSelectToggle() {
        state := this.SelectToggleCon.Value
        if (state == 1)
            TogSelectArea(true, this.OnSetArea.Bind(this))
        else
            TogSelectArea(false)
    }

    OnSetArea(x1, y1, x2, y2) {
        this.SelectToggleCon.Value := 0
        this.StartPosXCon.Value := x1
        this.StartPosYCon.Value := y1
        this.EndPosXCon.Value := x2
        this.EndPosYCon.Value := y2
    }

    RefreshMouseInfo() {
        try {
            CoordMode("Mouse", "Screen")
            MouseGetPos &mouseX, &mouseY
            this.MousePosCon.Value := Format("{}{},{}", GetLang("当前鼠标坐标："), mouseX, mouseY)
        }
    }

    OnSureBtnClick() {
        if (!this.CheckIfValid())
            return

        this.Data.Remark := this.RemarkCon.Value
        this.Data.CaptureName := this.CaptureNameCon.Value
        this.Data.StartPosX := this.StartPosXCon.Value
        this.Data.StartPosY := this.StartPosYCon.Value
        this.Data.EndPosX := this.EndPosXCon.Value
        this.Data.EndPosY := this.EndPosYCon.Value
        SaveMacroCMDData(this.Data)

        action := this.SureBtnAction
        action(this.GetCommandStr())
        this.Gui.Hide()
    }

    CheckIfValid() {
        if (!IsNumber(this.StartPosXCon.Value) || !IsNumber(this.StartPosYCon.Value) || !IsNumber(this.EndPosXCon.Value) || !IsNumber(this.EndPosYCon.Value)) {
            MsgBox(GetLang("坐标必须为数字"))
            return false
        }

        if (Number(this.StartPosXCon.Value) > Number(this.EndPosXCon.Value) || Number(this.StartPosYCon.Value) > Number(this.EndPosYCon.Value)) {
            MsgBox(GetLang("起始坐标不能大于终止坐标"))
            return false
        }
        return true
    }

    GetCommandStr() {
        if (this.RemarkCon.Value != "")
            return Format("{}_{}_{}_{}_{}_{}", this.Data.SerialStr, this.CaptureNameCon.Value, this.StartPosXCon.Value, this.StartPosYCon.Value, this.EndPosXCon.Value, this.EndPosYCon.Value, this.RemarkCon.Value)
        else
            return Format("{}_{}_{}_{}_{}_{}", this.Data.SerialStr, this.CaptureNameCon.Value, this.StartPosXCon.Value, this.StartPosYCon.Value, this.EndPosXCon.Value, this.EndPosYCon.Value)
    }

    TriggerMacro() {
        if (!this.CheckIfValid())
            return
        OnCaptureRegion("", this.GetCommandStr(), 1)
    }

    OnClose() {
        SetTimer ObjBindMethod(this, "RefreshMouseInfo"), 0
        TogSelectArea(false)
        ; 取消注册热键
        if (HasProp(this, "HotkeyRegistered") && this.HotkeyRegistered) {
            Hotkey("F1", "Off")
        }
    }

    OnF1() {
        this.SelectToggleCon.Value := 1
        TogSelectArea(true, this.OnSetArea.Bind(this))
    }
}