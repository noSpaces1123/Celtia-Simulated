---@diagnostic disable: lowercase-global

lume = require "lume"
zutil = require "zutil"
convobro = require "convobro"
require "particle"
require "game"
require "guy"
require "interaction"
require "vitboard"


NameOfTheGame = "Celtia Simulated"

love.window.setMode(0, 0, { fullscreen = true, highdpi = true })

WINDOW = {
    WIDTH = love.graphics.getWidth(),
    HEIGHT = love.graphics.getHeight(),
}
WINDOW.HALF_WIDTH = WINDOW.WIDTH / 2
WINDOW.HALF_HEIGHT = WINDOW.HEIGHT / 2
WINDOW.ORIGIN_X = -WINDOW.WIDTH / 2
WINDOW.ORIGIN_Y = -WINDOW.HEIGHT / 2
WINDOW.CENTER_X = 0
WINDOW.CENTER_Y = 0

love.window.setTitle(NameOfTheGame)
love.filesystem.setIdentity(NameOfTheGame)



function love.load()
    Particles = {}
    BGParticles = {}

    LoadGuyIntoTeam(1, 1)
    LoadGuyIntoTeam(1, 1)
    LoadGuyIntoTeam(2, 1)
    LoadGuyIntoTeam(2, 1)
    LoadGuyIntoTeam(1, 1)
    LoadGuyIntoTeam(1, 1)
    LoadGuyIntoTeam(2, 1)
    LoadGuyIntoTeam(2, 1)

    Fonts = {
        normal = love.graphics.newFont("assets/fonts/Roboto/static/Roboto-Regular.ttf", 20),
        celSelectionPrompt = love.graphics.newFont("assets/fonts/Roboto/static/Roboto-Light.ttf", 20),
    }

    SFX = zutil.loadsfx("assets/sfx", {}, "wav")

    GlobalDT = 0
end

function love.update(dt)
    GlobalDT = dt * 60

    UpdateCelAttackQueue()

    UpdateParticles(BGParticles)
    UpdateParticles(Particles)
end

function love.draw()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2) -- sets (0, 0) to the center of the screen.      <- just makes it a lot easier to do drawing operations and stuff (and rotate the screen)

    -- love.graphics.circle("fill", 0, 0, 3, 100) -- center of the screen

    DrawParticles(BGParticles)

    DrawGuysAndTheirCels()
    DrawVitBoards()
    DrawParticles(Particles)

    DrawCelsToSelectPrompt()

    CheckMouseHoveringOverGuy()
end



function DrawCelsToSelectPrompt()
    if not SelectingCelsToAffect.running then return end

    local text
    if not SelectingCelsToAffect.targetGuyIndex then
        text = "Select a target Guy."
    elseif SelectingCelsToAffect.celsSelected < SelectingCelsToAffect.minCelsToSelect then
        text = "Select " .. SelectingCelsToAffect.minCelsToSelect - SelectingCelsToAffect.celsSelected .. " more Cels."
    elseif SelectingCelsToAffect.celsSelected > SelectingCelsToAffect.maxCelsToSelect then
        text = "Select " .. SelectingCelsToAffect.celsSelected - SelectingCelsToAffect.maxCelsToSelect .. " fewer Cels."
    else
        text = "Press [X] to carry out the effect."
    end

    love.graphics.setColor(0,.5,1,1)
    love.graphics.setFont(Fonts.celSelectionPrompt)
    love.graphics.printf(text, WINDOW.ORIGIN_X, WINDOW.CENTER_Y - Fonts.celSelectionPrompt:getHeight() / 2, WINDOW.WIDTH, "center")
end