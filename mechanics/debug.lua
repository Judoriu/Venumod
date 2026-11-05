
Venumod = Venumod or {}

Venumod.debug = {
    input = "",
    message = "Console prête.",
    open = false,
    history = {},
    max_history = 10
}

--------------------------------------------------
-- NORMALISATION DES NOMS
--------------------------------------------------

local function normalize_name(value)
    if not value then return "" end

    value = string.lower(tostring(value))
    value = value:gsub("[%s%-]+", "_")

    return value
end

--------------------------------------------------
-- RECHERCHE UNIVERSELLE D'UNE CARTE
--------------------------------------------------

local function find_debug_center(query, wanted_set)
    if not G or not G.P_CENTERS then return nil end

    local search = normalize_name(query)

    local exact_match = nil
    local name_match = nil
    local suffix_match = nil

    for _, center in pairs(G.P_CENTERS) do
        if center.key and (not wanted_set or center.set == wanted_set) then

            local key = normalize_name(center.key)
            local short_key = key:match("([^_]+)$")

            -- Recherche par clé complète
            if key == search then
                exact_match = center
                break
            end

            -- Recherche par nom interne raccourci
            if short_key == search then
                suffix_match = suffix_match or center
            end

            -- Recherche par nom de carte
            local card_name = normalize_name(center.name)

            if card_name ~= "" and card_name == search then
                name_match = name_match or center
            end

            -- Recherche dans les noms localisés
            local descriptions = G.localization
                and G.localization.descriptions
                and G.localization.descriptions[center.set]

            local localized = descriptions
                and descriptions[center.key]

            if localized and localized.name then
                if normalize_name(localized.name) == search then
                    name_match = name_match or center
                end
            end
        end
    end

    return exact_match or name_match or suffix_match
end

--------------------------------------------------
-- AJOUT D'UNE CARTE
--------------------------------------------------

local function give_debug_card(query, wanted_set)
    if not G or not G.jokers then return end

    local center = find_debug_center(query, wanted_set)

    if not center then
        Venumod.debug.message = "Carte introuvable : " .. query
        return
    end

    local area

    if center.set == "Joker" then
        area = G.jokers
    elseif center.set == "Default" then
        Venumod.debug.message =
            "Les cartes classiques nécessitent une commande dédiée."
        return
    else
        area = G.consumeables
    end

    if not area then return end

    local success, result = pcall(function()
        return SMODS.add_card({
            key = center.key,
            area = area,
            bypass_discovery_center = true,
            bypass_discovery_ui = true
        })
    end)

    if success and result then
        Venumod.debug.message = center.key .. " ajouté !"
    else
        Venumod.debug.message = "Erreur lors de l'ajout."
        print("[Venumod Debug] " .. tostring(result))
    end
end

--------------------------------------------------
-- AJOUT DE MEGUMI A UN NIVEAU PRECIS
--------------------------------------------------

local function give_debug_megumi(level)

    if not G or not G.jokers then return end

    local center = find_debug_center("megumi", "Joker")

    if not center then
        Venumod.debug.message = "Megumi introuvable."
        return
    end

    local success, result = pcall(function()
        return SMODS.add_card({
            key = center.key,
            area = G.jokers,
            bypass_discovery_center = true,
            bypass_discovery_ui = true
        })
    end)

    if success and result then

        result.ability.venumod_megumi = {
            level = level,
            xp = 0,
            bull_rerolls_used = false
        }

        if result.juice_up then
            result:juice_up()
        end

        Venumod.debug.message =
            "Megumi ajoute au niveau " .. level .. " !"

    else
        Venumod.debug.message = "Erreur lors de la creation de Megumi."
        print("[Venumod Debug] " .. tostring(result))
    end
end

--------------------------------------------------
-- HISTORIQUE
--------------------------------------------------

local function add_debug_history(command)
    local history = Venumod.debug.history

    table.insert(history, 1, command)

    while #history > Venumod.debug.max_history do
        table.remove(history)
    end
end

--------------------------------------------------
-- EXECUTION DES COMMANDES
--------------------------------------------------

function Venumod.execute_debug_command(command, from_history)
    if not command or command:match("^%s*$") then
        Venumod.debug.input = ""
        return
    end

    command = command:gsub("^%s*/", "")
    command = command:gsub("^%s+", ""):gsub("%s+$", "")

    if not from_history then
        add_debug_history(command)
    end

    local cmd, args = command:match("^(%S+)%s*(.-)$")

    if not cmd then return end

    cmd = string.lower(cmd)

    local first, second = args:match("^(%S+)%s*(.-)$")

    --------------------------------------------------
    -- HELP
    --------------------------------------------------

    if cmd == "help" then
        Venumod.debug.message =
            "joker / joker megumi niveau / tarot / planet / spectral / card / money / energy"

    --------------------------------------------------
    -- JOKER
    --------------------------------------------------

        --------------------------------------------------
    -- JOKER
    --------------------------------------------------

    elseif cmd == "joker" then

        if first and normalize_name(first) == "megumi"
        and second ~= "" then

            local level = tonumber(second)

            if level
            and level == math.floor(level)
            and level >= 0
            and level <= 10 then

                give_debug_megumi(level)

            else
                Venumod.debug.message =
                    "Niveau invalide. Utilisation : joker megumi 8"
            end

        elseif args ~= "" then

            give_debug_card(args, "Joker")

        else
            Venumod.debug.message =
                "Utilisation : joker gojo ou joker megumi 8"
        end

    --------------------------------------------------
    -- TAROT
    --------------------------------------------------

    elseif cmd == "tarot" then
        if args ~= "" then
            give_debug_card(args, "Tarot")
        else
            Venumod.debug.message = "Utilisation : tarot eliot"
        end

    --------------------------------------------------
    -- PLANET
    --------------------------------------------------

    elseif cmd == "planet" then
        if args ~= "" then
            give_debug_card(args, "Planet")
        else
            Venumod.debug.message = "Utilisation : planet pluto"
        end

    --------------------------------------------------
    -- SPECTRAL
    --------------------------------------------------

    elseif cmd == "spectral" then
        if args ~= "" then
            give_debug_card(args, "Spectral")
        else
            Venumod.debug.message = "Utilisation : spectral soul"
        end

    --------------------------------------------------
    -- CARTE UNIVERSELLE
    --------------------------------------------------

    elseif cmd == "card" then
        if args ~= "" then
            give_debug_card(args, nil)
        else
            Venumod.debug.message = "Utilisation : card clé_interne"
        end

    --------------------------------------------------
    -- MONEY
    --------------------------------------------------

    elseif cmd == "money" then
        local amount = tonumber(first)

        if amount and ease_dollars then
            ease_dollars(amount)
            Venumod.debug.message = "Argent modifié : " .. amount
        else
            Venumod.debug.message = "Utilisation : money 10000"
        end

    --------------------------------------------------
    -- ENERGY JJK
    --------------------------------------------------

    elseif cmd == "energy" then
        local amount = tonumber(second)

        if not first or not amount then
            Venumod.debug.message = "Utilisation : energy gojo 100"
        else
            local found = false

            if G and G.jokers then
                for _, card in ipairs(G.jokers.cards) do
                    local key = normalize_name(card.config.center.key)
                    local short_key = key:match("([^_]+)$")

                    if key == normalize_name(first)
                    or short_key == normalize_name(first) then

                        if Venumod.add_jjk_energy then
                            Venumod.add_jjk_energy(card, amount)
                            Venumod.debug.message =
                                "Énergie ajoutée à " .. first
                        else
                            Venumod.debug.message =
                                "Système JJK indisponible."
                        end

                        found = true
                        break
                    end
                end
            end

            if not found then
                Venumod.debug.message = "Joker introuvable : " .. first
            end
        end

    else
        Venumod.debug.message = "Commande inconnue. Tapez help"
    end

    -- Effacement du champ après chaque commande
    Venumod.debug.input = ""

    print("[Venumod Debug] " .. Venumod.debug.message)
end

--------------------------------------------------
-- BOUTON EXECUTER
--------------------------------------------------

G.FUNCS.venumod_debug_execute = function()
    Venumod.execute_debug_command(Venumod.debug.input)
end

--------------------------------------------------
-- HISTORIQUE CLIQUABLE
--------------------------------------------------

local function create_history_buttons(nodes)
    for i, old_command in ipairs(Venumod.debug.history) do
        local saved_command = old_command
        local function_name = "venumod_debug_history_" .. i

        G.FUNCS[function_name] = function()
            Venumod.execute_debug_command(saved_command, true)
        end

        nodes[#nodes + 1] = {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.015
            },
            nodes = {
                UIBox_button({
                    label = {saved_command},
                    button = function_name,
                    minw = 4.5,
                    minh = 0.35,
                    scale = 0.3,
                    colour = G.C.GREY
                })
            }
        }
    end
end

--------------------------------------------------
-- FERMETURE
--------------------------------------------------

G.FUNCS.venumod_debug_close = function()
    Venumod.debug.open = false
    G.FUNCS.exit_overlay_menu()
end


--------------------------------------------------
-- REPETITION AUTOMATIQUE DU CLAVIER
--------------------------------------------------

Venumod.debug.enable_key_repeat = function()
    if love and love.keyboard and love.keyboard.setKeyRepeat then
        love.keyboard.setKeyRepeat(true, 0.35, 0.04)
    end
end

Venumod.debug.disable_key_repeat = function()
    if love and love.keyboard and love.keyboard.setKeyRepeat then
        love.keyboard.setKeyRepeat(false)
    end
end

--------------------------------------------------
-- INTERFACE
--------------------------------------------------

G.UIDEF.venumod_debug = function()

    local history_nodes = {}

    create_history_buttons(history_nodes)

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            colour = G.C.BLACK,
            r = 0.1,
            padding = 0.2
        },
        nodes = {

            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.1},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = "VENUMOD DEBUG CONSOLE",
                            scale = 0.55,
                            colour = G.C.PURPLE
                        }
                    }
                }
            },

            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.1},
                nodes = {
                    create_text_input({
                        w = 4.5,
                        h = 0.8,
                        text_scale = 0.45,
                        ref_table = Venumod.debug,
                        ref_value = "input",
                        prompt_text = "Entrez une commande...",
                        max_length = 80,
                        all_caps = false,
                        extended_corpus = true
                    })
                }
            },

            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.1},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            ref_table = Venumod.debug,
                            ref_value = "message",
                            scale = 0.35,
                            colour = G.C.WHITE
                        }
                    }
                }
            },

            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.1},
                nodes = {
                    UIBox_button({
                        label = {"EXECUTER"},
                        button = "venumod_debug_execute",
                        minw = 2.5,
                        minh = 0.7,
                        scale = 0.45,
                        colour = G.C.PURPLE
                    }),

                    UIBox_button({
                        label = {"FERMER"},
                        button = "venumod_debug_close",
                        minw = 2,
                        minh = 0.7,
                        scale = 0.45,
                        colour = G.C.RED
                    })
                }
            },

            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0.1},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = "HISTORIQUE",
                            scale = 0.4,
                            colour = G.C.PURPLE
                        }
                    }
                }
            },

            {
                n = G.UIT.R,
                config = {align = "cm"},
                nodes = history_nodes
            }
        }
    }
end

--------------------------------------------------
-- SURVEILLANCE DE LA FERMETURE AVEC ECHAP
--------------------------------------------------

Venumod.debug.update = function()
    if Venumod.debug.open and G and not G.OVERLAY_MENU then
        Venumod.debug.open = false
        Venumod.debug.disable_key_repeat()
    end
end

--------------------------------------------------
-- OUVERTURE AVEC F6
--------------------------------------------------

SMODS.Keybind {
    key = "debug_console",
    key_pressed = "f6",

    action = function(self)
        if not G or not G.ROOM then return end

        if Venumod.debug.open then
            return
        end

        Venumod.debug.open = true
        Venumod.debug.enable_key_repeat()

        G.FUNCS.overlay_menu({
            definition = G.UIDEF.venumod_debug()
        })

        G.FUNCS.overlay_menu({
            definition = G.UIDEF.venumod_debug()
        })
    end
}
