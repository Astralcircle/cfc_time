return function(instance)
local player_methods, player_meta = instance.Types.Player.Methods, instance.Types.Player

local getply
instance:AddHook("initialize", function()
    getply = player_meta.GetPlayer
end)

--- Returns the player has played in seconds. Returns 0 on failure.
-- @shared
-- @return number Played time
function player_methods:getTimePlayed()
    return getply(self):GetUTimeTotalTime()
end

end