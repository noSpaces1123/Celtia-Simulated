function love.keypressed(key)
    if key == "escape" then
        love.event.quit()

    elseif key == "x" then
        if SelectingCelsToAffect.running and SelectingCelsToAffect.celsSelected >= SelectingCelsToAffect.minCelsToSelect and SelectingCelsToAffect.celsSelected <= SelectingCelsToAffect.maxCelsToSelect then
            SelectingCelsToAffect.running = false

            SelectingCelsToAffect.effect(Teams[SelectingCelsToAffect.affecterTeamIndex][SelectingCelsToAffect.affecterGuyIndex], Teams[SelectingCelsToAffect.targetTeamIndex][SelectingCelsToAffect.targetGuyIndex], SelectingCelsToAffect.celSelection)
        end

    elseif key == "space" then
        BeginCelSelectionProcess(Teams[1][1], Teams[2][1], 3, 3, Moves.attack)

    elseif key == "q" then
        Vits[1] = Vits[1] - 1

    end
end

function love.mousepressed(mx, my, button)
    mx, my = love.graphics.inverseTransformPoint(mx, my)

    if button == 1 then

        if SelectingCelsToAffect.running then
            if not SelectingCelsToAffect.targetGuyIndex then -- select a guy
                for teamIndex, team in ipairs(Teams) do
                    for guyIndex, guyData in ipairs(team) do
                        local gx, gy = GetGuyRenderCoords(teamIndex, guyIndex)
                        if zutil.touching(mx, my, 1, 1, gx, gy, guyData.sprite:getWidth(), guyData.sprite:getHeight()) then
                            SelectingCelsToAffect.targetTeamIndex, SelectingCelsToAffect.targetGuyIndex = teamIndex, guyIndex
                        end
                    end
                end
            else -- select the cels
                for y, row in ipairs(SelectingCelsToAffect.celSelection) do
                    for x, cel in ipairs(row) do
                        local cx, cy, renderWidth = GetCelRenderCoordsAndWidth(SelectingCelsToAffect.targetTeamIndex, SelectingCelsToAffect.targetGuyIndex, x, y)
                        if zutil.touching(mx, my, 0, 0, cx, cy, renderWidth, renderWidth) then
                            SelectingCelsToAffect.celSelection[y][x] = (cel == 0 and 1 or 0)
                            SelectingCelsToAffect.celsSelected = SelectingCelsToAffect.celsSelected + (cel == 0 and 1 or -1)
                        end
                    end
                end
            end
        end

    end
end