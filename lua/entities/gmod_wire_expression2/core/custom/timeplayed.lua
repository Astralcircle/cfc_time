e2function number entity:getTimePlayed()
    if not IsValid(this) then return self:throw("Invalid entity!", 0) end
    if not this:IsPlayer() then return self:throw("Expected a Player but got an entity!", 0) end
    return this:GetUTimeTotalTime()
end