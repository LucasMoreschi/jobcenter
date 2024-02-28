----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

--[[
    FRAMEWORK 
]]

framework = config.resource_settings.framework
notifications = config.resource_settings.notifications
drawtext_ui = config.resource_settings.drawtext_ui

-- Init framework objects if available
if framework == 'boii_base' then
    fw = exports['boii_base']:get_object()
elseif framework == 'qb-core' then
    fw = exports['qb-core']:GetCoreObject()
elseif framework == 'esx_legacy' then
    fw = exports['es_extended']:getSharedObject()
elseif framework == 'ox_core' then    
    -- TO DO: add ox relevant code
elseif framework == 'custom' then
    -- Add code for your own framework here
end

--[[
    FUNCTIONS
]]

-- Function to get player data
function get_player_data()
    print('get_player_data triggered')
    local player, player_name, player_jobs
    
    if framework == 'boii_base' then
        player = fw.get_data()
        player_name = player.identity.first_name
    elseif framework == 'qb-core' then
        player = fw.Functions.GetPlayerData()
        player_name = player.charinfo.firstname
    elseif drawtext_ui == 'esx_legacy' then
        player = fw.GetPlayerData()
        player_name = player.getName()
    elseif drawtext_ui == 'custom' then
        -- Add code for your own drawtext
    end

    local player_data = {
        name = player_name,
    }

    return player_data
end

-- Function to send notifications
function notify(header, message, type, duration)
    if notifications == 'boii_ui' then
        exports['boii_ui']:notify(header, message, type, duration)
    end
end


-- Function to hide drawtext
function hide_drawtext()

    if drawtext_ui == 'boii_ui' then
        exports['boii_ui']:hide_drawtext()
    elseif drawtext_ui == 'qb-core' then
        exports['qb-core']:HideText()
    elseif drawtext_ui == 'esx_legacy' then
        -- TO DO: add esx_legacy relevant code
    elseif drawtext_ui == 'custom' then
        -- Add code for your own drawtext
    end

end

-- Function to display drawtext
function display_drawtext(label)
    local label = label or nil
    local message = 'Press [E] to open job center.'

    if drawtext_ui == 'boii_ui' then
        exports['boii_ui']:show_drawtext(label, message, 'default')
    elseif drawtext_ui == 'qb-core' then
        exports['qb-core']:DrawText(message, 'left')
    elseif drawtext_ui == 'esx_legacy' then
        -- TO DO: add esx_legacy relevant code
    elseif drawtext_ui == 'custom' then
        -- Add code for your own drawtext  
    end

end

-- Function to handle notifications
function handle_notifications(notif)

    if notif == 'locate_job' then
        notify('JOB CENTER', 'The location to start the job has been set on your GPS.', 'primary', 3500)
    elseif notif == '' then

    elseif notif == '' then

    elseif notif == '' then

    end

end

--[[
    CALL BACK FUNCTIONS
]]

-- Function to callback job rep data
function callback_job_rep_data(cb)
    if framework == 'boii_base' then
        fw.callback('boii_jobcenter:sv:get_jobs_data', {}, function(received_jobs_data)
            if not received_jobs_data then
                print("No job reputation data received.")
            end
            if cb then
                cb(received_jobs_data)
            end            
        end)

    elseif framework == 'qb-core' then
        fw.Functions.TriggerCallback('boii_jobcenter:sv:get_jobs_data', function(received_jobs_data)
            if not received_jobs_data then
                print("No job reputation data received.")
            end
            if cb then
                cb(received_jobs_data)
            end            
        end)

    elseif framework == 'esx_legacy' then
        fw.TriggerServerCallback('boii_jobcenter:sv:get_jobs_data', function(received_jobs_data)
            if not received_jobs_data then
                print("No job reputation data received.")
            end
            if cb then
                cb(received_jobs_data)
            end            
        end)
    end
end
