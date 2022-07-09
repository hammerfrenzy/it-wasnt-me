-- Maps players to their rolls
local rollMap = {}

-- List of players that haven't logged a roll yet
local waitingOnPlayers = {}

function PendingRolls.StartNewBlame()
    local members = {}
    for i = 1, MAX_RAID_MEMBERS, 1 do
        local name = GetRaidRosterInfo(i)
        if name ~= nil then
            members[i] = name
        end
    end

    return members
end
