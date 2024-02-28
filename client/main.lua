----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

-- Variables
local created_peds = {}
local created_blips = {}
local keypressed = false

--[[
    FUNCTIONS
]]

-- Helper function to request model
local function request_model(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

-- Function to create blips
local function create_blips()
    for _, location in pairs(config.locations) do
        if location.blip and location.blip.show then
            local blip = AddBlipForCoord(location.blip.coords.x, location.blip.coords.y, location.blip.coords.z)
            SetBlipSprite(blip, location.blip.sprite)
            SetBlipColour(blip, location.blip.colour)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, location.blip.scale)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(location.blip.label)
            EndTextCommandSetBlipName(blip)
            created_blips[#created_blips + 1] = blip
        end
    end
end

-- Function to create peds
local function create_peds()
    for _, location in pairs(config.locations) do
        if location.ped and location.ped.use then
            local model = GetHashKey(location.ped.model)
            request_model(model)
            local ped = CreatePed(4, model, location.ped.coords.x, location.ped.coords.y, location.ped.coords.z-1, location.ped.coords.w, false, false)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)
            if location.ped.scenario then
                TaskStartScenarioInPlace(ped, location.ped.scenario, 0, true)
            end
            SetModelAsNoLongerNeeded(model)
            created_peds[#created_peds + 1] = ped
        end
    end
end

-- Function to remove peds and blips
local function delete_all_peds_and_blips()
    for _, ped in ipairs(created_peds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    for _, blip in ipairs(created_blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    created_peds = {}
    created_blips = {}
end

-- Function to get closest location to player
local function get_closest_loc(coords)
    local closest_location = nil
    local closest_location_distance = 10
    for location_key, location in pairs(config.locations) do
        local blip_coords = vector3(location.blip.coords.x, location.blip.coords.y, location.blip.coords.z)
        local blip_distance = #(coords - blip_coords)
        if blip_distance < closest_location_distance then
            closest_location_distance = blip_distance
            closest_location = { location = location, location_key = location_key }
        end
    end
    return closest_location
end

-- Function to open job center ui
local function open_jobcenter(location)
    callback_job_rep_data(function(rep_data)
        local player = get_player_data()
        if not player then print('no player found') return end
        if rep_data then
            player.reputation = rep_data
        end
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open_jobcenter',
            location_key = location,
            player = player,
            jobs = config.jobs_data
        })
    end)
end

-- Function to handle keypress
local function handle_keypress(location)
    CreateThread(function()
        keypressed = true
        while keypressed do
            if IsControlJustPressed(0, 38) then
                hide_drawtext()
                open_jobcenter(location)
                keypressed = false
            end
            Wait(0)
        end
    end)
end

-- Function to create polyzones
local function create_zones()
    CreateThread(function()
        local jobcenter_zones = {}
        for _, jobcenter in pairs(config.locations) do
            jobcenter_zones[#jobcenter_zones+1] = BoxZone:Create(vector3(jobcenter.ped.coords.x, jobcenter.ped.coords.y, jobcenter.ped.coords.z), 2.5, 2.5, {
                heading = 0,
                name= jobcenter.id,
                debugPoly = false,
                minZ = jobcenter.ped.coords.z - 1,
                maxZ = jobcenter.ped.coords.z + 1,
            })
        end
        local jobcenter_locations = ComboZone:Create(jobcenter_zones, {name = 'jobcenter_zones'})
        jobcenter_locations:onPlayerInOut(function(is_inside)
            local player_coords = GetEntityCoords(PlayerPedId())
            local location_data = get_closest_loc(player_coords)
            if is_inside then
                display_drawtext(location_data.location.ped.label)
                handle_keypress(location_data.location_key)
            else
                keypressed = false
                hide_drawtext()
            end
        end)
    end)
end

-- Function to init resource
local function init()
    create_blips()
    create_peds()
    create_zones()
end
init()

--[[
    NUI
]]

-- Callback to close ui
RegisterNUICallback('close_ui', function(data, cb)
    SetNuiFocus(false, false)
    if cb then
        cb('ok')
    end
end)

-- Callback to accept a job
RegisterNUICallback('accept_job', function(data, cb)
    print(data.location)
    if data.job and data.job.job then
        TriggerServerEvent('boii_jobcenter:sv:accept_job', data)
    else
        print("Error: Job details not found in data.")
    end

    if cb then
        cb('ok')
    end
end)


-- Callback to locate job
RegisterNUICallback('locate_job', function(data, cb)
    SetNewWaypoint(data.x, data.y)
    handle_notifications('locate_job')
    if cb then
        cb('ok')
    end
end)

--[[
    EVENTS
]]

-- Event to send notifications
RegisterNetEvent('boii_jobcenter:notify', function(header, message, type, duration)
    notify(header, message, type, duration)
end)