#Requires AutoHotkey v2.0

class RMTCMDGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.CmdStrArr := ["截图", "截图提取文本", "自由贴",
            "关闭指令显示窗口", "切换指令显示开关", "全局暂停", "终止所有宏", "重载"]
        this.OperTypeCon := ""
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

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        cmdStr := cmdArr.Length >= 2 ? cmdArr[2] : "截图"
        loop this.CmdStrArr.Length {
            if (this.CmdStrArr[A_Index] == cmdStr) {
                this.OperTypeCon.Value := A_Index
                break
            }
        }
    }

    AddGui() {
        MyGui := Gui(, "RMT指令编辑器")
        this.Gui := MyGui
        MyGui.SetFont("S11 W550 Q2", MySoftData.FontType)

        PosX := 15
        PosY := 15
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "操作类型：")
        PosX += 80
        this.OperTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w160", PosX, PosY - 3), this.CmdStrArr)

        PosX := 100
        PosY += 40
        con := MyGui.Add("Button", Format("x{} y{} w100 h40", PosX, PosY), "确定")
        con.OnEvent("Click", (*) => this.OnSureBtnClick())
        MyGui.Show(Format("w{} h{}", 300, 120))
    }

    OnSureBtnClick() {
        CommandStr := "RMT指令_" this.OperTypeCon.Text
        action := this.SureBtnAction
        action(CommandStr)
        this.Gui.Hide()
    }
}
