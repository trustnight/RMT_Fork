#Requires AutoHotkey v2.0

class FreePasteGui {
    __new() {
    }

    ShowGui() {
        this.AddGui()
    }

    AddGui() {
        ; 检测剪贴板格式
        isImage := DllCall("IsClipboardFormatAvailable", "UInt", 8)  ; CF_DIB = 8
        isText := IsClipboardText()

        if (isImage || isText) {
            ; 创建GUI
            curGui := Gui("+AlwaysOnTop +ToolWindow -Caption -Resize -DPIScale")
            curGui.MarginX := !isImage && isText ? 10 : 0
            curGui.MarginY := !isImage && isText ? 10 : 0
            curGui.BackColor := "FFFFFF"  ; 默认背景色
            curGui.SetFont("S13 W550 Q2", "Consolas")
        }

        if (isImage) {
            CurrentDateTime := FormatTime(, "HHmmss")
            filePath := A_WorkingDir "\Images\FreePaste\" CurrentDateTime ".png"
            SaveClipToBitmap(filePath)
            pic := curGui.Add("Picture", "", filePath)
            ; 获取实际图片尺寸
            pic.GetPos(, , &width, &height)
        }
        else if (isText) {
            clipText := A_Clipboard
            ; 创建文本控件时不要指定固定大小
            textCtrl := curGui.Add("Text", "", clipText)  ; 只限制最大宽度
            ; 获取实际文本尺寸
            textCtrl.GetPos(, , &textW, &textH)
            width := textW + curGui.MarginX * 2
            height := textH + curGui.MarginY * 2
        }

        if (isImage || isText) {
            ; 添加透明覆盖控件（覆盖整个窗口）
            overlay := curGui.Add("Text", "x0 y0 w" width " h" height " BackgroundTrans +E0x200")
            ; 将事件绑定到覆盖控件
            overlay.OnEvent("Click", this.GuiDrag.Bind(this, curGui))
            overlay.OnEvent("DoubleClick", this.DoubleClick.Bind(this, curGui))
            curGui.Show("w" width " h" height)
        }
    }

    DoubleClick(GuiObj, *) {
        GuiObj.Destroy()
        GuiObj := ""
    }

    ; 拖动函数
    GuiDrag(GuiObj, *) {
        PostMessage(0xA1, 2, , , GuiObj)
    }
}
