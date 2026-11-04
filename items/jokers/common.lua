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

----------------------------------------------------------
----------- MOD CODE END ----------------------------------