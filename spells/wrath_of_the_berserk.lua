local my_utility = require("my_utility/my_utility")

local menu_elements_wrath_of_berk_base=
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_wrath_of_berk_base")),
    filter_mode           = combo_box:new(0, get_hash(my_utility.plugin_label .. "wrath_of_berk_base_filter_mode")),
    min_max_targets       = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_wrath_base"))
}

local function menu()

    if menu_elements_wrath_of_berk_base.tree_tab:push("Wrath Of The Berserk") then
        menu_elements_wrath_of_berk_base.main_boolean:render("Enable Spell", "")



        if menu_elements_wrath_of_berk_base.main_boolean:get() then
            local dropbox_options = {"No filter", "Elite & Boss Only", "Boss Only"}
            menu_elements_wrath_of_berk_base.filter_mode:render("Filter Modes", dropbox_options, "")
            menu_elements_wrath_of_berk_base.min_max_targets:render("Min Enemies Around", "Amount of targets to cast the spell")
        end

        menu_elements_wrath_of_berk_base.tree_tab:pop()
    end
end

local next_time_allowed_cast = 0.0;
local spell_id_wrath = 211871;


local function logics()

    local menu_boolean = menu_elements_wrath_of_berk_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean,
                next_time_allowed_cast,
                spell_id_wrath);

    if not is_logic_allowed then
    return false;
    end;

    local filter_mode = menu_elements_wrath_of_berk_base.filter_mode:get()
    local player_pos = get_player_position()
    local area_data = target_selector.get_most_hits_target_circular_area_light(player_pos, 5.0, 5.0, false)
    local units = area_data.n_hits
    local elite_units, champion_units, boss_units = my_utility.should_pop_cds()

    --[[if filter_mode == 1 then
        -- boss / elite
        if elite_units < 1 and champion_units < 1 and boss_units < 1 then
            return false
        end
    end

    if filter_mode == 2 then
        -- boss only
        if boss_units < 1 then
            return false
        end
    end

    if filter_mode ~= 1 and filter_mode ~= 2 then
        if units < menu_elements_wrath_of_berk_base.min_max_targets:get() then
            return false;
        end
    end
    ]]

    if  (filter_mode == 1 and elite_units >= 1 or champion_units >= 1 or boss_units >= 1)
        or (filter_mode == 2 and boss_units >= 1)
        or (units >= menu_elements_wrath_of_berk_base.min_max_targets:get())
    then
        if cast_spell.self(spell_id_wrath, 0.0) then
            -- ignore global cooldown -- test 04/06/2024 -- qqt
            local current_time = get_time_since_inject();
            next_time_allowed_cast = current_time + 0.4;
            console.print("Casted wrath of the berserk")
            return true;
        end
    end

    return false;
end

return
{
    menu = menu,
    logics = logics,
}