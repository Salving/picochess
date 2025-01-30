mouseX, mouseY = 0, 0
cameraOffsetX, cameraOffsetY = 0, 0

function mousePos()
    return stat(32), stat(33)
end

function _init()
    printh("---LOG START---", "log.txt", true)
    -- Want mouse
    poke(0x5F2D, 0x1 | 0x2)

    menuitem(2, "change projection", flipProjection)
    
    playerHand = generateRandomHand(6)

    initBoard()
    initDefaultPieces()
end

function _update()
    mouseX, mouseY = mousePos()
    cameraOffsetX = (mouseX - 64) * 2
    cameraOffsetY = mouseY
    camera(cameraOffsetX, cameraOffsetY)

    clearBoard()

    updateBoard()
    updateCards()

    if btnp(4) then
        flipProjection()
    end
end

function updateBoard()
    local tileX, tileY = screenToIso(mouseX + cameraOffsetX, mouseY + cameraOffsetY)
    if withinBoard(tileX, tileY) then
        selectedTile = { x = tileX, y = tileY }
        board[tileX][tileY] = 2
    else
        selectedTile = {}
    end

    if btnp(5) then
        if pickedPiece and
                withinBoard(tileX, tileY) and
                canMove(tileX, tileY, pickedPieceMoves)
        then
            movePiece(pickedPiece, tileX, tileY)
            pickedPiece = nil
        else
            local piece = findPiece(selectedTile.x, selectedTile.y)
            if piece
            --and piece.side
            then
                pickedPiece = piece
            end
        end

        pickedPieceMoves = possibleMoves(pickedPiece)
    end
end

function updateCards()
    selectedCard = screenToCard(mouseX + cameraOffsetX, mouseY + cameraOffsetY)

    if btnp(5) then
        if selectedCard then
            pickedCard = selectedCard
        end
    end
end

function canMove(x, y, moves)
    for i, move in pairs(moves) do
        if move.x == x and move.y == y then
            return true
        end
    end
    return false
end

function _draw()
    cls(2)

    -- Possible moves
    if pickedPiece then
        for i, v in ipairs(pickedPieceMoves) do
            board[v.x][v.y] = 3
        end
    end

    drawBoard()
    renderPieces()

    -- Picked piece indicator
    if pickedPiece then
        circfill(4 + cameraOffsetX, 4 + cameraOffsetY, 2, 7)
    end

    drawHand(playerHand)

    -- Cursor
    spr(0, mouseX + cameraOffsetX, mouseY + cameraOffsetY)
    --drawPiece(selectedTile.x, selectedTile.y, 0)
end