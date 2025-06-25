VitBoardRendering = {
    sprite = love.graphics.newImage("assets/sprites/base box vits board.png", {dpiscale = 3}),
    unitXOffset = 900, unitYOffset = 300,
}

Vits = { 40, 40 }



function SpendVits(teamIndex, amount)
    Vits[teamIndex] = Vits[teamIndex] - amount
end

function DrawVitBoards()
    for teamIndex, vitCount in ipairs(Vits) do
        local xOffset = ((teamIndex - 1) * 2 - 1) * VitBoardRendering.unitXOffset
        local yOffset = ((teamIndex - 1) * 2 - 1) * VitBoardRendering.unitYOffset

        local renderX, renderY = xOffset - VitBoardRendering.sprite:getWidth() / 2, yOffset - VitBoardRendering.sprite:getHeight() / 2

        love.graphics.setColor(1,1,1)
        love.graphics.draw(VitBoardRendering.sprite, renderX, renderY)

        -- piece on the vitboard (relative x and y)
        local pxyAdd = 82
        local px, py = 305.25 + pxyAdd + renderX, 755.5 + renderY
        for i = 0, vitCount do
            if i > 0 then
                if (i - 1) % 5 == 0 then
                    pxyAdd = -pxyAdd
                    py = py - math.abs(pxyAdd)
                else
                    px = px + pxyAdd
                end
            end
        end

        love.graphics.setColor(TeamColors[teamIndex])
        love.graphics.circle("fill", px, py, 10)

        love.graphics.setFont(Fonts.normal)
        love.graphics.print(vitCount, px + 20, py)
    end
end