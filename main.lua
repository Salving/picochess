mouseX, mouseY = 0, 0
cameraOffsetX, cameraOffsetY = 0, 0

gameScene = {}
menuScene = {}

currentScene = menuScene

playerPieceCount = 0
enemyPieceCount = 0

function changeScene(scene)
    currentScene.clean()
    currentScene = scene
    currentScene.init()
    currentScene.update()
end

function gameInit()
    menuitem(2, "change projection", flipProjection)
    add(buttons, createButton(120, 170, 40, 20, "и\222", nextTurn))
    currentTurn = TURN_PLAYER

    playerHand = generateRandomHand(3)
    
    initBoard()
    initDefaultPieces()
end

function gameUpdate()
    cameraOffsetX = (mouseX - 64) * 2
    cameraOffsetY = mouseY
    camera(cameraOffsetX, cameraOffsetY)

    clearBoard()

    if currentTurn == TURN_PLAYER then
        updateCards()
        updateBoard()
        updateUI()

        if btnp(5) then
            pickedPieceMoves = possibleMoves(pickedPiece, pickedCard)
        end

        if btnp(4) then
            pickedPiece = nil
            pickedPieceMoves = {}
        end
    elseif currentTurn == TURN_ENEMY then
        aiMakeTurn()
    end
end

function gameDraw()
    -- Possible moves
    if pickedCard and #pickedPieceMoves > 0 then
        for i, v in ipairs(pickedPieceMoves) do
            if board[v.x][v.y] ~= 2 then
                board[v.x][v.y] = 3
            end
        end
    end

    if flr(t()) % 10 == 0 then
        drawFX(cameraOffsetX, cameraOffsetY)
    end

    drawBoard()
    renderPieces()
    renderButtons()
    
    print(playerPieceCount, 8 + cameraOffsetX, 2 + cameraOffsetY, 14)
    print(enemyPieceCount, 120 + cameraOffsetX, 2 + cameraOffsetY, 14)

    circfill(4 + cameraOffsetX, 4 + cameraOffsetY, 2, currentTurn + 7)

    drawHand(playerHand)

    -- Cursor
    spr(0, mouseX + cameraOffsetX, mouseY + cameraOffsetY)
    
    distort()
end

function gameClean()
    buttons = {}
end

function mousePos()
    return stat(32), stat(33)
end

function resetPal()
    pal({ [0] = 0, 129, 1, 133, 130, 5, 134, 13, 136, 140, 139, 3, 131, 15, 6, 7 }, 1)
    pal({ [0] = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }, 0)
end

function pl()
    resetPal()
end

function _init()
    menuScene = {
        update = menuUpdate,
        draw = menuDraw,
        init = menuInit,
        clean = menuClean
    }

    gameScene = {
        update = gameUpdate,
        draw = gameDraw,
        init = gameInit,
        clean = gameClean
    }

    currentScene = menuScene

    printh("---LOG START---", "log.txt", true)
    -- Want mouse
    poke(0x5F2D, 0x1 | 0x2)

    currentScene.init()
end

function _update()
    mouseX, mouseY = mousePos()

    currentScene.update()
end

function _draw()
    cls(1)

    currentScene.draw()
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
        if pickedCard ~= nil and
                withinBoard(tileX, tileY) and
                canMove(tileX, tileY, pickedPieceMoves) then
            makeTurn(pickedCard, playerHand, pickedPiece, tileX, tileY)
            clearSelect()
            return
        end

        -- Select piece
        local piece = findPiece(selectedTile.x, selectedTile.y)
        if piece and selectablePieces[piece]
        --and piece.side
        then
            pickedPiece = piece
        end
    end

    checkGameEnd()
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

function checkGameEnd()
    playerPieceCount = #filterPiecesBySide(pieces, 1)
    enemyPieceCount = #filterPiecesBySide(pieces, 0)

    if playerPieceCount == 0 or enemyPieceCount == 0 then
        changeScene(menuScene)
    end
end

function updateUI()
    selectedButton = getButton(mouseX + cameraOffsetX, mouseY + cameraOffsetY)
    if btnp(5) and selectedButton then
        selectedButton.action()
    end
end

function log(message)
    --printh(deepToString(message), "log.txt")
end

function deepToString(obj)
    local text = ""
    if type(obj) == "table" then
        text = text .. "{"
        for i, v in pairs(obj) do
            text = text .. deepToString(i) .. "=" .. deepToString(v) .. ", "
        end
        text = text .. "}"
    else
        text = tostr(obj)
    end

    return text
end

function keys(table)
    local list = {}

    for i, v in pairs(table) do
        add(list, i)
    end

    return list
end