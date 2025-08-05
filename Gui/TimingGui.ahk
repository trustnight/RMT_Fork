#Requires AutoHotkey v2.0

class TimingGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.Data := ""

        this.StartTimeCon := ""
        this.EndTimeCon := ""
        this.TypeCon := ""
        this.IntervalCon := ""
    }

    ShowGui(SerialStr) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }
        this.Init(SerialStr)
    }

    Init(SerialStr) {
        this.SerialStr := SerialStr != "" ? SerialStr : GetSerialStr("Timing")
        this.Data := this.GetTimingData(this.SerialStr)
    }

    AddGui() {
        MyGui := Gui(, "定时编辑器")
        this.Gui := MyGui
        MyGui.SetFont(, "Arial")
        MyGui.SetFont("S11 W550 Q2", "Consolas")

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "开始时间：")
        PosX += 80
        this.StartTimeCon := MyGui.Add("DateTime", Format("x{} y{} w150", PosX, PosY - 3), "yyyy-MM-dd HH:mm")

        PosX += 170
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "结束时间：")
        PosX += 80
        this.EndTimeCon := MyGui.Add("DateTime", Format("x{} y{} w175 ChooseNone", PosX, PosY - 3), "yyyy-MM-dd HH:mm")

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "定时类型：")
        PosX += 80
        this.TypeCon := MyGui.Add("DropDownList", Format("x{} y{} w150 R5", PosX, PosY - 3), ["单次", "每小时", "每天", "每周",
            "每月", "自定义"])
        PosX += 170
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "间隔时间：")
        PosX += 80
        this.IntervalCon := MyGui.Add("Edit", Format("x{} y{} w175", PosX, PosY - 3), "")

        MyGui.Show(Format("w{} h{}", 525, 300))
    }

    GetTimingData(SerialStr) {
        saveStr := IniRead(TimingFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := TimingData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }
}
