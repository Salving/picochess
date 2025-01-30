mouseX, mouseY = 0, 0
cameraOffsetX, cameraOffsetY = 0, 0

pickedPiece = nil

function mousePos()
    return stat(32), stat(33)
end

function _init()
    printh("---LOG START---", "log.txt", true)
    poke(0x5F2D, 0x1 | 0x2)
    
    menuitem(2, "change projection", flipProjection)

    initBoard()
    initDefaultPieces()
end

function _update()
    mouseX, mouseY = mousePos()
    cameraOffsetX = (mouseX - 64) * 2
    cameraOffsetY = mouseY
    camera(cameraOffsetX, cameraOffsetY)

    clearBoard()

    local tileX, tileY = screenToIso(mouseX + cameraOffsetX, mouseY + cameraOffsetY)
    if withinBoard(tileX, tileY) then
        selectedTile = { x = tileX, y = tileY }
        board[tileX][tileY] = 2
    end

    if btnp(5) then
        if pickedPiece and
                withinBoard(tileX, tileY) and
                not isOccupied(tileX, tileY) then
            movePiece(pickedPiece, tileX, tileY)
            pickedPiece = nil
        else
            local piece = findPiece(selectedTile.x, selectedTile.y)
            if piece then
                pickedPiece = piece
            end
        end
    end

    if btnp(4) then
        flipProjection()
    end
end

function _draw()
    cls(2)

    drawBoard()
    renderPieces()

    -- Picked piece indicator
    if pickedPiece then
        circfill(4 + cameraOffsetX, 4 + cameraOffsetY, 2, 7)
    end

    -- Cursor
    spr(0, mouseX + cameraOffsetX, mouseY + cameraOffsetY)
    --drawPiece(selectedTile.x, selectedTile.y, 0)
end