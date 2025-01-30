mouseX, mouseY = 0, 0
cameraOffsetX, cameraOffsetY = 0, 0

function mousePos()
    return stat(32), stat(33)
end

function _init()
    printh("---LOG START---", "log.txt", true)
    poke(0x5F2D, 0x1)
    
    initField()
end

function _update()
    clearField()

    local tileX, tileY = screenToIso(mouseX + cameraOffsetX, mouseY + cameraOffsetY)
    if (tileX >= 0 and tileX < 8 and tileY >= 0 and tileY < 8) then
        selectedTile = { x = tileX, y = tileY }
        field[tileX][tileY] = 2
    end
end

function _draw()
    cls(2)

    mouseX, mouseY = mousePos()
    cameraOffsetX = (mouseX - 64) * 2
    cameraOffsetY = mouseY
    camera(cameraOffsetX, cameraOffsetY)

    for gridX, row in pairs(field) do
        for gridY, v in pairs(row) do
            drawTile(gridX * 8, gridY * 8, tileColors[v])
        end
    end

    spr(0, mouseX + cameraOffsetX, mouseY + cameraOffsetY)
end