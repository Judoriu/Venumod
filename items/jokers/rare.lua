--- STEAMODDED HEADER
--- MOD_NAME: Venumod
--- MOD_ID: Venumod
--- MOD_AUTHOR: Judoriu
--- MOD_DESCRIPTION: yo
--- PREFIX: venu
----------------------------------------------------------
----------- MOD CODE -------------------------------------

SMODS.Atlas {
    key = "fb",
    path = "femboy.png",
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = "femboy",
    loc_txt = {
        name = "random femboy",
        text ={ 
            "This is a random image of a femboy on pinterest",
            "Transform every dressed card into Queen card",
            "If the played card is a Queen +50 to mult"
        }
    },
    atlas= "fb",
    rarity= 3,
    cost= 8,
    pos= {x=0, y=0},
    unlocked = true,
    discovered = true,
    blueprint_compat = false,


calculate = function(self, card, context)

    if context.before then
        for _, playing_card in ipairs(context.scoring_hand) do
            if playing_card:is_face() then
                local suit_prefix = string.sub(
                    playing_card.base.suit,
                    1,
                    1
                )

                local queen = G.P_CARDS[suit_prefix .. "_Q"]

                if queen then
                    playing_card:set_base(queen)
                end
            end
        end
    end

    if context.individual
    and context.cardarea == G.play
    and context.other_card:get_id() == 12 then
        return {
            mult = 50,
            message = "+50 Mult",
            colour = G.C.MULT
        }
    end
end
}

----------------------------------------------------------
----------- MOD CODE END ----------------------------------