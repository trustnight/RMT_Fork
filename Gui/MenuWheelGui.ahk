#Requires AutoHotkey v2.0

class MenuWheelGui {
    __new() {
        this.Gui := ""
        MenuIndex := 1

        ShowPosX := 540
        ShowPosY := 300
    }

    ShowGui(MenuIndex) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }
        this.Init(MenuIndex)
    }

    Init(MenuIndex) {
        this.MenuIndex := MenuIndex

    }

    AddGui() {
        MyGui := Gui("-Caption +AlwaysOnTop +ToolWindow", "菜单轮")
        MyGui.SetFont("S11 W550 Q2", MySoftData.FontType)
        MyGui.BackColor := "EEAA99"
        WinSetTransColor("EEAA99", MyGui)
        this.Gui := MyGui
        PosX := 0
        PosY := 0

        PosX := 115
        PosY := 10
        con := MyGui.Add("Button", Format("x{} y{} w90 h30", PosX, PosY), "菜单配置1")
        con.OnEvent("Click", (*) => this.OnBtnClick(1))

        PosX := 210
        PosY := 45
        con := MyGui.Add("Button", Format("x{} y{} w90 h30", PosX, PosY), "菜单配置2")
        con.OnEvent("Click", (*) => this.OnBtnClick(1))

        PosX := 210
        PosY := 80
        con := MyGui.Add("Button", Format("x{} y{} w90 h30", PosX, PosY), "菜单配置2")
        con.OnEvent("Click", (*) => this.OnBtnClick(1))

        MyGui.Show(Format("w{} h{}", 300, 180))
    }

    OnBtnClick(index) {
        MsgBox("!23")
    }
}
