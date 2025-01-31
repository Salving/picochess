local ENEMY_SIDE = 0

local playerPieces = {}
local playerAveragePosition = {x=0, y=0}

function aiMakeTurn()
    local enemyHand = generateRandomHand(5)
    playerPieces = filterPiecesBySide(pieces, 1)
    playerAveragePosition = averagePosition(playerPieces)
    
    for card in all(enemyHand) do
        local selectable = getSelectablePieces(card, ENEMY_SIDE)
        local piece = rnd(keys(selectable))

        if piece then
            --if card.cardType == CARD_TYPE_CONVERT and
            --        piece.type > card.targetType then
            --    goto continue
            --end

            local moves = possibleMoves(piece, card)
            sortMoves(moves, piece)
            local chosenMove = moves[1]
            if chosenMove then
                makeTurn(card, enemyHand, piece, chosenMove.x, chosenMove.y)
            end
        end
        :: continue ::
    end

    nextTurn()
end

function filterPiecesBySide(pieces, side) 
    local filtered = {}
    foreach(pieces, function(item)
        if item.side == side then
            add(filtered, item)
        end
    end)
    
    return filtered
end

function sortMoves(moves, piece)
    log(moves)
    
    sortTable(moves, function(a, b) 
        local foundPiece = findPiece(a.x, a.y)
        return moveScore(foundPiece, piece, b) - moveScore(foundPiece, piece, a)
    end)
    
    log(moves)
end

function moveScore(foundPiece, piece, move)
    local score = 0
    if foundPiece and foundPiece.side ~= 0 then
        score = score + 1
    end
    
    score = score + 1 / (abs(playerAveragePosition.x - move.x) + abs(playerAveragePosition.y - move.y))
    
    return score
end

function sortTable(table, func, left, right)
    left = left or 1
    right = right or #table
    if left < right then
        local p = left
        for k = left, right - 1 do
            if func(table[k], table[right]) <= 0 then
                table[p], table[k] = table[k], table[p]
                p = p + 1
            end
        end
        table[p], table[right] = table[right], table[p]
        sortTable(table, func, left, p - 1)
        sortTable(table, func, p + 1, right)
    end
end

function averagePosition(pieces)
    local x, y, n = 0, 0, 0
    for i, v in pairs(pieces) do
        x = x + v.x
        y = y + v.y
        n = n + 1
    end
    
    return {x=x/n, y=y/n}
end