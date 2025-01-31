isoW = 2
isoH = 1
gridStartX = 64
gridStartY = 64
tileWidth = 8
tileHeight = 8

tileColors = { [0] = 13, 7, 11, 9 }
selectedTile = { x = 0, y = 0 }
selectablePieces = {}
pickedPiece = nil
pickedPieceMoves = {}

board = {}

pieceSprites = { [0] = 64, 70, 68, 66, 72, 74, 76 }
pieces = {}
PIECE_PAWN = 0
PIECE_KNIGHT = 1
PIECE_BISHOP = 2
PIECE_ROOK = 3
PIECE_QUEEN = 4
PIECE_KING = 5
PIECE_WALL = 6
pieceMoves = {}

---@class Piece:table {x, y, type, side}

function initBoard()
    for x = 0, 7 do
        board[x] = {}
        for y = 0, 7 do
            board[x][y] = (x + y) % 2
        end
    end

    pieceMoves = {
        [PIECE_PAWN] = pawnMoves,
        [PIECE_ROOK] = rookMove,
        [PIECE_BISHOP] = bishopMoves,
        [PIECE_KNIGHT] = knightMoves,
        [PIECE_QUEEN] = queenMoves,
        [PIECE_KING] = kingMoves,
    }
end

function clearBoard()
    for x, row in pairs(board) do
        for y, v in pairs(row) do
            row[y] = (x + y + 1) % 2;
        end
    end
end

function drawBoard()
    for gridX, row in pairs(board) do
        for gridY, v in pairs(row) do
            local color = tileColors[v]
            if color == 9 then
                color = color - (gridX + gridY) % 2
            end
            drawTile(gridX * 8, gridY * 8, color)
        end
    end
end

function drawTile(x, y, color)
    for i = 0, tileWidth - 1 do
        for j = 0, tileHeight - 1 do
            local scX, scY = isoToScreen(x + i, y + j)
            pset(scX, scY, color)
            pset(scX - 1, scY, color)
            pset(scX, scY + 1, color)
            pset(scX - 1, scY + 1, color)
        end
    end
end

function renderPieces()
    for i, piece in ipairs(pieces) do
        if piece ~= pickedPiece then
            drawPiece(piece)
        end
    end

    if pickedPiece ~= nil then
        drawPiece(pickedPiece)
    end
end

function drawPiece(piece)
    local x = piece.x
    local y = piece.y
    local scrX, scrY = isoToScreen(x * tileWidth, y * tileHeight)

    if piece == pickedPiece then
        ovalfill(scrX - 5, scrY + 11, scrX + 4, scrY + 13, 1)
        scrY = scrY - (3 * (cos(time() / 2) + 1))
    end

    local flip = false
    if piece.side == 0 then
        flip = true
        pal(15, 12, 0)
        pal(6, 2, 0)
        pal(5, 1, 0)
    elseif selectablePieces[piece] then
        pal(5, 11)
    end

    spr(pieceSprites[piece.type], scrX - 8, scrY - 4, 2, 2, flip)
    pal()
    resetPal()
end

function initDefaultPieces()
    for i = 0, 7 do
        add(pieces, createPiece(i, 1, PIECE_PAWN, 0))
        add(pieces, createPiece(i, 6, PIECE_PAWN, 1))

        if i == 0 or i == 7 then
            add(pieces, createPiece(i, 0, PIECE_ROOK, 0))
            add(pieces, createPiece(i, 7, PIECE_ROOK, 1))
        elseif i == 1 or i == 6 then
            add(pieces, createPiece(i, 0, PIECE_KNIGHT, 0))
            add(pieces, createPiece(i, 7, PIECE_KNIGHT, 1))
        elseif i == 2 or i == 5 then
            add(pieces, createPiece(i, 0, PIECE_BISHOP, 0))
            add(pieces, createPiece(i, 7, PIECE_BISHOP, 1))
        elseif i == 3 then
            add(pieces, createPiece(i, 0, PIECE_QUEEN, 0))
            add(pieces, createPiece(i, 7, PIECE_QUEEN, 1))
        else
            add(pieces, createPiece(i, 0, PIECE_KING, 0))
            add(pieces, createPiece(i, 7, PIECE_KING, 1))
        end
    end
end

---@param x number
---@param y number
---@param type number
---@param side number
---@return Piece
function createPiece(x, y, type, side)
    return { x = x, y = y, type = type, side = side }
end

function movePiece(piece, x, y)
    local foundPiece, i = findPiece(x, y)

    if foundPiece then
        del(pieces, foundPiece)
    end

    piece.x = x
    piece.y = y
end

function findPiece(x, y)
    for i, piece in ipairs(pieces) do
        if (piece.x == x and piece.y == y) then
            return piece
        end
    end

    return nil
end

function isOccupied(x, y)
    return findPiece(x, y) ~= nil
end

function isoToScreen(x, y)
    local screenX = gridStartX + (x - y) * isoW
    local screenY = gridStartY + (x + y) * isoH
    return screenX, screenY
end

function screenToIso(scrX, scrY)
    local x = ((scrY - gridStartY) / isoH + (scrX - gridStartX) / isoW) / 2
    local y = ((scrY - gridStartY) / isoH - (scrX - gridStartX) / isoW) / 2
    return flr(x / tileWidth), flr(y / tileHeight)
end

function withinBoard(x, y)
    return x >= 0 and x < 8 and y >= 0 and y < 8
end

function possibleMoves(piece, card)
    if card == nil or card.cardType ~= CARD_TYPE_WALL and piece == nil then
        return {}
    end

    if card.cardType == CARD_TYPE_MOVE then
        return pieceMoves[piece.type](piece, card)
    elseif card.cardType == CARD_TYPE_NUDGE then
        return kingMoves(piece)
    elseif card.cardType == CARD_TYPE_CONVERT then
        return { { x = piece.x, y = piece.y } }
    elseif card.cardType == CARD_TYPE_WALL then
        return wallMoves()
    end

    return {}
end

function pawnMoves(piece)
    local offset = 1
    if piece.side == 1 then
        offset = -1
    end

    local x, y = piece.x, piece.y
    y = y + offset
    local moves = {}

    for i = -1, 1 do
        local foundPiece = findPiece(x + i, y)
        if withinBoard(x + i, y) then
            if foundPiece and (i == -1 or i == 1) then
                add(moves, { x = x + i, y = y })
            elseif i == 0 and not foundPiece then
                add(moves, { x = x, y = y })
            end
        end
    end

    return moves
end

function offsetMoves(piece, offsets, distance)
    distance = distance or 7
    local moves = {}
    for _, offset in pairs(offsets) do
        for i = 1, distance do
            local x = piece.x + offset[1] * i
            local y = piece.y + offset[2] * i
            local foundPiece = findPiece(x, y)
            if foundPiece then
                if foundPiece.side ~= piece.side then
                    add(moves, { x = x, y = y })
                end
                goto continue
            end

            if withinBoard(x, y) then
                add(moves, { x = x, y = y })
            end
        end
        :: continue ::
    end

    return moves
end

function rookMove(piece)
    local offsets = {
        { -1, 0 },
        { 0, -1 },
        { 1, 0 },
        { 0, 1 },
    }

    return offsetMoves(piece, offsets)
end

function bishopMoves(piece)
    local offsets = {
        { -1, -1 },
        { -1, 1 },
        { 1, -1 },
        { 1, 1 },
    }

    return offsetMoves(piece, offsets)
end

function knightMoves(piece)
    local offsets = {
        { -2, -1 },
        { -2, 1 },
        { 2, -1 },
        { 2, 1 },
        { -1, -2 },
        { 1, -2 },
        { -1, 2 },
        { 1, 2 },
    }

    return offsetMoves(piece, offsets, 1)
end

function queenMoves(piece)
    local offsets = {
        { -1, -1 },
        { -1, 1 },
        { 1, -1 },
        { 1, 1 },
        { -1, 0 },
        { 0, -1 },
        { 1, 0 },
        { 0, 1 },
    }

    return offsetMoves(piece, offsets)
end

function kingMoves(piece)
    local offsets = {
        { -1, -1 },
        { -1, 1 },
        { 1, -1 },
        { 1, 1 },
        { -1, 0 },
        { 0, -1 },
        { 1, 0 },
        { 0, 1 },
    }

    return offsetMoves(piece, offsets, 1)
end

function wallMoves()
    local allMoves = {}
    for x, row in pairs(board) do
        for y, v in pairs(row) do
            if findPiece(x, y) == nil then
                add(allMoves, { x = x, y = y })
            end
        end
    end

    return allMoves
end

function flipProjection()
    isoW = 2 / isoW
end