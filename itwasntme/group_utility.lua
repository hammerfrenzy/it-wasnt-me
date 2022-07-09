function GroupUtility.GetRaidMembers()
    local members = {}
    for i = 1, MAX_RAID_MEMBERS, 1 do
        local name = GetRaidRosterInfo(i)
        if name ~= nil then
            members[i] = name
        end
    end

    return members
end
