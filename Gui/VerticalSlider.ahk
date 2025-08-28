#Requires AutoHotkey v2.0

class VerticalSlider {
    __new() {
        this.tableItem := ""
        this.AreaCon := ""
        this.BarCon := ""
        this.GuiHeight := 500
        this.BarHeight := 500
        this.MaxHeight := ""
        this.ShowSlider := false
    }

    SetSliderCon(AreaCon, BarCon) {
        this.AreaCon := AreaCon
        this.BarCon := BarCon
    }

    SwitchTab(tableItem) {
        this.tableItem := tableItem
        this.MaxHeight := tableItem.UnderPosY
        this.ShowSlider := this.MaxHeight > this.GuiHeight
        this.AreaCon.Visible := this.ShowSlider
        this.BarCon.Visible := this.ShowSlider
        this.BarHeight := (this.GuiHeight / this.MaxHeight) * this.GuiHeight

        if (!this.ShowSlider)
            return

    }

}
