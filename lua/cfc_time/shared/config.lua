CFCTime.Config = CFCTime.Config or {}
local config = CFCTime.Config

local configFilename = "cfc_time/config.json"

-- other files should access this config using the 'get' function
-- CFCTime.ctime.Config.get("updateInterval")

-- defaults
config.values = {
    updateInterval = 10,
    storageType = "sqlite",
    realm = "default"
}

function config.save()
    file.CreateDir("cfc_time")
    file.Write( configFilename, util.TableToJSON( config.values, true ))
end

function config.load()
    local data = file.Read( configFilename ) or ""
    local values = util.JSONToTable( data ) or {}
    table.Merge( config.values, values )
end

function config.setDefaults( tbl )
    for k, v in pairs( tbl ) do
        if not config.values[k] then
            config.values[k] = v
        end
    end
    config.load()
    config.save()
end

local function configInit()
    config.load()
    config.save()
end


function config.set( key, value )
    if not config.values[key] then return end
    config.values[key] = value
end

function config.get( key )
    return config.values[key]
end

function config.getType( key )
    return type(config.values[key])
end

local function commandSet( ply, cmd, args )
    local key = args[1]
    local value = args[2]

    if not value or not key then return end

    if config.getType( key ) == "nil" then
        return ply:PrintMessage( HUD_PRINTCONSOLE, "invalid config key "..key)
    end

    if config.getType( key ) == "number" then
        value = tonumber(value)
    end

    config.set( key, value )
    config.save()
    ply:PrintMessage( HUD_PRINTCONSOLE, key.."="..value)
    ply:PrintMessage( HUD_PRINTCONSOLE, "A server restart may be required for these changes to take effect" )
end

if SERVER then
    concommand.Add( "cfc_time_config_set", commandSet )
else
    concommand.Add( "cfc_time_config_set_client", commandSet )
end

configInit()
