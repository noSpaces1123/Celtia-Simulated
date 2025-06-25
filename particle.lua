function NewParticle(x, y, radius, color, speed, degrees, gravity, lifespan, behavior, texture)
    return {
        x = x, y = y, yvelocity = 0,
        radius = radius, speed = speed, gravity = gravity, degrees = degrees,
        lifespan = lifespan, startingLifespan = lifespan, color = color,
        draw = function (self)
            love.graphics.setColor(self.color)

            if texture == nil then
                love.graphics.circle("fill", self.x, self.y, self.radius)
            else
                texture(self)
            end
        end,
        update = function (self)
            self.lifespan = self.lifespan - 1 * GlobalDT
            if self.lifespan <= 0 then
                zutil.remove(Particles, self)
                zutil.remove(BGParticles, self)
            end

            self.radius = self.lifespan / lifespan * radius

            self.x = self.x + math.sin(math.rad(self.degrees)) * self.speed * GlobalDT
            self.y = self.y + math.cos(math.rad(self.degrees)) * self.speed * GlobalDT

            self.yvelocity = self.yvelocity + self.gravity * GlobalDT
            self.y = self.y + self.yvelocity * GlobalDT

            if behavior ~= nil then behavior(self) end
        end
    }
end

function UpdateParticles(t)
    for _, particle in ipairs(t) do
        particle.update(particle)
    end
end

function DrawParticles(t)
    for _, particle in ipairs(t) do
        particle.draw(particle)
    end
end