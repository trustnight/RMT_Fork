#Requires AutoHotkey v2.0

;打赏
AddThankUI(index) {
    MyGui := MySoftData.MyGui
    posY := MySoftData.TabPosY + 40
    OriPosX := MySoftData.TabPosX + 15

    posX := OriPosX
    con := MyGui.Add("Text", Format("x{} y{} w{} h{}", posX, posY, 850, 70),
    "感谢每一位陪伴我们走过这段旅程的粉丝和群友们！是你们的支持与信任，让这个软件从一个小小的想法，一步步成长为今天的样子。每一次的鼓励、每一条的建议，都是我们前进的动力。`n感谢你们不离不弃，与我们共同见证每一次的迭代与成长。")
    con.SetFont((Format("S{} W{} Q{}", 12, 600, 0)))
    con.Focus()

    posX := OriPosX
    posY += 75
    MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", posX, posY, 850, 60), "感谢以下开发者为项目付出的智慧与汗水（排名不分先后）：")

    posY += 30
    posX += 10
    MyGui.Add("Link", Format("x{} y{}", posX, posY), '<a href="https://github.com/GushuLily">GushuLily</a>')

    posX += 100
    MyGui.Add("Link", Format("x{} y{}", posX, posY), '<a href="https://gitee.com/bogezzb">张正波</a>')

    posX := OriPosX
    posY += 75
    MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", posX, posY, 850, 60), "软件的开发离不开众多优秀开源项目的支持，特别感谢：")

    posY += 30
    posX += 10
    MyGui.Add("Text", Format("x{} y{}", posX, posY), "GushuLily")

    posX += 100
    MyGui.Add("Text", Format("x{} y{}", posX, posY), "张正波")

    posY += 35
    MySoftData.TableInfo[index].underPosY := posY
}