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
            "Randomize every {C:purple}Joker{}",
            "Randomize every {C:attention}playing card{}",
            "Randomize every {C:planet}hand level{}",
            "{C:red}Chaos is inevitable{}"
        }
    },

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
            "Transform all cards",
            "in your hand into {C:attention}Queens{}"
        }
    },

    atlas = "cola",
    pos = {x = 0, y = 0},
    cost = 6,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,

    use = function(self, card, area, copier)

        for _, playing_card in ipairs(G.hand.cards) do

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

    end
}



----------------------------------------------------------
----------- MOD CODE END ----------------------------------