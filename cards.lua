cardWidth = 28
cardHeight = 32

-- UI
cardStartX = 40
cardStartY = 202
cardOffset = 24

selectedCard = nil
pickedCard = nil

playerHand = {}

CARD_TYPE_MOVE = 0
CARD_TYPE_CONVERT = 1
CARD_TYPE_NUDGE = 2
CARD_TYPE_WALL = 3

---@class Card:table {pieceType}

---@param pieceType number
---@return Card
function createCard(pieceType, cardType, targetType)
    return { pieceType = pieceType, cardType = cardType, targetType = targetType }
end

function generateRandomHand(size)
    local hand = {}
    while #hand < size do
        local card = generateRandomCard()
        if card.pieceType == card.targetType or
                card. cardType == CARD_TYPE_CONVERT and card.pieceType == PIECE_KING or
                card.cardType == CARD_TYPE_CONVERT and card.targetType == PIECE_KING then
            goto continue
        end
        add(hand, card)
        :: continue ::
    end

    return hand
end

function generateRandomCard()
    local v = rnd(PIECE_KING)
    local pieceType = flr((v * v + 3) / 5)
    v = rnd(CARD_TYPE_WALL)
    local cardType = flr((v * v + 2) / 3)
    local targetType = flr(rnd(PIECE_KING + 1))

    return createCard(pieceType, cardType, targetType)
end

function drawHand(hand)
    local handSize = #hand
    cardStartX = 40 - (cardWidth / 2) * handSize
    local selectedIndex = nil
    for i, card in ipairs(hand) do
        if card ~= selectedCard then
            drawCard(cardStartX + i * cardOffset, cardStartY, card)
        else
            selectedIndex = i
        end
    end

    if selectedCard then
        drawCard(cardStartX + selectedIndex * cardOffset, cardStartY, selectedCard)
    end
end

function drawCard(x, y, card)
    if card == selectedCard then
        y = y - 8
    end

    if card == pickedCard then
        pal(13, 7)
    end

    spr(4, x, y, 4, 4)
    resetPal()

    if card.cardType == CARD_TYPE_WALL then
        spr(pieceSprites[PIECE_WALL], x + cardWidth / 4 + 1, y + cardHeight / 2.5, 2, 2)
    else
        -- Draw piece type
        spr(pieceSprites[card.pieceType], x + cardWidth / 4 - 6, y + cardHeight / 2.5, 2, 2)
    end

    if card.cardType == CARD_TYPE_CONVERT then
        -- Draw target type
        spr(pieceSprites[card.targetType], x + cardWidth / 4 + 7, y + cardHeight / 2.5, 2, 2)
    end

    if card.cardType == CARD_TYPE_NUDGE then
        -- Draw "One"
        spr(16, x + cardWidth / 4 + 10, y + cardHeight / 2, 1, 1)
    end

    if card.cardType > 0 and card.cardType < 3 then
        -- Draw arrow
        spr(1, x + cardWidth / 2 - 3, y + cardHeight / 2, 1, 1)
    end
end

function screenToCard(x, y)
    local handSize = #playerHand
    local cardIndex = flr((x - cardStartX) / cardOffset)
    if y < cardStartY or y > cardStartY + cardHeight then
        return nil
    end

    if cardIndex >= 0 and cardIndex <= handSize then
        return playerHand[cardIndex]
    end

    return nil
end