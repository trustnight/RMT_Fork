#Requires AutoHotkey v2.0

class StopGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""

        this.StopTypeCon := ""
        this.StopIndexCon := ""
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
        this.OnRefresh()
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "终止指令编辑")
        this.Gui := MyGui
        MyGui.SetFont("S10 W550 Q2", MySoftData.FontType)

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
        PosX += 80
        con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 70, 20), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 10, 80, 30), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosX += 90
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 50, 30), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "宏类型:")

        PosX += 70
        this.StopTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX, PosY - 5, 100), ["当前宏", "按键宏", "字串宏",
            "定时宏", "宏"])
        this.StopTypeCon.Value := 1
        this.StopTypeCon.OnEvent("Change", (*) => this.OnRefresh())

        PosX += 160
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "宏序号：")

        PosX += 70
        this.StopIndexCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "1")

        PosY += 50
        PosX := 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 500, 180))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : GetSerialStr("Stop")
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetStopData(this.SerialStr)

        this.StopTypeCon.Value := this.Data.StopType
        this.StopIndexCon.Value := this.Data.StopIndex

        if (this.StopTypeCon.Value != 1) {
            SerialArr := ""
            if (this.StopTypeCon.Value == 2) {
                SerialArr := MySoftData.TableInfo[1].SerialArr
            }
            else if (this.StopTypeCon.Value == 3) {
                SerialArr := MySoftData.TableInfo[2].SerialArr
            }
            else if (this.StopTypeCon.Value == 4) {
                SerialArr := MySoftData.TableInfo[3].SerialArr
            }
            else if (this.StopTypeCon.Value == 5) {
                SerialArr := MySoftData.TableInfo[4].SerialArr
            }

            if (SerialArr.Length < this.Data.StopIndex || SerialArr[this.Data.StopIndex] != this.Data.MacroSerial) {
                loop SerialArr.Length {
                    if (SerialArr[A_Index] == this.Data.MacroSerial) {
                        this.StopIndexCon.Value := A_Index
                        break
                    }
                }
            }
        }
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

    OnRefresh() {
        enableIndex := this.StopTypeCon.Value != 1  ;类型是1的时候，不能选择序号
        this.StopIndexCon.Enabled := enableIndex
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveStopData()
        this.ToggleFunc(false)
        CommandStr := this.GetCommandStr()
        action := this.SureBtnAction
        action(CommandStr)
        this.Gui.Hide()
    }

    CheckIfValid() {
        SerialArr := ""
        if (this.StopTypeCon.Value == 2) {
            SerialArr := MySoftData.TableInfo[1].SerialArr
        }
        else if (this.StopTypeCon.Value == 3) {
            SerialArr := MySoftData.TableInfo[2].SerialArr
        }
        else if (this.StopTypeCon.Value == 4) {
            SerialArr := MySoftData.TableInfo[3].SerialArr
        }
        else if (this.StopTypeCon.Value == 5) {
            SerialArr := MySoftData.TableInfo[4].SerialArr
        }

        if (SerialArr != "" && SerialArr.Length < this.StopIndexCon.Value) {
            MsgBox("配置无效，序号不正确")
            return false
        }

        return true
    }

    TriggerMacro() {
        this.SaveStopData()
        CommandStr := this.GetCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        OnStop(tableItem, CommandStr, 1)
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "终止_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetStopData(SerialStr) {
        saveStr := IniRead(StopFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := StopData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveStopData() {
        this.Data.StopType := this.StopTypeCon.Value
        this.Data.StopIndex := this.StopIndexCon.value

        SerialArr := ""
        if (this.StopTypeCon.Value == 2) {
            SerialArr := MySoftData.TableInfo[1].SerialArr
        }
        else if (this.StopTypeCon.Value == 3) {
            SerialArr := MySoftData.TableInfo[2].SerialArr
        }
        else if (this.StopTypeCon.Value == 4) {
            SerialArr := MySoftData.TableInfo[3].SerialArr
        }
        else if (this.StopTypeCon.Value == 5) {
            SerialArr := MySoftData.TableInfo[4].SerialArr
        }
        this.Data.MacroSerial := SerialArr != "" ? SerialArr[this.Data.StopIndex] : ""

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, StopFile, IniSection, this.Data.SerialStr)
        if (MySoftData.DataCacheMap.Has(this.Data.SerialStr)) {
            MySoftData.DataCacheMap.Delete(this.Data.SerialStr)
        }
    }
}
