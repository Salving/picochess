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

    updateCards()
    updateBoard()

    if btnp(5) then
        pickedPieceMoves = possibleMoves(pickedPiece, pickedCard)
    end

    if btnp(4) then
        pickedPiece = nil
        pickedPieceMoves = {}
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
            if piece and selectablePieces[piece]
            --and piece.side
            then
                pickedPiece = piece
            end
        end
    end
end

function updateCards()
    selectedCard = screenToCard(mouseX + cameraOffsetX, mouseY + cameraOffsetY)

    if btnp(5) then
        if selectedCard then
            pickedCard = selectedCard
            pickedPiece = nil
        end

        --if pickedCard and pickedCard.cardType == CARD_TYPE_WALL then
        --    pickedPiece = nil
        --end

        selectablePieces = getSelectablePieces(pickedCard, 1)
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

function getSelectablePieces(card, side)
    local selectable = {}

    if card == nil then
        return selectable
    end
    
    for piece in all(pieces) do
        if card.cardType == CARD_TYPE_WALL then
            return {}
        else
            if card.pieceType == piece.type and
                piece.side == side
            then
                selectable[piece] = true
            end
        end
    end

    return selectable
end

function _draw()
    cls(2)

    -- Possible moves
    if pickedCard and #pickedPieceMoves > 0 then
        for i, v in ipairs(pickedPieceMoves) do
            if board[v.x][v.y] ~= 2 then
                board[v.x][v.y] = 3
            end
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