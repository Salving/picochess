buttons = {}
selectedButton = nil

local buttonBackground = 13
local buttonForeground = 8
local buttonShadow = 0
local buttonBorder = 5

---createButton
---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
---@param action function
function createButton(x, y, width, height, text, action)
    return { x = x, y = y, width = width, height = height, text = text, action = action }
end

---getButton
---@param x number
---@param y number
function getButton(x, y)
    for button in all(buttons) do
        if x >= button.x and y >= button.y and
                x < button.x + button.width and y < button.y + button.height
        then
            return button
        end
    end

    return nil
end

function renderButtons()
    for button in all(buttons) do
        renderButton(button)
    end
end

function renderButton(button)
    local x, y = button.x, button.y
    -- Shadow
    rectfill(x - 2, y + 2, x + button.width, y + button.height  + 3, buttonShadow)

    if button == selectedButton then
        y = y - 4
    end
    -- Border
    rect(x-1, y-1, x + button.width + 1, y + button.height + 1, buttonBorder)
    -- Background
    rectfill(x, y, x + button.width, y + button.height, buttonBackground)
    
    print(button.text, 
            x + button.width / 2 - #button.text * 4, 
            y + button.height / 2 - 2, 
            buttonForeground)
end
