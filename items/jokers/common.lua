--- STEAMODDED HEADER
--- MOD_NAME: Venumod
--- MOD_ID: Venumod
--- MOD_AUTHOR: Judoriu
--- MOD_DESCRIPTION: yo
--- PREFIX: venu
----------------------------------------------------------
----------- MOD CODE -------------------------------------

SMODS.Atlas {
    key = "teach",
    path = "joker_teacher.png",
    px = 71,
    py = 95,
}

SMODS.Joker{
    key = "teacher",
    loc_txt= {
        name = 'Joker teacher',
        text = {
            "If scored hand contain red suit",
            "+ Number of red suit square to the {C:blue}chips{}",
            "If scored hand contain black suit",
            "+ Number of black suit squared to the {C:blue}chips{}"
        }
    },
    atlas = "teach",
    rarity = 1,
    cost = 5,
    pos = {x=0, y=0},
    unlocked = true,
    discovered = true,
    blueprint_compat = true,

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
        local total_chips = (red ^ 2 * 5) + math.floor(math.sqrt(black))

        return {
            chips = total_chips
        }
    end
end
}

SMODS.Atlas {
    key = "carte_trefle",
    path = "carte_trefle.png",
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = "carte_trefle",

    loc_txt = {
        name = "Card of Spades",
        text = {
            "If a {C:attention}4 of Clubs{} scores:",
            "{X:mult,C:white}X4{} Mult and {X:chips,C:white}X4{} Chips",
            "If a {C:attention}5 of Clubs{} scores:",
            "{X:mult,C:white}X2{} Mult and {C:chips}halve{} Chips"
        }
    },

    atlas = "carte_trefle",
    pos = {x = 0, y = 0},
    rarity = 1,
    cost = 5,

    unlocked = true,
    discovered = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if context.individual
        and context.cardarea == G.play
        and context.other_card then

            local played_card = context.other_card

            if played_card:is_suit("Clubs") then

                -- 4 OF CLUBS
                if played_card:get_id() == 4 then
                    return {
                        Xmult = 4,
                        x_chips = 4,
                        message = "X4 !",
                        colour = G.C.GREEN
                    }

                -- 5 OF CLUBS
                elseif played_card:get_id() == 5 then
                    return {
                        Xmult = 2,
                        x_chips = 0.5,
                        message = "X2 / 2",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    end
}

----------------------------------------------------------
----------- MOD CODE END ----------------------------------