--[[ Cel values:

    0 : dead
    1 : alive
    2 : protected

]]

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
    }
}

GuyRendering = {
    spacingBetween = 20,
    unitYOffset = 400,
}



Moves = {}

-- `target` and `attacker` should be supplied as the Guy tables themselves.
function Moves.attack(attacker, target, cels)
    for y, row in ipairs(cels) do
        for x, cel in ipairs(row) do
            if cel == 1 then
                target[y][x] = 0
                Trigger(attacker, "attack") ; Trigger(target, "attacked")
            end
        end
    end
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
    guy.statusEffects = {}
    guy.dead = false
    guy.sprite = love.graphics.newImage("assets/guys/" .. guy.name .. ".png", {dpiscale = 4})
end

function Trigger(guyTable, triggerName, ...)
    if guyTable.triggers[triggerName] then
        guyTable.triggers[triggerName](...)
        return true
    end
    return false
end



function DrawGuys()
    for teamIndex, team in ipairs(Teams) do
        for guyIndex, guyData in ipairs(team) do
            local x, y = GetGuyRenderCoords(teamIndex, guyIndex)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(guyData.sprite, x, y)
        end
    end
end

function GetGuyRenderCoords(teamIndex, guyIndex)
    local unitYPivot = (teamIndex - 1) * 2 - 1 -- if teamIndex == 1, unitYPivot = -1. if teamIndex == 2, unitYPivot = 1.     <- pretty cool, right?
    local yOffset = GuyRendering.unitYOffset * unitYPivot
    local guyData = Teams[teamIndex][guyIndex]
    return (guyIndex - #Teams[teamIndex] / 2 - 1) * (guyData.sprite:getWidth() + GuyRendering.spacingBetween) + GuyRendering.spacingBetween / 2, yOffset - guyData.sprite:getHeight() / 2
end

function CheckMouseHoveringOverGuy()
    local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

    for teamIndex, team in ipairs(Teams) do
        for guyIndex, guyData in ipairs(team) do
            local gx, gy = GetGuyRenderCoords(teamIndex, guyIndex)
            if zutil.touching(mx, my, 0, 0, gx, gy, guyData.sprite:getWidth(), guyData.sprite:getHeight()) then
                DisplayGuy(guyData)
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