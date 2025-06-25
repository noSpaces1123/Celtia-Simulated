--[[ Cel values:

    0 : dead
    1 : alive

]]

local guyDPIScale = 4

GuyEncyclopedia = {
    {
        name = "Knight",
        speed = 3,
        color = "Blue",
        startingCels = {
            {1,1,1},
            {1,1,1},
            {1,1,1},
        },
        pack = "Base Pack",
        box = "Base Box",
        quats = 2,
        passive = function ()
            
        end,
        moves = {
            function ()
                
            end
        },
        sprite = love.graphics.newImage("assets/guys/Knight.png", {dpiscale = guyDPIScale})
    }
}

GuyRendering = {
    spacingBetweenGuys = 20,
    spacingBetweenCels = 10,
    unitYOffset = 450,
    celWidth = GuyEncyclopedia[1].sprite:getWidth() / 3, liveCelRenderWidthMultiplier = .85, deadCelRenderWidthMultiplier = .65,
    guyDPIScale = guyDPIScale,
    deadCelAlpha = .35,
}
GuyRendering.celHeight = GuyRendering.celWidth

CelAttackQueue = { updateInterval = { current = 0, max = .1*60 } }



Moves = {}

-- `target` and `attacker` should be supplied as the Guy tables themselves.
function Moves.attack(attacker, target, cels)
    NewItemInCelAttackQueue(attacker, target, cels)
    Trigger(attacker, "attack") ; Trigger(target, "attacked")
end


function NewItemInCelAttackQueue(attacker, target, cels)
    CelAttackQueue.updateInterval.current = CelAttackQueue.updateInterval.max
    table.insert(CelAttackQueue, { attacker = attacker, target = target, cels = cels })
end
function UpdateCelAttackQueue()
    for _, item in ipairs(CelAttackQueue) do
        zutil.updatetimer(CelAttackQueue.updateInterval, GlobalDT, function ()
            for y, row in ipairs(item.cels) do
                for x, cel in ipairs(row) do
                    if cel == 1 and item.target.cels[y][x] == 1 then
                        item.target.cels[y][x] = 0

                        for _ = 1, 30 do
                            local px, py = GetCelRenderCoordsAndWidth(item.target.myTeamIndex, item.target.myGuyIndexInTheTeam, x, y)
                            table.insert(Particles, NewParticle(px + GuyRendering.celWidth / 2, py + GuyRendering.celHeight / 2, math.random()*4+2, {1,1,1}, math.random()*6+2, math.random(360), 0,
                            math.random(40,80), function (self)
                                if self.speed > 0 then self.speed = zutil.relu(self.speed - .04 * GlobalDT) end
                            end))
                        end

                        zutil.playsfx(SFX.hitCel, .3, math.random()/10+.95)
                        zutil.playsfx(SFX.thump, 2, 1)

                        item.target.shake = 3

                        if CountLiveCels(item.target) == 0 then
                            DeclareGuyAsDead(item.target)
                        end

                        return true
                    end
                end
            end
        end, 1)
    end

    return false
end



function LoadGuyIntoTeam(teamIndex, guyEncyclopediaIndex)
    local guyData = GuyEncyclopedia[guyEncyclopediaIndex]
    Teams[teamIndex][#Teams[teamIndex]+1] = {}
    local guy = Teams[teamIndex][#Teams[teamIndex]]

    -- error(lume.serialize(guy))

    for key, value in pairs(guyData) do
        guy[key] = value -- clone the Guy datatable
    end

    guy.cels = { {}, {}, {} }
    for y, row in ipairs(guy.startingCels) do -- clone the startingCels to a new cels array
        for x, cel in ipairs(row) do
            guy.cels[y][x] = cel
        end
    end

    guy.scarredCels = {
        {0,0,0},
        {0,0,0},
        {0,0,0},
    }
    guy.protectedCels = {
        {0,0,0},
        {0,0,0},
        {0,0,0},
    }
    guy.statusEffects = {}
    guy.dead = false
    guy.sprite = love.graphics.newImage("assets/guys/" .. guy.name .. ".png", {dpiscale = GuyRendering.guyDPIScale})
    guy.myTeamIndex = teamIndex
    guy.myGuyIndexInTheTeam = #Teams[teamIndex]

    guy.shake = 0
end

function Trigger(guyTable, triggerName, ...)
    if not guyTable.triggers then return false
    elseif guyTable.triggers[triggerName] then
        guyTable.triggers[triggerName](...)
        return true
    end
    return false
end



function DrawGuysAndTheirCels()
    for teamIndex, team in ipairs(Teams) do
        for guyIndex, guyData in ipairs(team) do
            local gx, gy = GetGuyRenderCoords(teamIndex, guyIndex)
            gx, gy = gx + zutil.jitter(guyData.shake), gy + zutil.jitter(guyData.shake)

            love.graphics.setColor((guyData.dead and {1,0,0,.4} or {1,1,1}))
            love.graphics.draw(guyData.sprite, gx, gy)

            local isSelected = SelectingCelsToAffect.running and SelectingCelsToAffect.targetGuyIndex == guyIndex and SelectingCelsToAffect.targetTeamIndex == teamIndex

            if isSelected then
                local padding = 5
                love.graphics.setColor(1,0,0)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", gx - padding, gy - padding, guyData.sprite:getWidth() + padding * 2, guyData.sprite:getHeight() + padding * 2)
            end

            -- cels
            for cy, row in ipairs(guyData.cels) do
                for cx, cel in ipairs(row) do
                    local x, y, renderWidth = GetCelRenderCoordsAndWidth(teamIndex, guyIndex, cx, cy)
                    x, y = x + zutil.jitter(guyData.shake), y + zutil.jitter(guyData.shake)

                    love.graphics.setColor((guyData.dead and {1,0,0, GuyRendering.deadCelAlpha} or {1,1,1, (cel > 0 and 1 or GuyRendering.deadCelAlpha)}))
                    love.graphics.rectangle("fill", x, y, renderWidth, renderWidth)

                    if isSelected and SelectingCelsToAffect.celSelection[cy][cx] == 1 then
                        love.graphics.setColor(1,0,0)
                        love.graphics.setLineWidth(3)
                        love.graphics.rectangle("line", x, y, renderWidth, renderWidth)
                    end
                end
            end

            -- shake
            if guyData.shake > 0 then
                guyData.shake = zutil.relu(guyData.shake - 0.06 * GlobalDT)
            end
        end
    end
end

--For drawing Guys.
function CalculateYOffset(teamIndex)
    return ((teamIndex - 1) * 2 - 1) * GuyRendering.unitYOffset -- if teamIndex == 1, unitYPivot = -1. if teamIndex == 2, unitYPivot = 1.     <- pretty cool, right?
end
function GetGuyRenderCoords(teamIndex, guyIndex)
    local yOffset = CalculateYOffset(teamIndex)
    local guyData = Teams[teamIndex][guyIndex]
    return (guyIndex - #Teams[teamIndex] / 2 - 1) * (guyData.sprite:getWidth() + GuyRendering.spacingBetweenGuys) + GuyRendering.spacingBetweenGuys / 2, yOffset - guyData.sprite:getHeight() / 2
end
function GetCelRenderCoordsAndWidth(teamIndex, guyIndex, x, y)
    local guyData = Teams[teamIndex][guyIndex]
    local guyX, guyY = GetGuyRenderCoords(teamIndex, guyIndex)
    local anchorX, anchorY = guyX, guyY + (teamIndex == 1 and guyData.sprite:getHeight() + GuyRendering.spacingBetweenCels or -GuyRendering.spacingBetweenCels - #guyData.cels * GuyRendering.celHeight)
    local renderWidth = GuyRendering.celWidth * (guyData.cels[y][x] > 0 and GuyRendering.liveCelRenderWidthMultiplier or GuyRendering.deadCelRenderWidthMultiplier)
    local offset = (GuyRendering.celWidth - renderWidth) / 2
    local renderX, renderY = anchorX + GuyRendering.celWidth * (x - 1), anchorY + GuyRendering.celHeight * (y - 1)
    local celRenderX, celRenderY = renderX + offset, renderY + offset
    return celRenderX, celRenderY, renderWidth
end

function CheckMouseHoveringOverGuy()
    local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

    for teamIndex, team in ipairs(Teams) do
        for guyIndex, guyData in ipairs(team) do
            local gx, gy = GetGuyRenderCoords(teamIndex, guyIndex)
            if zutil.touching(mx, my, 0, 0, gx, gy, guyData.sprite:getWidth(), guyData.sprite:getHeight()) then
                DisplayGuy(guyData)
                return
            end
        end
    end
end
function DisplayGuy(guyData)
    zutil.overlay({0,0,0,.5})

    local scale = 3

    love.graphics.setColor(1,1,1)
    love.graphics.draw(guyData.sprite, -guyData.sprite:getWidth() / 2 * scale, -guyData.sprite:getHeight() / 2 * scale, 0, scale)
end



function CountLiveCels(guyData)
    local count = 0
    for _, row in ipairs(guyData.cels) do
        for _, cel in ipairs(row) do
            if cel == 1 then count = count + 1 end
        end
    end
    return count
end

function DeclareGuyAsDead(target)
    target.dead = true
    zutil.playsfx(SFX.guyDead, .4, .8)
end