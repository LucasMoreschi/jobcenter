----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

--[[
    FRAMEWORK 
]]

framework = config.resource_settings.framework

if framework == 'boii_base' then
    fw = exports['boii_base']:get_object()
elseif framework == 'qb-core' then
    fw = exports['qb-core']:GetCoreObject()
elseif framework == 'esx_legacy' then
    fw = exports['es_extended']:getSharedObject()
elseif framework == 'ox_core' then    
    -- TO DO:
elseif framework == 'custom' then
    -- add code for your own framework here
end

--[[
    FUNCTIONS
]]

-- Function to create sql table on load if not created already
local function create_tables()
    local query
    
    if framework == 'boii_base' then
        query = string.format([[
            CREATE TABLE IF NOT EXISTS `%s` (
                `unique_id` varchar(255) NOT NULL,
                `char_id` int(1) NOT NULL DEFAULT 1,
                `reputation` json DEFAULT '{}',
                PRIMARY KEY (`unique_id`, `char_id`)
                CONSTRAINT `fk_job_reputation_players` FOREIGN KEY (`unique_id`, `char_id`)
                REFERENCES `players` (`unique_id`, `char_id`) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]], config.sql.table_name)
    elseif framework == 'qb-core' then
        query = string.format([[
            CREATE TABLE IF NOT EXISTS `%s` (
                `citizenid` varchar(50) NOT NULL,
                `reputation` json DEFAULT '{}',
                PRIMARY KEY (`citizenid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]], config.sql.table_name)
    elseif framework == 'esx_legacy' then 
        query = string.format([[
            CREATE TABLE IF NOT EXISTS `%s` (
                `identifier` varchar(60) NOT NULL,
                `reputation` json DEFAULT '{}',
                PRIMARY KEY (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]], config.sql.table_name)              
    elseif framework == 'ox_core' then
        -- TO DO:
    elseif framework == 'custom' then
        -- Add the table schema required for your custom framework here

    end

    MySQL.Async.execute(query, {})
end
create_tables()

-- Function to get a player
function get_player(_src)
    if framework == 'boii_base' then
        player = fw.get_user(_src)
    elseif framework == 'qb-core' then
        player = fw.Functions.GetPlayer(_src)
    elseif framework == 'esx_legacy' then
        player = fw.GetPlayerFromId(_src)
    elseif framework == 'ox_core' then
        -- TO DO:
    elseif framework == 'custom' then
        -- Add your own custom entry here.
    end
    return player
end

-- Function to get identifier and prepare database statement
function get_db_params(_src)
    local player = get_player(_src)
    local query, params
    if framework == 'boii_base' then
        query = 'unique_id = ? AND char_id = ?'
        params = { player.unique_id, player.char_id }
    elseif framework == 'qb-core' then
        query = 'citizenid = ?'
        params = { player.PlayerData.citizenid }
    elseif framework == 'esx_legacy' then
        query = 'identifier = ?'
        params = { player.identifier }
    elseif framework == 'ox_core' then
        -- TO DO:
    elseif framework == 'custom' then
        -- Add your own custom entry here.
    end
    return query, params
end

-- Function to get columns, values, and parameters for insert
function get_insert_params(_src, data)
    local player = get_player(_src)
    local columns, values, params
    
    local rep_data = {}
    rep_data[data.job.job.job_name] = data.job.reputation
    
    if framework == 'boii_base' then
        columns = {'unique_id', 'char_id', 'reputation'}
        values = '?, ?, ?'
        params = { player.unique_id, player.char_id, json.encode(rep_data) }
    elseif framework == 'qb-core' then
        columns = {'citizenid', 'reputation'}
        values = '?, ?'
        params = { player.PlayerData.citizenid, json.encode(rep_data) }
    elseif framework == 'esx_legacy' then
        columns = {'identifier', 'reputation'}
        values = '?, ?'
        params = { player.identifier, json.encode(rep_data) }
    elseif framework == 'ox_core' then
        -- TO DO:
    elseif framework == 'custom' then
        -- Add your own custom entry here.
    end

    return columns, values, params
end

-- Function to set a players job
function set_job(_src, player, job_name, job_grade)

    if framework == 'boii_base' then
        player.set_job(job_name, job_grade)
        TriggerClientEvent('boii_jobcenter:notify', _src, 'JOB CENTER', 'Your job has been set to ' .. job_name .. ' ' .. job_grade, 'primary', 3500)
    elseif framework == 'qb-core' then
        player.Functions.SetJob(job_name, job_grade)
        TriggerClientEvent('boii_jobcenter:notify', _src, nil, 'Your job has been set to ' .. job_name .. ' ' .. job_grade, 'primary', 3500)
    elseif framework == 'esx_legacy' then
        if fw.DoesJobExist(job_name, job_grade) then
            player.setJob(job_name, job_grade)
        end
        TriggerClientEvent('boii_jobcenter:notify', _src, nil, 'Your job has been set to ' .. job_name .. ' ' .. job_grade, 'primary', 3500)
    elseif framework == 'ox_core' then
        -- TO DO:
    elseif framework == 'custom' then
        -- Add your own custom entry here.
    end

end

--[[
    CALLBACKS
]]

if framework == 'boii_base' then
    
    -- Callback to get all jobs and their reputations for a player
    fw.register_callback('boii_jobcenter:sv:get_jobs_data', function(source, data, cb)
        local _src = source
        local player = get_player(_src)
        if not player then return end
        local jobs_data = get_all_player_jobs(_src)
        if jobs_data then
            cb(jobs_data)
        else
            cb(nil)
        end
    end)

elseif framework == 'qb-core' then
    
    -- Callback to get all jobs and their reputations for a player
    fw.Functions.CreateCallback('boii_jobcenter:sv:get_jobs_data', function(source, cb)
        local _src = source
        local player = get_player(_src)
        if not player then return end
        local jobs_data = get_all_player_jobs(_src)
        if jobs_data then
            cb(jobs_data)
        else
            cb(nil)
        end
    end)

elseif framework == 'esx_legacy' then

    -- Callback to get all jobs and their reputations for a player
    fw.RegisterServerCallback('boii_jobcenter:sv:get_jobs_data', function(source, cb)
        local _src = source
        local player = get_player(_src)
        if not player then return end
        local jobs_data = get_all_player_jobs(_src)
        if jobs_data then
            cb(jobs_data)
        else
            cb(nil)
        end
    end)


elseif framework == 'ox_core' then
    -- TO DO:
elseif framework == 'custom' then    
    -- Add your own callback method here
end
