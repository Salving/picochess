isoW = 2
isoH = 1
gridStartX = 64
gridStartY = 64
tileWidth = 7
tileHeight = 7

tileColors = { [0] = 13, 15, 3 }
selectedTile = { x = 0, y = 0 }

field = {}

function initField()
    for x = 0, 7 do
        field[x] = {}
        for y = 0, 7 do
            field[x][y] = (x + y) % 2
        end
    end
end

function clearField()
    for x, row in pairs(field) do
        for y, v in pairs(row) do
            row[y] = (x + y) % 2;
        end
    end
end

function drawTile(x, y, color)
    for i = 0, tileWidth do
        for j = 0, tileHeight do
            local scX, scY = isoToScreen(x + i, y + j)
            pset(scX, scY, color)
            pset(scX - 1, scY, color)
            pset(scX, scY + 1, color)
            pset(scX - 1, scY + 1, color)
        end
    end
end

function isoToScreen(x, y)
    local screenX = gridStartX + (x - y) * isoW
    local screenY = gridStartY + (x + y) * isoH
    return screenX, screenY
end

function screenToIso(scrX, scrY)
    local x = ((scrY - gridStartY) / isoH + (scrX - gridStartX) / isoW) / 2
    local y = ((scrY - gridStartY) / isoH - (scrX - gridStartX) / isoW) / 2
    return flr(x / (tileWidth + 1)), flr(y / (tileHeight + 1))
end