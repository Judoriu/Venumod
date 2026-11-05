--- STEAMODDED HEADER
--- MOD_NAME: Venumod
--- MOD_ID: Venumod
--- MOD_AUTHOR: Judoriu
--- MOD_DESCRIPTION: yo
--- PREFIX: venu
----------------------------------------------------------
----------- MOD CODE -------------------------------------

SMODS.current_mod.optional_features = function()
    return {
        post_trigger = true,
        retrigger_joker = true
    }
end

assert(SMODS.load_file("mechanics/jjk.lua"))()
assert(SMODS.load_file("mechanics/debug.lua"))()
assert(SMODS.load_file("anim/mahoraga_intro.lua"))()

assert(SMODS.load_file("items/jokers/common.lua"))()
assert(SMODS.load_file("items/jokers/uncommon.lua"))()
assert(SMODS.load_file("items/jokers/rare.lua"))()
assert(SMODS.load_file("items/jokers/legendary.lua"))()
assert(SMODS.load_file("items/jokers/evolutif.lua"))()

assert(SMODS.load_file("items/blinds.lua"))()
assert(SMODS.load_file("items/consumable/tarot.lua"))()

----------------------------------------------------------
----------- MOD CODE END ----------------------------------