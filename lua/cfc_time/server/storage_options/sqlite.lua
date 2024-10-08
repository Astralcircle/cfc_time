include( "utils/sqlite.lua" )

local storage = CFCTime.Storage
local utils = CFCTime.Utils

hook.Add( "PostGamemodeLoaded", "CFC_Time_DBInit", function()
    storage:SetupTables()
    storage:RunSessionCleanup()
end )

--[ API Begins Here ]--

function storage:UpdateBatch( batchData, callback )
    if not batchData then return callback() end
    if table.IsEmpty( batchData ) then return callback() end

    sql.Begin()

    for sessionID, data in pairs( batchData ) do
        local updateStr = utils:buildSessionUpdate( sessionID, data )
        sql.Query( updateStr )
    end

    sql.Commit()

    callback()
end

function storage:GetTotalTime( steamID, callback )
    local data = self:QueryTotalTime( steamID )
    local sum = data[1]["SUM(duration)"]

    if callback then callback( sum ) end

    return sum
end

function storage:CreateSession( steamID, sessionStart, duration )
    local sessionEnd = sessionStart + duration
    self:QueryCreateSession( steamID, sessionStart, sessionEnd, duration )
end

function storage:PlayerInit( ply, sessionStart, callback )
    local steamID = ply:SteamID64()

    sql.Begin()

    local isFirstVisit = self:QueryGetUser( steamID ) == nil
    self:QueryCreateUser( steamID )
    self:QueryCreateSession( steamID, sessionStart, SQL_NULL, 0 )

    sql.Commit()

    local sessionID = tonumber( self:QueryLatestSessionId()[1]["last_insert_rowid()"] )

    local response = {
        isFirstVisit = isFirstVisit,
        sessionID = sessionID
    }

    callback( response )
end
