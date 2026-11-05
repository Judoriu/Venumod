
Venumod = Venumod or {}

local Intro = {}

Intro.active = false
Intro.elapsed = 0
Intro.duration = 4.7

local function ease_out(t)
    return 1 - (1 - t) * (1 - t)
end

function Intro.start()
    Intro.elapsed = 0
    Intro.active = true
end

function Intro.update(dt)
    if not Intro.active then return end

    Intro.elapsed = Intro.elapsed + dt

    if Intro.elapsed >= Intro.duration then
        Intro.elapsed = Intro.duration
        Intro.active = false
    end
end

function Intro.draw()
    if not Intro.active then return end

    local w, h = love.graphics.getDimensions()
    local t = Intro.elapsed

    love.graphics.push("all")
    love.graphics.origin()

    -- Fond noir initial
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Roue dorée
    if t >= 0.55 and t < 3.65 then
        local wheel_t = math.min(1, (t - 0.55) / 2.75)
        local fade = 1

        if t > 3.30 then
            fade = 1 - (t - 3.30) / 0.35
        end

        local cx, cy = w / 2, h / 2
        local radius = math.min(w, h) * 0.19
        local angle = 2 * math.pi * (wheel_t * 2 + wheel_t * wheel_t * 5)

        love.graphics.translate(cx, cy)
        love.graphics.rotate(angle)

        -- Halo
        for i = 5, 1, -1 do
            love.graphics.setColor(1, 0.65, 0.12, 0.035 * fade)
            love.graphics.circle("fill", 0, 0, radius + i * 13)
        end

        -- Cercles
        love.graphics.setLineWidth(4)
        love.graphics.setColor(1, 0.72, 0.2, fade)
        love.graphics.circle("line", 0, 0, radius)
        love.graphics.circle("line", 0, 0, radius * 0.82)

        -- Huit branches
        for i = 0, 7 do
            local a = i * math.pi / 4

            local x1 = math.cos(a) * radius * 0.35
            local y1 = math.sin(a) * radius * 0.35
            local x2 = math.cos(a) * radius
            local y2 = math.sin(a) * radius

            love.graphics.setColor(1, 0.75, 0.25, fade)
            love.graphics.setLineWidth(5)
            love.graphics.line(x1, y1, x2, y2)

            -- Extrémité de chaque branche
            love.graphics.circle("fill", x2, y2, 7)
        end

        -- Centre lumineux
        love.graphics.setColor(1, 0.85, 0.35, fade)
        love.graphics.circle("fill", 0, 0, 13)

        love.graphics.origin()
    end

    -- Ouverture en deux panneaux noirs
    if t >= 3.65 then
        local split = ease_out(math.min(1, (t - 3.65) / 1.05))
        local panel_width = w / 2
        local offset = panel_width * split

        love.graphics.setColor(0, 0, 0, 1)

        -- Panneau gauche
        love.graphics.rectangle(
            "fill",
            -offset,
            0,
            panel_width,
            h
        )

        -- Panneau droit
        love.graphics.rectangle(
            "fill",
            panel_width + offset,
            0,
            panel_width,
            h
        )
    end

    love.graphics.pop()
end

Venumod.MahoragaIntro = Intro

return Intro
