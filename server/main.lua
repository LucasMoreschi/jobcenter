----------------------------------get_reputation
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

-- Variables

--[[
    FUNCTIONS
]]

-- Function to calculate required rep for next level
local function calculate_required_rep(current_level, first_level_rep, growth_factor)
    return first_level_rep * (growth_factor ^ (current_level - 1))
end

-- Function to get player reputation for a specific job
local function get_reputation(_src, job_name)
    local query_part, params = get_db_params(_src)
    local query = string.format('SELECT reputation FROM %s WHERE %s', config.sql.table_name, query_part)
    local response = MySQL.query.await(query, params)
    if response then
        for i = 1, #response do
            local row = response[i]
            local rep_data = json.decode(row.reputation)
            if rep_data and rep_data[job_name] then
                return rep_data[job_name]
            end
        end
    end
    return nil
end

-- Function to get all player job reputations
local function get_all_reputations(_src)
    local query_part, params = get_db_params(_src)
    local query = string.format('SELECT * FROM %s WHERE %s', config.sql.table_name, query_part)
    local response = MySQL.query.await(query, params)
    if response and #response > 0 then
        return json.decode(response[1].reputation)
    end
    return {}
end

-- Function to modify a specific job's reputation
local function modify_reputation(_src, job_name, value, operation)
    local all_rep_data = get_all_reputations(_src)
    if not all_rep_data then 
        print("Error: Could not fetch current reputation data for player")
        return false
    end
    if not all_rep_data[job_name] then
        print("Error: No reputation data found for job:", job_name)
        return false
    end
    if operation == "add" then
        all_rep_data[job_name].current_rep = all_rep_data[job_name].current_rep + value
    elseif operation == "remove" then
        all_rep_data[job_name].current_rep = all_rep_data[job_name].current_rep - value
    elseif operation == "set" then
        all_rep_data[job_name].current_rep = value
    else
        print("Error: Invalid operation specified for modify_reputation.")
        return false
    end
    local query_part, params = get_db_params(_src)
    local updated_params = { json.encode(all_rep_data) }
    for _, v in ipairs(params) do
        updated_params[#updated_params + 1] = v
    end
    local query = string.format('UPDATE %s SET reputation = ? WHERE %s', config.sql.table_name, query_part)
    local affectedRows = MySQL.Sync.execute(query, updated_params)
    if affectedRows > 0 then
        return true
    else
        return false
    end
end

-- Function to get all player jobs from rep table
function get_all_player_jobs(_src)
    local query_part, params = get_db_params(_src)
    local query = string.format('SELECT reputation FROM %s WHERE %s', config.sql.table_name, query_part)
    local result = MySQL.Sync.fetchAll(query, params)
    if result and #result > 0 then
        return json.decode(result[1].reputation)
    else
        return nil
    end
end

-- Function to insert rep entry for new jobs
local function insert_player_reputation(_src, data)
    local columns, values, params = get_insert_params(_src, data)
    local query = string.format('INSERT IGNORE INTO %s (%s) VALUES (%s)', config.sql.table_name, table.concat(columns, ", "), values)
    MySQL.insert(query, params)
end

-- Function to update existing reputation data for a player
local function update_player_reputation(_src, rep_data)
    local query_part, params = get_db_params(_src)
    local query = string.format('UPDATE %s SET reputation = ? WHERE %s', config.sql.table_name, query_part)
    MySQL.execute(query, { json.encode(rep_data), table.unpack(params) })
end

--[[
    EVENTS
]]

-- Event to set accept a job
RegisterServerEvent('boii_jobcenter:sv:accept_job', function(data)
    local _src = source
    if not _src then if config.debug then print('no source found') end return end
    if not data then if config.debug then print('no job details found') end return end

    local player = get_player(_src)
    if not player then if config.debug then print('no player found') end return end
    local player_coords = GetEntityCoords(GetPlayerPed(_src))
    local job_location
    for location, location_data in pairs(config.locations) do
        if location == data.location then
            job_location = vector3(location_data.blip.coords.x, location_data.blip.coords.y, location_data.blip.coords.z)
        end
    end
    if not job_location then if config.debug then print("Error: Job location not found!") end return end
    local distance = #(player_coords - job_location)
    if distance > 20.0 then 
        DropPlayer(_src, "Your were dropped for exploiting an event!") 
        return 
    end
    local all_rep_data = get_all_player_jobs(_src)
    if not all_rep_data then
        insert_player_reputation(_src, data)
    else
        if not all_rep_data[data.job.job.job_name] then
            all_rep_data[data.job.job.job_name] = data.job.reputation
            update_player_reputation(_src, all_rep_data)
        end
    end
    if all_rep_data == nil then 
        grade = 0
    else
        local job_rep_data = all_rep_data[data.job.job.job_name]
        grade = job_rep_data.level
    end
    set_job(_src, player, data.job.job.job_name, grade)
end)

--[[
    EXPORTS
]]

exports('get_reputation', get_reputation)
exports('modify_reputation', modify_reputation)