-- Logs some game data to the console on the server side which is used to power the web interface.
-- Does nothing on the client side.
-- Also does practically nothing on the server without some other program reading the log.

-- Used to reduce spam
local log_timer = 0

-- A list of Self Propelled Bomb targets
local spb_targets = {}

-- A list of recently exploded players
local recent_explosions = {}

-- A list of recently damaged players
local recent_damaged = {}

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local function log_khaos()
    -- CHAOS, CHAOS!
    print("================BEGIN KHAOS DATA================")
    print(TailsKK.PreviousUniversalEffect)
    local playern = 0
    while playern < #players do
        if players[playern] == nil then
            break
        end
        if not players[playern].spectator then
            local khaos_data = ""
            for key, effect in pairs(players[playern].khaoseffects) do
                if #khaos_data ~= 0 then
                    khaos_data = khaos_data .. ";"
                end
                -- print(dump(effect))
                khaos_data = khaos_data ..
                    tostring(effect.icon) .. "|" .. 
                    tostring(effect.notimer) .. "|" ..
                    tostring(effect.timer) .. "|" ..
                    tostring(effect.duration) .. "|" ..
                    tostring(effect.noblink)
                local effect_data = KhaosEffectsTable[effect.effect]
                khaos_data = khaos_data .. "|" .. 
                    tostring(effect_data.etype) .. "|" .. 
                    tostring(effect_data.name)
            end
            print(
                tostring(#khaos_data) .. "|" ..
                khaos_data ..
                tostring(players[playern].name)
            )
        end
        playern = playern + 1
    end
    print("================ END KHAOS DATA ================\n\n\n\n\n")
end

local function log_game_data()
    if consoleplayer ~= server then
        return
    end

    if log_timer > 0 then
        log_timer = log_timer - 1
        return
    end
    log_timer = 30
    print("================BEGIN PLAYERS DATA================")
    local playern = 0
    while playern < #players do
        if players[playern] == nil then
            break
        end
        if not players[playern].spectator then
            local lap = players[playern].latestlap
            if lap > numlaps then
                lap = -1
            end
            local speed_percentage = (players[playern].speed * 100) / K_GetKartSpeed(players[playern], false, true)
            print(
                tostring(players[playern].position) .. " " ..
                tostring(players[playern].rings) .. " " ..
                tostring(spb_targets[players[playern].name] ~= nil) .. " " ..
                tostring(recent_explosions[players[playern].name] ~= nil) .. " " ..
                tostring(recent_damaged[players[playern].name] ~= nil) .. " " ..
                tostring(lap) .. " " ..
                tostring(speed_percentage) .. " " ..
                tostring(players[playern].karthud[khud_ringdelay]) .. " " ..
                tostring(players[playern].name)
            )
        end
        playern = playern + 1
    end
    print("================ END PLAYERS DATA ================\n\n\n\n\n")
    
    if TailsKK ~= nil then
        log_khaos()
    end

    -- Remove all recent explosions
    for k in pairs(recent_explosions) do
        recent_explosions[k] = nil
    end
    -- Remove all recent damage
    for k in pairs(recent_damaged) do
        recent_damaged[k] = nil
    end
end

local function find_spb_target(spb)
    if consoleplayer ~= server then
        return
    end

    if spb.tracer then
        spb_targets[spb.tracer.player.name] = true
    end
end

local function log_damage(target, inflictor, source, damage, damagetype)
    if consoleplayer ~= server then
        return
    end

    recent_damaged[target.player.name] = true
end

local function log_explosions(target, inflictor, source, damagetype)
    if consoleplayer ~= server then
        return
    end
    if damagetype < DMG_INSTAKILL then
        return
    end

    recent_explosions[target.player.name] = true
end

local function reset()
    if consoleplayer ~= server then
        return
    end

    -- Remove all Self Propelled Bomb targets
    for k in pairs(spb_targets) do
        spb_targets[k] = nil
    end
end

local function log_match_results()
    if consoleplayer ~= server then
        return
    end

    print("================BEGIN RESULTS DATA================")
    local playern = 0
    while playern < #players do
        if players[playern] == nil then
            break
        end
        if not players[playern].spectator then
            local position = players[playern].position
            if players[playern].exiting == 0 then
                position = -1
            end
            print(
                tostring(position) .. " " ..
                tostring(players[playern].name)
            )
        end
        playern = playern + 1
    end
    print("================ END RESULTS DATA ================\n\n\n\n\n")
end

addHook("PreThinkFrame", reset)
addHook("PostThinkFrame", log_game_data)
addHook("MobjThinker", find_spb_target, MT_SPB)
addHook("MobjDeath", log_explosions, MT_PLAYER)
addHook("MobjDamage", log_damage, MT_PLAYER)
addHook("IntermissionThinker", log_match_results)
