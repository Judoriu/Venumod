--- STEAMODDED HEADER
--- MOD_NAME: Venumod
--- MOD_ID: Venumod
--- MOD_AUTHOR: Judoriu
--- MOD_DESCRIPTION: yo
--- PREFIX: venu
----------------------------------------------------------
----------- MOD CODE -------------------------------------

SMODS.Atlas {
    key = "sort_inversion",
    path = "sort_inversion.png",
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = "sort_inversion",

    loc_txt = {
        name = "Sort d'inversion",
        text = {
            "Before scoring,",
            "{C:mult}Mult{} and {C:chips}Chips{}",
            "switch places"
        }
    },

    atlas = "sort_inversion",
    pos = {x = 0, y = 0},
    rarity = 2,
    cost = 6,

    unlocked = true,
    discovered = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context.joker_main then
            local old_mult = mult
            local old_chips = hand_chips

            return {
                mult = old_chips *5- old_mult,
                chips = old_mult *5 - old_chips,
                message = "Inversion !",
                colour = G.C.PURPLE
            }
        end
    end
}

----------------------------------------------------------
----------- MOD CODE END ----------------------------------