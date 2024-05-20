-- Logs some game data to the console on the server side which is used to power the web interface.
-- Does nothing on the client side.
-- Also does practically nothing on the server without some other program reading the log.

-- Used to reduce spam
local log_timer = 0

-- A list of Self Propelled Bomb targets
local spb_targets = {}

-- A list of recently exploded players
local recent_explosions = {}

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
                tostring(lap) .. " " ..
                tostring(speed_percentage) .. " " ..
                tostring(players[playern].karthud[khud_ringdelay]) .. " " ..
                tostring(players[playern].name)
            )
        end
        playern = playern + 1
    end
    print("================ END PLAYERS DATA ================\n\n\n\n\n")

    -- Remove all recent explosions
    for k in pairs(recent_explosions) do
        recent_explosions[k] = nil
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

addHook("PreThinkFrame", reset)
addHook("PostThinkFrame", log_game_data)
addHook("MobjThinker", find_spb_target, MT_SPB)
addHook("MobjDeath", log_explosions, MT_PLAYER)
