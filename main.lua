---@diagnostic disable: lowercase-global

lume = require "lume"
zutil = require "zutil"
convobro = require "convobro"
require "particle"
require "game"
require "guy"
require "interaction"

love.window.setFullscreen(true)



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
    DrawParticles(Particles)

    CheckMouseHoveringOverGuy()
end