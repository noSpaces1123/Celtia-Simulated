function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(mx, my, button)
    if button == 1 then

        if SelectingCelsToAffect.running then
            if not SelectingCelsToAffect.guyIndex then -- select a guy
                for teamIndex, team in ipairs(Teams) do
                    for guyIndex, guyData in ipairs(team) do
                        local gx, gy = GetGuyRenderCoords(teamIndex, guyIndex)
                        if zutil.touching(mx, my, 0, 0, gx, gy, guyData.sprite:getWidth(), guyData.sprite:getHeight()) then
                            SelectingCelsToAffect.teamIndex, SelectingCelsToAffect.guyIndex = teamIndex, guyIndex
                        end
                    end
                end
            else -- select the cels
                for y, row in ipairs(SelectingCelsToAffect.celSelection) do
                    for x, cel in ipairs(row) do
                        local cx, cy, renderWidth = GetCelRenderCoordsAndWidth(SelectingCelsToAffect.teamIndex, SelectingCelsToAffect.guyIndex, x, y)
                        if zutil.touching(mx, my, 0, 0, cx, cy, renderWidth, renderWidth) then
                            SelectingCelsToAffect.celSelection[y][x] = (cel == 0 and 1 or 0)
                        end
                    end
                end
            end
        end

    end
end