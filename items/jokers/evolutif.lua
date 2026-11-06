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
-- MEGUMI FUSHIGURO - VENумOD
----------------------------------------------------------

SMODS.Atlas {
    key = "megumi",
    path = "megumi.png",
    px = 71,
    py = 95,
}

----------------------------------------------------------
-- DONNEES DES NIVEAUX
----------------------------------------------------------

local MEGUMI_LEVELS = {
    [0]  = {mult = 5,   chips = 10,   rarity = "Common"},
    [1]  = {mult = 15,  chips = 30,   rarity = "Common"},
    [2]  = {mult = 30,  xchips = 2,   rarity = "Common"},
    [3]  = {mult = 50,  xchips = 2.5, rarity = "Uncommon"},
    [4]  = {mult = 65,  xchips = 3,   rarity = "Uncommon"},
    [5]  = {xmult = 2,  xchips = 3.5, rarity = "Rare"},
    [6]  = {xmult = 2.5,xchips = 4,   rarity = "Rare"},
    [7]  = {xmult = 3,  xchips = 4.5, rarity = "Rare"},
    [8]  = {xmult = 5,  xchips = 8,   rarity = "Legendary"},
    [9]  = {xmult = 15, xchips = 26,  rarity = "Legendary"},
    [10] = {xmult = 100,xchips = 500, rarity = "Mythic"},
}

local function megumi_xp_required(level)
    if level >= 10 then return 0 end
    return math.ceil(50 * (1.2 ^ level))
end

local function megumi_data(card)
    card.ability.venumod_megumi =
        card.ability.venumod_megumi or {
            level = 0,
            xp = 0,
            bull_rerolls_used = false,

            tiger_mult = 0,
            tiger_chips = 0,

            territory_n = nil,
    }

    return card.ability.venumod_megumi
end

Venumod.has_megumi_frog = function()
    if not G.jokers then return false end

    for _, joker in ipairs(G.jokers.cards) do
        if joker.config.center.venumod_megumi then
            local data = joker.ability.venumod_megumi

            if data and data.level >= 2 then
                return true
            end
        end
    end

    return false
end

----------------------------------------------------------
-- TERRITOIRE DE MEGUMI
----------------------------------------------------------

local function megumi_territory_multiplier(card)
    local data = megumi_data(card)

    if data.level < 9 then
        return 1
    end

    if not Venumod.get_jjk_data then
        return 1
    end

    local jjk_data = Venumod.get_jjk_data(card)

    if jjk_data and jjk_data.domain_active then
        return data.territory_n or 1
    end

    return 1
end

local function megumi_activate_territory(card)
    local data = megumi_data(card)

    data.territory_n = math.random(1, 10)

    card_eval_status_text(
        card,
        "extra",
        nil,
        nil,
        nil,
        {
            message = "Territoire : x" .. data.territory_n,
            colour = G.C.PURPLE
        }
    )
end

local function megumi_add_xp(card, amount)
    local data = megumi_data(card)

    -- Niveau 9 : impossible de gagner davantage d'XP
    if data.level >= 9 then
        data.xp = 0
        return false
    end

    local previous_level = data.level

    data.xp = data.xp + amount

    local leveled_up = false

    while data.level < 9 do
        local required = megumi_xp_required(data.level)

        if data.xp < required then break end

        data.xp = data.xp - required
        data.level = data.level + 1
        leveled_up = true
    end

    ------------------------------------------------------
    -- MAHORAGA : PRESCRIPTION POUR LE PROCHAIN ANTE
    ------------------------------------------------------

    if previous_level < 9 and data.level == 9 and G.GAME then

        G.GAME.perscribed_bosses =
            G.GAME.perscribed_bosses or {}

        local next_ante = G.GAME.round_resets.ante + 1

        G.GAME.perscribed_bosses[next_ante] = "bl_venu_mahoraga"

        print("[Venumod] Mahoraga programme pour l'Ante " .. next_ante)
    end

    return leveled_up
end

----------------------------------------------------------
-- INVOCATIONS DEBLOQUEES
----------------------------------------------------------

local function megumi_shikigami_text(level)
    local names = {}

    if level >= 1 then table.insert(names, "Lapin") end
    if level >= 2 then table.insert(names, "Grenouille") end
    if level >= 3 then table.insert(names, "Chien de jade") end
    if level >= 4 then table.insert(names, "Serpent") end
    if level >= 5 then table.insert(names, "Nue") end
    if level >= 6 then table.insert(names, "Cerf d'inversion") end
    if level >= 7 then table.insert(names, "Elephant") end
    if level >= 8 then table.insert(names, "Taureau") end
    if level >= 9 then table.insert(names, "Tigre funeraire") end
    if level >= 10 then table.insert(names, "Mahoraga") end

    if #names == 0 then return "Aucune" end

    return table.concat(names, ", ")
end

local function megumi_bonus_text(level)
    local bonus = MEGUMI_LEVELS[level]

    local parts = {}

    if bonus.mult then
        table.insert(parts, "+" .. bonus.mult .. " Mult")
    end

    if bonus.chips then
        table.insert(parts, "+" .. bonus.chips .. " Chips")
    end

    if bonus.xmult then
        table.insert(parts, "x" .. bonus.xmult .. " Mult")
    end

    if bonus.xchips then
        table.insert(parts, "x" .. bonus.xchips .. " Chips")
    end

    return table.concat(parts, " / ")
end

----------------------------------------------------------
-- JOKER MEGUMI
----------------------------------------------------------

SMODS.Joker {
    key = "megumi",

    loc_txt = {
        name = "Megumi Fushiguro",
        text = {
            "{C:attention}Niveau #1#{}",
            "{C:inactive}XP : #2# / #3#{}",
            "{C:blue}Bonus : #4#{}",
            "{C:dark_edition}Shikigami : #5#{}",
            "Gagne {C:attention}+10 XP{} par main jouee",
        }
    },

    atlas = "megumi",
    pos = {x = 0, y = 0},

    rarity = 1,
    cost = 8,
    venumod_megumi = true,
    venumod_jjk = true,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,

    config = {
        extra = {}
    },

    set_ability = function(self, card, initial, delay_sprites)
        megumi_data(card)
    end,

    loc_vars = function(self, info_queue, card)
        local data = card and megumi_data(card) or {
            level = 0,
            xp = 0
        }

        local level = data.level
        local required = megumi_xp_required(level)

        return {
            vars = {
                level,
                data.xp,
                required,
                megumi_bonus_text(level),
                megumi_shikigami_text(level)
            }
        }
    end,

    ------------------------------------------------------
    -- RARETE VISUELLE PAR EXEMPLAIRE
    ------------------------------------------------------

    set_badges = function(self, card, badges)
        local data = megumi_data(card)
        local level = data.level

        local rarity = MEGUMI_LEVELS[level].rarity

        local colors = {
            Common = G.C.GREY,
            Uncommon = G.C.GREEN,
            Rare = G.C.BLUE,
            Legendary = G.C.PURPLE,
            Mythic = HEX("FF4040")
        }

        badges[1] = create_badge(
            rarity,
            colors[rarity],
            G.C.WHITE,
            1.2
        )
    end,

    ------------------------------------------------------
    -- EFFETS
    ------------------------------------------------------

    calculate = function(self, card, context)
        local data = megumi_data(card)
        local level = data.level
        local bonus = MEGUMI_LEVELS[level]

--------------------------------------------------
-- NIVEAU 10 : MAHORAGA NEUTRALISE LES BOSS BLINDS
-- ET DIVISE LE SCORE REQUIS PAR 10
--------------------------------------------------

--------------------------------------------------
-- NIVEAU 10 : MAHORAGA NEUTRALISE LES BOSS BLINDS
-- ET DIVISE LE SCORE REQUIS PAR 10
--------------------------------------------------

if level >= 10
and context.setting_blind
and not context.blueprint
and not context.retrigger_joker
and G.GAME
and G.GAME.blind
and G.GAME.blind.boss
and not G.GAME.blind.venumod_mahoraga_power then

    G.E_MANAGER:add_event(Event({
        func = function()
            local blind = G.GAME.blind

            if blind
            and blind.boss
            and not blind.venumod_mahoraga_power then

                blind.venumod_mahoraga_power = true

                -- Divise le score requis par 10
                blind.chips = math.max(1, blind.chips / 10)
                blind.chip_text = number_format(blind.chips)

                -- Neutralise le pouvoir du Boss Blind
                blind:disable()

                card_eval_status_text(
                    card,
                    "extra",
                    nil,
                    nil,
                    nil,
                    {
                        message = "MAHORAGA : SCORE /10 !",
                        colour = G.C.PURPLE
                    }
                )

                card:juice_up(0.8, 0.8)
            end

            return true
        end
    }))
end
        --------------------------------------------------
        -- INTEGRATION JJK
        --------------------------------------------------

        if context.before
        and Venumod.apply_domain_seal then
            Venumod.apply_domain_seal(context)
        end

        if context.blind_defeated
        and Venumod.update_domain_duration then
            Venumod.update_domain_duration(card, context)
        end

        if context.post_trigger
        and Venumod.domain_post_trigger then
            return Venumod.domain_post_trigger(card, context)
        end
        --------------------------------------------------
        -- XP : +10 PAR MAIN JOUEE
        --------------------------------------------------

        if context.before
        and context.cardarea == G.jokers
        and not context.blueprint
        and not context.retrigger_joker then

            local leveled_up = megumi_add_xp(card, 10)

            if leveled_up then
                card_eval_status_text(
                    card,
                    "extra",
                    nil,
                    nil,
                    nil,
                    {
                        message = "Niveau " .. data.level .. " !",
                        colour = G.C.PURPLE
                    }
                )

                return {
                    message = "Evolution !",
                    colour = G.C.PURPLE
                }
            end
        end
        --------------------------------------------------
        -- TAUREAU : 2 RELANCES GRATUITES
        --------------------------------------------------

        if level >= 8
        and context.end_of_round
        and not context.blueprint
        and not context.retrigger_joker
        and G.GAME then

            -- Une seule attribution par Blind,
            -- même avec plusieurs Megumi.
            if G.GAME.venumod_taurus_round ~= G.GAME.round then

                G.GAME.venumod_taurus_round = G.GAME.round

                local n = megumi_territory_multiplier(card)
                SMODS.change_free_rerolls(2 * n)

                return {
                    message = "Taureau : 2 relances !",
                    colour = G.C.PURPLE
                }
            end
        end

        --------------------------------------------------
        -- CERF D'INVERSION : +10 MULT PERMANENT
        --------------------------------------------------

        if level >= 6
        and context.before
        and context.cardarea == G.jokers
        and not context.blueprint
        and not context.retrigger_joker then

            for _, played_card in ipairs(context.full_hand) do

                local n = megumi_territory_multiplier(card)

                played_card.ability.perma_mult =
                    (played_card.ability.perma_mult or 0) + (10 * n)

                played_card:juice_up()
            end

            return {
            message = "+10 Mult permanent",
            colour = G.C.MULT
            }
        end

        --------------------------------------------------
        -- LAPIN : RETRIGGER DES CARTES JOUEES
        --------------------------------------------------

        if level >= 1
        and context.repetition
        and context.cardarea == G.play
        and context.other_card then

            return {
                repetitions = megumi_territory_multiplier(card),
                message = "Lapin !",
                colour = G.C.PURPLE
            }
        end

        --------------------------------------------------
        -- CHIEN DE JADE / SERPENT / NUE
        --------------------------------------------------

        if context.individual
        and context.cardarea == G.play
        and context.other_card then

            local played_card = context.other_card

            if level >= 3 and played_card:is_suit("Spades") then
                return {
                    mult = 50 * megumi_territory_multiplier(card),
                    message = "Chien de jade",
                    colour = G.C.PURPLE
                }
            end

            if level >= 4 and played_card:is_suit("Hearts") then
                return {
                    mult = 50 * megumi_territory_multiplier(card),
                    message = "Serpent",
                    colour = G.C.PURPLE
                }
            end

            if level >= 5 and played_card:is_suit("Clubs") then
                return {
                    chips = 150 * megumi_territory_multiplier(card),
                    message = "Nue",
                    colour = G.C.BLUE
                }
            end
        end

        --------------------------------------------------
        -- ELEPHANT : RETRIGGER DES JOKERS
        --------------------------------------------------

        if level >= 7
        and context.retrigger_joker_check
        and context.other_card
        and context.other_card ~= card
        and context.other_context
        and context.other_context.joker_main
        and not context.retrigger_joker then

            return {
                repetitions = megumi_territory_multiplier(card),
                message = "Elephant !",
                colour = G.C.PURPLE
            }
        end


        --------------------------------------------------
-- TIGRE FUNERAIRE : BONUS PAR CARTE DEFAUSSEE
--------------------------------------------------

        if level >= 9
        and context.discard
        and context.other_card
        and not context.blueprint
        and not context.retrigger_joker then

            local n = megumi_territory_multiplier(card)

            data.tiger_mult = (data.tiger_mult or 0) + n
            data.tiger_chips = (data.tiger_chips or 0) + n

            return {
                message = "+" .. n .. " Mult / +" .. n .. " Chips",
                colour = G.C.PURPLE
            }
        end

        --------------------------------------------------
        -- BONUS PRINCIPAL
        --------------------------------------------------

        if context.joker_main then
            local result = {}
--------------------------------------------------
-- MEGUMI : ENERGIE DU TERRITOIRE
--------------------------------------------------

            if level >= 9 and Venumod.add_jjk_energy then

                local jjk_data = Venumod.get_jjk_data(card)

                local was_active = jjk_data and jjk_data.domain_active

                Venumod.add_jjk_energy(card, 10)

                jjk_data = Venumod.get_jjk_data(card)

                if jjk_data
                and not was_active
                and jjk_data.domain_active then

                    megumi_activate_territory(card)
                end
            end

            if level >= 9 then
                result.mult = (result.mult or 0) + (data.tiger_mult or 0)
                result.chips = (result.chips or 0) + (data.tiger_chips or 0)
            end

            if bonus.mult then
                result.mult = bonus.mult
            end

            if bonus.chips then
                result.chips = bonus.chips
            end

            if bonus.xmult then
                result.Xmult = bonus.xmult
            end

            if bonus.xchips then
                result.x_chips = bonus.xchips
            end

            result.message = "Megumi !"
            result.colour = G.C.PURPLE

            return result
        end
    end
}


----------------------------------------------------------
----------- MOD CODE END ----------------------------------