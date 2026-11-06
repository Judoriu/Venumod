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
            "{C:blue}+#2#{} Chips for every other Joker",
            "",
            "{C:purple}Domain Expansion:{}",
            "{X:mult,C:white}X#3#{} Mult during the territory"
        }
    },

    venumod_jjk = true,

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
                card.ability.extra.chips,
                500^2
            }
        }
    end,

    venumod_domain_bonus = function(self, joker, context)
        return {
            Xmult = 500^2,
            message = "UNLIMITED VOID!",
            colour = G.C.PURPLE
        }
    end,
    
    calculate = function(self, card, context)
        if context.before then
            Venumod.apply_domain_seal(context)
        end

        if context.post_trigger then
            return Venumod.domain_post_trigger(card, context)
        end

        if context.blind_defeated then
            Venumod.update_domain_duration(card, context)
        end

        if context.joker_main then
            Venumod.add_jjk_energy(card, 5)

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
                    (current_mult ^ 2) + (current_chips ^ 2) * 5

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

SMODS.Atlas {
    key = "tempete",
    path = "tempete.png",
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = "tempete",

    loc_txt = {
        name = "Tempête émotionnelle",
        text = {
            "Add current {C:mult}Mult{} and {C:chips}Chips{}",
            "Randomly separate the total",
            "Add a random bonus between {C:attention}0 and 100000{}",
            "to both new values"
        }
    },

    atlas = "tempete",
    rarity = 4,
    cost = 8,
    pos = {x = 0, y = 0},

    unlocked = true,
    discovered = true,
    blueprint_compat = false,

    calculate = function(self, card, context)

        if context.joker_main then

            local current_mult = mult
            local current_chips = hand_chips

            local total = current_mult + current_chips

            -- Random separation
            local new_mult = pseudorandom(
                "tempete_mult",
                0,
                math.floor(total)
            )

            local new_chips = total - new_mult

            -- Random bonuses
            local bonus_mult = pseudorandom(
                "tempete_bonus_mult",
                0,
                100000
            )

            local bonus_chips = pseudorandom(
                "tempete_bonus_chips",
                0,
                100000
            )

            -- Add bonuses
            new_mult = new_mult + bonus_mult
            new_chips = new_chips + bonus_chips

            -- Calculate differences
            local mult_difference = new_mult - current_mult
            local chips_difference = new_chips - current_chips

            return {
                mult = mult_difference,
                chips = chips_difference,
                message = "Tempête !",
                colour = G.C.PURPLE
            }
        end
    end
}

----------------------------------------------------------
----------- MOD CODE END ----------------------------------