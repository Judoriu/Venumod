--- STEAMODDED HEADER
--- MOD_NAME: Venumod
--- MOD_ID: Venumod
--- MOD_AUTHOR: Judoriu
--- MOD_DESCRIPTION: yo
--- PREFIX: venu
----------------------------------------------------------
----------- MOD CODE -------------------------------------


SMODS.Atlas {
    key = "random",
    path = "absolute_guenole.png",
    px = 71,
    py = 95,
}

SMODS.Consumable {
    key = "random_everything",
    set = "Tarot",

    loc_txt = {
        name = "Absolute Guenole",
        text = {
            "{E:1,C:red}Chaos is inevitable{}"
        }
    },

    unlocked = true,
    discovered = true,
    atlas = "random",
    pos = {x = 0, y = 0},
    cost = 10,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area, copier)

        ------------------------------------------------
        -- RANDOM JOKERS
        ------------------------------------------------

        local joker_pool = G.P_CENTER_POOLS.Joker

        if joker_pool and #joker_pool > 0 then
            for _, joker in ipairs(G.jokers.cards) do

                local random_joker = pseudorandom_element(
                    joker_pool,
                    pseudoseed("random_everything_joker")
                )

                if random_joker then
                    joker:set_ability(random_joker, nil, true)
                    joker:juice_up(0.5, 0.5)
                end
            end
        end

        ------------------------------------------------
        -- RANDOM PLAYING CARDS
        ------------------------------------------------

        local card_pool = {}

        for _, base in pairs(G.P_CARDS) do
            if base and base.suit and base.value then
                card_pool[#card_pool + 1] = base
            end
        end

        for _, playing_card in ipairs(G.playing_cards) do

            local random_base = pseudorandom_element(
                card_pool,
                pseudoseed("random_everything_cards")
            )

            if random_base then
                playing_card:set_base(random_base)
                playing_card:juice_up(0.3, 0.3)
            end
        end

        ------------------------------------------------
        -- RANDOM HAND LEVELS
        ------------------------------------------------

        for hand_name, hand_data in pairs(G.GAME.hands) do

            local current_level = hand_data.level
            local random_level = pseudorandom(
                "random_everything_levels_" .. hand_name,
                1,
                100
            )

            local difference = random_level - current_level

            if difference ~= 0 then
                level_up_hand(
                    card,
                    hand_name,
                    true,
                    difference
                )
            end
        end

        ------------------------------------------------
        -- END
        ------------------------------------------------

        play_sound("tarot1")
    end
}


SMODS.Atlas{
    key= "lep",
    path= "lepen.png",
    px= 71,
    py= 95,
}

SMODS.Consumable{
    key= "lp",
    set = "Tarot",
    loc_txt= {
        name= "Marine Le Pen",
        text= {
            "Destroy all {C:attention}Black Cards{}",
            "{C:spades}Spades{} and {C:clubs}Clubs{}"
        }
    },

    unlocked = true,
    discovered = true,
    atlas= "lep",
    pos= {x=0,y=0},
    cost= 10,

    can_use = function(self, card)
        for _, playing_card in ipairs(G.playing_cards) do
            if playing_card:is_suit("Spades")
            or playing_card:is_suit("Clubs") then
                return true
            end
        end

        return false
    end,

    use = function(self, card, area, copier)

        local destroyed_cards = {}

        -- Find every black card
        for _, playing_card in ipairs(G.playing_cards) do
            if playing_card:is_suit("Spades")
            or playing_card:is_suit("Clubs") then

                destroyed_cards[#destroyed_cards + 1] = playing_card

            end
        end

        -- Destroy the collected cards
        if #destroyed_cards > 0 then
            SMODS.destroy_cards(destroyed_cards, {
                bypass_eternal = true
            })
        end

    end
}



SMODS.Atlas {
    key = "cola",
    path = "eliot.png",
    px = 71,
    py = 95,
}

SMODS.Consumable {
    key = "eliot",
    set = "Tarot",

    loc_txt = {
        name = "Eliot",
        text = {
            "Transforme toutes les cartes",
            "de ta main en {C:attention}Dames{}",
            "Gagne {C:purple}20 énergie{} par utilisation",
            "À {C:purple}100 énergie{} : transforme",
            "tout ton deck en {C:attention}Dames{}"
        }
    },

    unlocked = true,
    discovered = true,
    venumod_jjk = true,
    atlas = "cola",
    pos = {x = 0, y = 0},
    cost = 6,

    -- Affiche l'énergie actuelle dans la description
    loc_vars = function(self, info_queue, card)
        local energy = 0

        if G.GAME and G.GAME.venumod_eliot then
            energy = G.GAME.venumod_eliot.energy or 0
        end

        return {
            vars = {energy}
        }
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,

    use = function(self, card, area, copier)

        -- Initialise l'énergie d'Eliot
        G.GAME.venumod_eliot =
            G.GAME.venumod_eliot or {
                energy = 0
            }

        local data = G.GAME.venumod_eliot

        -- Ajoute 20 énergie
        data.energy = math.min(100, data.energy + 20)

        local territory = data.energy >= 100

        local cards_to_transform = {}

        if territory then

            -- EXTENSION DU TERRITOIRE
            -- Récupère toutes les cartes du deck
            for _, playing_card in ipairs(G.playing_cards) do
                cards_to_transform[#cards_to_transform + 1] =
                    playing_card
            end

            attention_text({
                text = "EXTENSION DU TERRITOIRE !",
                scale = 1.4,
                hold = 2,
                backdrop_colour = G.C.PURPLE,
                align = "cm",
                major = G.play,
                offset = {x = 0, y = -1}
            })

            -- Réinitialise la jauge
            data.energy = 0

        else

            -- Effet normal : uniquement la main
            for _, playing_card in ipairs(G.hand.cards) do
                cards_to_transform[#cards_to_transform + 1] =
                    playing_card
            end

        end

        -- Transformation des cartes en Dames
        for _, playing_card in ipairs(cards_to_transform) do

            local suit_prefix = string.sub(
                playing_card.base.suit,
                1,
                1
            )

            local queen = G.P_CARDS[suit_prefix .. "_Q"]

            if queen then
                playing_card:set_base(queen)
                playing_card:juice_up(0.5, 0.5)
            end

        end

        -- Message selon l'effet utilisé
        if territory then
            card_eval_status_text(
                card,
                'extra',
                nil,
                nil,
                nil,
                {
                    message = "WORLD IS HAREM!",
                    colour = G.C.PURPLE
                }
            )
        else
            card_eval_status_text(
                card,
                'extra',
                nil,
                nil,
                nil,
                {
                    message = "+" .. 20 .. " Énergie",
                    colour = G.C.PURPLE
                }
            )
        end

    end
}


SMODS.Atlas {
    key = "spooderman",
    path = "spooderman.png",
    px = 71,
    py = 95,
}

SMODS.Consumable {
    key = "spooderman",
    set = "Tarot",

    loc_txt = {
        name = "Spooderman",
        text = {
            "{C:green}1 in 15{} chance:",
            "{C:green}Good effect:{} Add {C:red}Red Seals{}",
            "to {C:attention}3 random cards{}",
            "{C:red}Bad effect:{} Destroy {C:attention}2 cards{}"
        }
    },

    atlas = "spooderman",
    pos = {x = 0, y = 0},
    cost = 6,

    can_use = function(self, card)
        return G.playing_cards and #G.playing_cards >= 2
    end,

    use = function(self, card, area, copier)
        local success = pseudorandom(
            pseudoseed("spooderman"),
            1,
            15
        ) == 1

        if success then
            -- GOOD EFFECT
            local available_cards = {}

            for _, playing_card in ipairs(G.playing_cards) do
                if not playing_card.seal then
                    available_cards[#available_cards + 1] = playing_card
                end
            end

            for i = 1, math.min(3, #available_cards) do
                local selected = pseudorandom_element(
                    available_cards,
                    pseudoseed("spooderman_seal_" .. i)
                )

                if selected then
                    selected:set_seal("Red", true, true)
                    selected:juice_up(0.5, 0.5)

                    for j, v in ipairs(available_cards) do
                        if v == selected then
                            table.remove(available_cards, j)
                            break
                        end
                    end
                end
            end

            card_eval_status_text(
                card,
                "extra",
                nil,
                nil,
                nil,
                {message = "SPIDER LUCK!", colour = G.C.RED}
            )

        else
            -- BAD EFFECT
            local destroyed_cards = {}

            for i = 1, 2 do
                if #G.playing_cards > 0 then
                    local selected = pseudorandom_element(
                        G.playing_cards,
                        pseudoseed("spooderman_destroy_" .. i)
                    )

                    if selected then
                        destroyed_cards[#destroyed_cards + 1] = selected
                        for j, v in ipairs(G.playing_cards) do
                            if v == selected then
                                table.remove(G.playing_cards, j)
                                break
                            end
                        end
                    end
                end
            end

            SMODS.destroy_cards(destroyed_cards, {
                bypass_eternal = true
            })
        end

        play_sound("tarot1")
    end
}

----------------------------------------------------------
----------- MOD CODE END ----------------------------------