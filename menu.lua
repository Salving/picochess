local frame = 0

local droplets = {}

function menuInit()
    add(buttons, createButton(86, 48, 30, 15, "\250\229", startGame))
    add(buttons, createButton(86, 48 + 32, 30, 15, "\243п", stopGame))

    for i = 1, 7 do
        add(droplets, { x = rnd(128), y = i * -32 })
    end
end

function menuUpdate()
    selectedButton = getButton(mouseX, mouseY)
    if btnp(5) and selectedButton then
        selectedButton.action()
    end
end

function menuDraw()
    if frame < 10 then
        resetPal()
    else
        pal()
    end
    frame = (frame + 1) % 150

    if frame % 2 == 0 and frame > 100 then
        drawFX(0, 0)
        drawFX(0, 0)
    end

    print("дхз", 15, 20, 8)
    print("бд\245-1984", 0, 120, 5)

    renderButtons()
    
    drawDroplets(droplets)

    for i, v in ipairs(droplets) do
        v.y = v.y + 2
        if (v.y > 148) then
            v.y = -16
        end
    end

    -- Cursor
    spr(0, mouseX + cameraOffsetX, mouseY + cameraOffsetY)
    
    distort()
end

function menuClean()
    buttons = {}
end

function drawFX(offsX, offsY)
    local x, y = rnd(128), rnd(128)
    local r = rnd(3)
    local c = rnd(2) + 12
    circfill(x + offsX, y + offsY, r, c)
end

function distort()
    local x, y = rnd(128) + cameraOffsetX, rnd(128) + cameraOffsetY
    local xs, ys = rnd(128) + cameraOffsetX, rnd(128) + cameraOffsetY
    
    pset(x, y, pget(xs, ys))
end

function drawDroplets(droplets)
    local color = 0
    for i, v in ipairs(droplets) do
        circfill(v.x, v.y, 2, color)
        circfill(v.x, v.y - 3, 1, color)
    end
end

function startGame()
    changeScene(gameScene)
end

function stopGame()
    cls(0)
    extcmd("shutdown")
    stop()
end