local function GetGroupMembers()
    local members = {}
    for i = 1, MAX_RAID_MEMBERS, 1 do
        local name = GetRaidRosterInfo(i)
        if name ~= nil then
            members[i] = name
        end
    end

    return members
end

local function IsInGroupWith(playerName)
    local members = GetGroupMembers()

    for _, name in pairs(members) do
        if name == playerName then
            return true
        end
    end

    return false
end

function IWM_GroupUtility.ShouldRespondToBlameRequest(fromName)
    if not IsInGroup() then
        return false
    elseif IsInGroupWith(fromName) then
        return true
    else
        return false
    end
end

function IWM_GroupUtility.GetAppropriateChatChannel()
    if IsInRaid() then
        return 'RAID'
    elseif IsInGroup() then
        return 'PARTY'
    else
        return 'SAY'
    end
end
