
Venumod = Venumod or {}

--------------------------------------------------
-- DONNEES INDIVIDUELLES DES JOKERS JJK
--------------------------------------------------

function Venumod.has_jjk_joker()
    if not G or not G.jokers then return false end

    for _, joker in ipairs(G.jokers.cards) do
        if joker.config
        and joker.config.center
        and joker.config.center.venumod_jjk then
            return true
        end
    end

    return false
end


function Venumod.get_jjk_data(card)
    if not card or not card.config or not card.config.center then
        return nil
    end

    if not card.config.center.venumod_jjk then
        return nil
    end

    card.ability = card.ability or {}

    card.ability.venumod_jjk_data =
        card.ability.venumod_jjk_data or {
            energy = 0,
            domain_active = false,
            domain_blinds = 0,
            flash_until = 0,
            domain_started_at = nil,
            domain_fadeout_until = nil
        }

    return card.ability.venumod_jjk_data
end


--------------------------------------------------
-- VERIFICATION DES TERRITOIRES
--------------------------------------------------

function Venumod.has_active_domain()
    if not G or not G.jokers then return false end

    for _, joker in ipairs(G.jokers.cards) do
        local data = Venumod.get_jjk_data(joker)

        if data and data.domain_active then
            return true
        end
    end

    return false
end


--------------------------------------------------
-- ENERGIE MAUDITE
--------------------------------------------------

function Venumod.add_jjk_energy(card, amount)
    local data = Venumod.get_jjk_data(card)

    if not data then return end
    if data.domain_active then return end

    amount = math.max(0, tonumber(amount) or 0)

    data.energy = math.min(100, data.energy + amount)

    if data.energy >= 100 then
        Venumod.activate_domain(card)
    end
end


--------------------------------------------------
-- ACTIVATION DU TERRITOIRE
--------------------------------------------------

function Venumod.activate_domain(card)
    local data = Venumod.get_jjk_data(card)

    if not data or data.domain_active then return end

    data.energy = 0
    data.domain_active = true
    data.domain_blinds = 3

    data.flash_until = G.TIMERS.REAL + 1.5
    data.domain_started_at = G.TIMERS.REAL
    data.domain_fadeout_until = nil

    attention_text({
        text = "EXTENSION DU TERRITOIRE",
        scale = 1.4,
        hold = 2,
        backdrop_colour = G.C.PURPLE,
        align = "cm",
        major = G.play,
        offset = {x = 0, y = -1}
    })

    card_eval_status_text(
        card,
        'extra',
        nil,
        nil,
        nil,
        {
            message = "EXTENSION DU TERRITOIRE !",
            colour = G.C.PURPLE
        }
    )
end


--------------------------------------------------
-- DESACTIVATION DU TERRITOIRE
--------------------------------------------------

function Venumod.deactivate_domain(card)
    local data = Venumod.get_jjk_data(card)

    if not data then return end

    data.domain_active = false
    data.domain_blinds = 0
    data.energy = 0

    data.domain_fadeout_until = G.TIMERS.REAL + 0.7

    -- On conserve les sceaux si un autre territoire
    -- est encore actif.
    if not Venumod.has_active_domain() then
        Venumod.remove_domain_seals()
    end
end


--------------------------------------------------
-- DUREE INDIVIDUELLE DES TERRITOIRES
--------------------------------------------------

function Venumod.update_domain_duration(card, context)
    if not context.blind_defeated then return end

    local data = Venumod.get_jjk_data(card)

    if not data or not data.domain_active then return end

    data.domain_blinds = data.domain_blinds - 1

    if data.domain_blinds <= 0 then
        Venumod.deactivate_domain(card)

        card_eval_status_text(
            card,
            'extra',
            nil,
            nil,
            nil,
            {
                message = "Territoire terminé !",
                colour = G.C.PURPLE
            }
        )
    end
end


--------------------------------------------------
-- BONUS DES TERRITOIRES
--------------------------------------------------

Venumod.normal_domain_bonus = {
    chips = 20,
    mult = 5
}


function Venumod.domain_post_trigger(card, context)
    local data = Venumod.get_jjk_data(card)

    if not data or not data.domain_active then return end
    if not context.post_trigger then return end

    local triggered_joker = context.other_card
    local original_context = context.other_context

    if not triggered_joker or not original_context then return end

    if not original_context.joker_main
    and not original_context.individual then
        return
    end

    local triggered_center = triggered_joker.config.center

    -- Bonus spécial du Joker qui vient de déclencher son effet
    if triggered_center.venumod_jjk
    and triggered_center.venumod_domain_bonus then

        return triggered_center.venumod_domain_bonus(
            triggered_center,
            triggered_joker,
            original_context
        )
    end

    -- Bonus générique
    return {
        chips = Venumod.normal_domain_bonus.chips,
        mult = Venumod.normal_domain_bonus.mult,
        message = "Territoire !",
        colour = G.C.PURPLE
    }
end


--------------------------------------------------
-- ATLAS ET SCEAU MAUDIT
--------------------------------------------------

SMODS.Atlas {
    key = "jjk_seal",
    path = "jjk_seal.png",
    px = 71,
    py = 95,
}


SMODS.Seal {
    key = "jjk",
    badge_colour = HEX("A65BDA"),

    loc_txt = {
        name = "Sceau maudit",
        label = "Sceau maudit",
        text = {
            "{X:mult,C:white}+5 Mult{}",
            "{X:blue,C:white}+10 Chips{}"
        }
    },

    atlas = "jjk_seal",
    pos = {x = 0, y = 0},

    calculate = function(self, card, context)
        if context.main_scoring then
            return {
                mult = 5,
                chips = 10,
                message = "Énergie maudite !",
                colour = G.C.PURPLE
            }
        end
    end
}


--------------------------------------------------
-- GESTION DES SCEAUX TEMPORAIRES
--------------------------------------------------

Venumod.temporary_seals = Venumod.temporary_seals or {}


function Venumod.apply_domain_seal(context)
    if not context.before then return end
    if not Venumod.has_active_domain() then return end
    if not context.scoring_hand then return end

    for _, playing_card in ipairs(context.scoring_hand) do
        if not playing_card.seal then
            playing_card:set_seal("venu_jjk", true, true)

            Venumod.temporary_seals[playing_card] = true
        end
    end
end


function Venumod.remove_domain_seals()
    for playing_card, _ in pairs(Venumod.temporary_seals) do
        if playing_card and playing_card.seal == "venu_jjk" then
            playing_card:set_seal(nil, true, true)
            playing_card:juice_up(0.3, 0.3)
        end
    end

    Venumod.temporary_seals = {}
end


--------------------------------------------------
-- JAUGES INDIVIDUELLES
--------------------------------------------------

Venumod.energy_uis = {}
Venumod.energy_ui_values = {}


-- Construction d'une jauge pour un Joker
function Venumod.create_energy_ui(card, energy, flash)
    local pulse = flash
        and math.floor(G.TIMERS.REAL * 8) % 2 == 0

    local filled = flash and 10 or math.floor(energy / 10)

    local bar_nodes = {}

    for i = 1, 10 do
        bar_nodes[#bar_nodes + 1] = {
            n = G.UIT.R,
            config = {
                align = "cm",
                minw = 0.20,
                minh = 0.17,
                r = 0.04,
                colour = i <= filled
                    and (pulse and G.C.WHITE or G.C.PURPLE)
                    or G.C.UI.BACKGROUND_INACTIVE
            }
        }
    end

    local definition = {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            colour = G.C.CLEAR,
            padding = 0.04
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {align = "cm"},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = "JJK",
                            scale = 0.30,
                            colour = G.C.PURPLE
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = {align = "cm"},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = tostring(energy),
                            scale = 0.38,
                            colour = G.C.WHITE
                        }
                    }
                }
            },
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.02
                },
                nodes = bar_nodes
            }
        }
    }

    -- La jauge est attachée directement à la carte Joker.
    return UIBox {
        definition = definition,
        config = {
            align = "cr",
            offset = {
                x = 0,
                y = -0.5
            },
            major = card,
            parent = G.ROOM
        }
    }
end


--------------------------------------------------
-- DESSIN ET ACTUALISATION DES JAUGES
--------------------------------------------------

function Venumod.draw_energy_ui()
    if not G or not G.jokers or not G.GAME then return end

    local active_cards = {}

    for _, joker in ipairs(G.jokers.cards) do
        local data = Venumod.get_jjk_data(joker)

        if data then
            active_cards[joker] = true

            local flash = data.flash_until
                and G.TIMERS.REAL < data.flash_until

            local pulse = flash
                and math.floor(G.TIMERS.REAL * 8) % 2 == 0

            local ui_state =
                tostring(data.energy)
                .. "_" .. tostring(pulse)
                .. "_" .. tostring(data.domain_active)

            if not Venumod.energy_uis[joker]
            or Venumod.energy_ui_values[joker] ~= ui_state then

                if Venumod.energy_uis[joker] then
                    Venumod.energy_uis[joker]:remove()
                end

                Venumod.energy_uis[joker] =
                    Venumod.create_energy_ui(
                        joker,
                        data.energy,
                        flash
                    )

                Venumod.energy_ui_values[joker] = ui_state
            end

            if Venumod.energy_uis[joker] then
                Venumod.energy_uis[joker]:draw()
            end
        end
    end

    -- Nettoyage des jauges des Jokers qui ne sont plus présents
    for joker, ui in pairs(Venumod.energy_uis) do
        if not active_cards[joker] then
            if ui then
                ui:remove()
            end

            Venumod.energy_uis[joker] = nil
            Venumod.energy_ui_values[joker] = nil
        end
    end
end


--------------------------------------------------
-- FOND VISUEL DES TERRITOIRES
--------------------------------------------------

function Venumod.draw_domain_background()
    if not love or not love.graphics or not G or not G.TIMERS then
        return
    end

    if not G.jokers then return end

    local now = G.TIMERS.REAL
    local alpha = 0

    -- On récupère l'intensité maximale parmi les territoires.
    for _, joker in ipairs(G.jokers.cards) do
        local data = Venumod.get_jjk_data(joker)

        if data then
            if data.domain_active then
                local elapsed = now - (data.domain_started_at or now)

                local current_alpha =
                    math.min(elapsed / 0.7, 1) * 0.65

                alpha = math.max(alpha, current_alpha)

            elseif data.domain_fadeout_until
            and now < data.domain_fadeout_until then

                local current_alpha = 0.65 * (
                    (data.domain_fadeout_until - now) / 0.7
                )

                alpha = math.max(alpha, current_alpha)
            end
        end
    end

    if alpha <= 0 then return end

    local shader = G.SHADERS["venu_domain"]
    if not shader then return end

    local width, height = love.graphics.getDimensions()

    love.graphics.push("all")

    shader:send("time", now)
    shader:send("overlay_alpha", alpha)

    love.graphics.setShader(shader)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.rectangle(
        "fill",
        0,
        0,
        width,
        height
    )

    love.graphics.pop()
end


--------------------------------------------------
-- SHADER
--------------------------------------------------

SMODS.Shader {
    key = "domain",
    path = "venumod_domain.fs"
}

print("[Venumod] Système JJK individuel chargé !")
