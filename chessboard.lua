isoW = 2
isoH = 1
gridStartX = 64
gridStartY = 64
tileWidth = 8
tileHeight = 8

tileColors = { [0] = 13, 15, 3 }
selectedTile = { x = 0, y = 0 }

board = {}

pieceSprites = { [0] = 64, 66, 68, 70, 72, 74 }
pieces = {}
PIECE_PAWN = 0
PIECE_ROOK = 1
PIECE_BISHOP = 2
PIECE_KNIGHT = 3
PIECE_QUEEN = 4
PIECE_KING = 5

function initBoard()
    for x = 0, 7 do
        board[x] = {}
        for y = 0, 7 do
            board[x][y] = (x + y) % 2
        end
    end
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
            drawTile(gridX * 8, gridY * 8, tileColors[v])
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
        scrY = scrY - (3 * (cos(time() / 2) + 1))
    end

    local flip = false
    if not piece.side then
        flip = true
        pal(7, 1, 0)
        pal(6, 13, 0)
        pal(5, 0, 0)
    end

    spr(pieceSprites[piece.type], scrX - 8, scrY - 4, 2, 2, flip)
    pal()
end

function initDefaultPieces()
    for i = 0, 7 do
        add(pieces, createPiece(i, 1, PIECE_PAWN, false))
        add(pieces, createPiece(i, 6, PIECE_PAWN, true))

        if i == 0 or i == 7 then
            add(pieces, createPiece(i, 0, PIECE_ROOK, false))
            add(pieces, createPiece(i, 7, PIECE_ROOK, true))
        elseif i == 1 or i == 6 then
            add(pieces, createPiece(i, 0, PIECE_KNIGHT, false))
            add(pieces, createPiece(i, 7, PIECE_KNIGHT, true))
        elseif i == 2 or i == 5 then
            add(pieces, createPiece(i, 0, PIECE_BISHOP, false))
            add(pieces, createPiece(i, 7, PIECE_BISHOP, true))
        elseif i == 3 then
            add(pieces, createPiece(i, 0, PIECE_QUEEN, false))
            add(pieces, createPiece(i, 7, PIECE_QUEEN, true))
        else
            add(pieces, createPiece(i, 0, PIECE_KING, false))
            add(pieces, createPiece(i, 7, PIECE_KING, true))
        end
    end
end

function createPiece(x, y, type, side)
    return { x = x, y = y, type = type, side = side }
end

function movePiece(piece, x, y)
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

function flipProjection()
    isoW = 2 / isoW
end