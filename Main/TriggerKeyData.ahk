#Requires AutoHotkey v2.0

class TriggerKeyData {
    __New(Key) {
        this.Key := Key
        this.OriDownArr := []  ;按下触发
        this.OriLoosenArr := []    ;松开触发
        this.OriLoosenStopArr := []    ;松止
        this.OriTogArr := []   ;开关
        this.OriHoldArr := []  ;按长按
        this.HoldActionArr := []

        this.DownArr := []
        this.LoosenArr := []
        this.LoosenStopArr := []
        this.TogArr := []
        this.HoldArr := []

        ; this.Get
    }

    AddData(index) {
        tableItem := MySoftData.TableInfo[1]
        TriggerType := tableItem.TriggerTypeArr[index]
        if (TriggerType == 1)
            this.OriDownArr.Push(index)
        if (TriggerType == 2)
            this.OriLoosenArr.Push(index)
        if (TriggerType == 3)
            this.OriLoosenStopArr.Push(index)
        if (TriggerType == 4)
            this.OriTogArr.Push(index)
        if (TriggerType == 5)
            this.OriHoldArr.Push(index)
    }

    UpdataArr() {
        tableItem := MySoftData.TableInfo[1]
        this.DownArr := []
        this.LoosenArr := []
        this.LoosenStopArr := []
        this.TogArr := []
        this.HoldArr := []

        MyMouseInfo.UpdateInfo()
        this.UpdateArrByFront(this.OriDownArr, this.DownArr)
        this.UpdateArrByFront(this.OriLoosenArr, this.LoosenArr)
        this.UpdateArrByFront(this.OriLoosenStopArr, this.LoosenStopArr)
        this.UpdateArrByFront(this.OriTogArr, this.TogArr)
        this.UpdateArrByFront(this.OriHoldArr, this.HoldArr)
    }

    UpdateArrByFront(OriArr, ResArr) {
        tableItem := MySoftData.TableInfo[1]
        for index, value in OriArr {
            infoStr := tableItem.FrontInfoArr[value]
            if (infoStr == "")
                continue

            if (MyMouseInfo.CheckIfMatch(infoStr, false))
                ResArr.Push(value)
        }

        ; 如果没有找到任何符合条件的窗口
        if (ResArr.Length == 0) {
            for index, value in OriArr {
                if (tableItem.FrontInfoArr[value] == "")
                    ResArr.Push(value)
            }
        }
    }

    OnTriggerKeyDown() {
        this.UpdataArr()
        tableItem := MySoftData.TableInfo[1]
        for index, value in this.DownArr {
            if (index == 1 && SubStr(tableItem.TKArr[value], 1, 1) != "~")
                LoosenModifyKey(tableItem.TKArr[value])

            TriggerMacroHandler(1, value)
        }

        for index, value in this.LoosenStopArr {
            TriggerMacroHandler(1, value)
        }

        for index, value in this.TogArr {
            isWork := tableItem.IsWorkIndexArr[value]
            if (isWork) {       ;关闭开关
                MySubMacroStopAction(1, value)
                return
            }
            OnToggleTriggerMacro(1, value)
        }

        if (this.HoldActionArr.Length == 0) {
            this.SetHoldTimeChecker()
        }
    }

    OnTriggerKeyUp() {
        this.UpdataArr()
        tableItem := MySoftData.TableInfo[1]
        for index, value in this.LoosenArr {
            TriggerMacroHandler(1, value)
        }

        for index, value in this.LoosenStopArr {
            isWork := tableItem.IsWorkIndexArr[value]
            if (isWork) {
                workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkIndexArr[value])
                MyWorkPool.PostMessage(WM_STOP_MACRO, workPath, 0, 0)
                return
            }
            KillTableItemMacro(tableItem, value)
        }
    }

    SetHoldTimeChecker() {
        tableItem := MySoftData.TableInfo[1]
        this.HoldActionArr := []
        for _, value in this.HoldArr {
            action := this.HoldTimeAction.Bind(this)
            SetTimer(action, -tableItem.HoldTimeArr[value])
            this.HoldActionArr.Push(action)
        }
    }

    DelHoldTimeChecker() {
        for _, value in this.HoldActionArr {
            SetTimer(value, 0)
        }
        this.HoldActionArr := []
    }

    HoldTimeAction(index) {
        tableItem := MySoftData.TableInfo[1]
        keyCombo := LTrim(tableItem.TKArr[index], "~")
        if (AreKeysPressed(keyCombo))
            TriggerMacroHandler(1, index)
    }
}