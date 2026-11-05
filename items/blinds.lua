
--- STEAMODDED HEADER
--- MOD_NAME: Venumod
--- MOD_ID: Venumod
--- MOD_AUTHOR: Judoriu
--- MOD_DESCRIPTION: yo
--- PREFIX: venu
----------------------------------------------------------
----------- MOD CODE -------------------------------------

Venumod = Venumod or {}

----------------------------------------------------------
-- DETECTION DE MEGUMI
----------------------------------------------------------

local function has_megumi_level_9()
    if not G.jokers then return false end

    for _, joker in ipairs(G.jokers.cards) do
        if joker.config.center.venumod_megumi then
            local data = joker.ability.venumod_megumi

            if data and data.level >= 9 then
                return true
            end
        end
    end

    return false
end

----------------------------------------------------------
-- ATLAS MAHORAGA
----------------------------------------------------------

SMODS.Atlas{
    key = "bm",
    path = "rm.png",
    px = 34,
    py = 34
}

----------------------------------------------------------
-- BOSS BLIND : MAHORAGA
----------------------------------------------------------

SMODS.Blind {
    key = "mahoraga",

    loc_txt = {
        name = "Mahoraga",
        text = {
            "S'adapte aux mains que tu joues.",
            "Chaque répétition divise",
            "leur Mult et leurs Chips par 2.",
            "Le score requis augmente de 30%",
            "à chaque répétition."
        }
    },

    boss = {
        min = 1
    },

    boss_colour = HEX("7C5A9E"),

    mult = 2,
    dollars = 8,

    discovered = true,
    atlas = "bm",
    pos = {x = 0, y = 0},

    ------------------------------------------------------
    -- DEBUT DU COMBAT + CINEMATIQUE
    ------------------------------------------------------

    set_blind = function(self)
        local blind = G.GAME.blind

        -- Lancement de la cinématique de Mahoraga
        if Venumod
        and Venumod.MahoragaIntro
        and Venumod.MahoragaIntro.start then

            Venumod.MahoragaIntro.start()
        end

        -- Initialisation des mains
        blind.venumod_mahoraga_hands = {}

        -- Score initial requis
        blind.venumod_mahoraga_base_chips = blind.chips
    end,

    ------------------------------------------------------
    -- ADAPTATION
    ------------------------------------------------------

    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)

        local blind = G.GAME.blind

        if not blind.venumod_mahoraga_hands then
            blind.venumod_mahoraga_hands = {}
        end

        local hands = blind.venumod_mahoraga_hands

        -- Nom de la main jouée
        local hand_name = text or "Unknown"

        -- Incrémentation du compteur
        hands[hand_name] = (hands[hand_name] or 0) + 1

        local count = hands[hand_name]

        -- Première utilisation : aucune adaptation
        if count <= 1 then
            return mult, hand_chips, false
        end

        -- Réduction Mult et Chips
        local factor = 0.5 ^ (count - 1)

        mult = mult * factor
        hand_chips = hand_chips * factor

        -- Augmentation du score requis de 50%
        local base_chips =
            blind.venumod_mahoraga_base_chips or blind.chips

        blind.chips = base_chips * (1 + 0.50 * (count - 1))

        blind.chip_text = number_format(blind.chips)

        return mult, hand_chips, true
    end,

    ------------------------------------------------------
    -- DEFAITE : EVOLUTION DE MEGUMI AU NIVEAU 10
    ------------------------------------------------------

    defeat = function(self)

        if not G.jokers then return end

        for _, joker in ipairs(G.jokers.cards) do

            if joker.config.center.venumod_megumi then

                local data = joker.ability.venumod_megumi

                if data and data.level == 9 then

                    data.level = 10
                    data.xp = 0

                    card_eval_status_text(
                        joker,
                        "extra",
                        nil,
                        nil,
                        nil,
                        {
                            message = "MAHORAGA VAINCU ! NIVEAU 10 !",
                            colour = G.C.PURPLE
                        }
                    )

                    joker:juice_up(0.8, 0.8)
                end
            end
        end
    end,

    ------------------------------------------------------
    -- APPARITION DANS LA POOL
    ------------------------------------------------------

    in_pool = function(self)

        if not G.jokers then return false end

        for _, joker in ipairs(G.jokers.cards) do

            if joker.config.center.venumod_megumi then

                local data = joker.ability.venumod_megumi

                if data and data.level == 9 then
                    return true
                end
            end
        end

        return false
    end
}

----------------------------------------------------------
----------- MOD CODE END ----------------------------------
