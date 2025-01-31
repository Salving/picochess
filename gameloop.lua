TURN_NULL = 0
TURN_PLAYER = 1
TURN_ENEMY = 2

currentTurn = TURN_NULL

function clearSelect()
    pickedPiece = nil
    pickedCard = nil
    selectablePieces = {}
end

function nextTurn()
    clearSelect()
    if currentTurn == TURN_PLAYER then
        currentTurn = TURN_ENEMY
    else
        currentTurn = TURN_PLAYER
        playerHand = generateRandomHand(4)
    end
end

function makeTurn(card, hand, piece, x, y)
    if card.cardType == CARD_TYPE_WALL then
        -- Place wall
        add(pieces, createPiece(x, y, PIECE_WALL, 3))

        del(hand, card)
    elseif card.cardType == CARD_TYPE_CONVERT then
        -- Convert piece
        del(pieces, piece)

        add(pieces, createPiece(x, y, card.targetType, piece.side))

        del(hand, card)
    elseif piece then
        -- Move piece
        movePiece(piece, x, y)

        del(hand, card)
    end
end