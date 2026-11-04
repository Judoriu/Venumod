--- STEAMODDED HEADER
--- MOD_NAME: Venumod
--- MOD_ID: Venumod
--- MOD_AUTHOR: Judoriu
--- MOD_DESCRIPTION: yo
--- PREFIX: venu
----------------------------------------------------------
----------- MOD CODE -------------------------------------


SMODS.Atlas {
    key = "sg",
    path = "satoru_gojo.png",
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = "gojo",

    loc_txt = {
        name = "Gojo",
        text = {
            "Each red card played gives",
            "{X:mult,C:white}X#1#{} Mult",
            "",
            "Each black card played gives",
            "{X:blue,C:white}+#2#{} Chips for every other Joker"
        }
    },

    config = {
        extra = {
            xmult = 50,
            chips = 1
        }
    },

    atlas = "sg",
    rarity = 4,
    cost = 10,
    pos = {x = 0, y = 0},
    unlocked = true,
    discovered = true,
    blueprint_compat = false,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.chips
            }
        }
    end,

    
    calculate = function(self, card, context)
        if context.joker_main then
            local red = 0
            local black = 0

            for _, played_card in ipairs(context.scoring_hand) do
                if played_card:is_suit("Hearts")
                or played_card:is_suit("Diamonds") then
                    red = red + 1
                elseif played_card:is_suit("Spades")
                or played_card:is_suit("Clubs") then
                    black = black + 1
                end
            end

            local joker_count = #G.jokers.cards - 1

            local red_mult = red * card.ability.extra.xmult
            local black_chips = black * joker_count * card.ability.extra.chips

            -- Hollow Purple : cartes rouges ET noires
            if red > 0 and black > 0 then
                local current_mult = mult
                local current_chips = hand_chips

                local hollow_purple =
                    (current_mult ^ 2) + (current_chips ^ 2)

                return {
                    mult = hollow_purple,
                    chips = hollow_purple,
                    message = "Hollow Purple",
                    colour = G.C.PURPLE
                }

            -- Reversal : Red
            elseif red > 0 then
                return {
                    Xmult = red_mult,
                    message = "Reversal: Red",
                    colour = G.C.MULT
                }

            -- Lapse : Blue
            elseif black > 0 then
                return {
                    chips = black_chips,
                    message = "Lapse: Blue",
                    colour = G.C.BLUE
                }
            end
        end
    end
}

----------------------------------------------------------
----------- MOD CODE END ----------------------------------