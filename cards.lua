cardWidth = 28
cardHeight = 32

-- UI
cardStartX = 40
cardStartY = 202
cardOffset = 24

selectedCard = nil
pickedCard = nil

playerHand = {}

---@class Card:table {pieceType}

---@param pieceType number
---@return Card
function createCard(pieceType) 
    return {pieceType=pieceType}
end

function generateRandomHand(size)
    local hand = {}
    for i = 1, size do
        local type = flr(rnd(6))
        add(hand, createCard(type))
    end
    
    return hand
end

function drawHand(hand)
    local handSize = #hand
    cardStartX = 40 - (cardWidth / 2) * handSize
    for i, card in ipairs(hand) do
        drawCard(cardStartX + i * cardOffset, cardStartY, card)
    end
end

function drawCard(x, y, card)
    if card == selectedCard then
        y = y - 8
    end
    if card == pickedCard then
        pal(15, 13)
    end
    
    spr(4, x, y, 4, 4)
    pal()
    
    spr(pieceSprites[card.pieceType], x + cardWidth / 4, y + cardHeight / 2.5, 2, 2)
end

function screenToCard(x, y)
    local handSize = #playerHand
    local cardIndex = flr((x - cardStartX) / cardOffset)
    if y < cardStartY or y > cardStartY + cardHeight then
        return nil
    end
    
    if cardIndex >=0 and cardIndex <= handSize then
        return playerHand[cardIndex]
    end
    
    return nil
end