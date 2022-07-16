function IWM_RollUtility.EmoteForRoll(roll)
    local message = ''

    -- General case messages
    if roll <= 9 then
        message = 'fumbles the die! It comes up ' .. roll .. '!'
    elseif roll <= 29 then
        message = 'rolls the die off the table. After picking it up, it\'s only a ' .. roll .. '.'
    elseif roll <= 49 then
        message = 'throws the die as hard as they can... but only gets a ' .. roll .. '.'
    elseif roll <= 69 then
        message = 'makes an OK roll and gets an OK result of ' .. roll .. '.'
    elseif roll <= 89 then
        message = 'rolls with precision! A ' .. roll .. '!'
    else
        message = 'has a gleam in their eye. The die shows ' .. roll .. '!'
    end

    -- Special messages
    if roll == 69 then
        message = 'unleashes a secret technique! The die rolls... it\'s a 69!!!'
    end

    if roll == 100 then
        message = 'scores a critical hit! It\'s a perfect 100!'

    end

    SendChatMessage(message, 'EMOTE')
end

local rollLog = {}

-- A local function get how many entries
-- are currently in the roll log.
local function GetRollCount()
    local count = 0
    for _ in pairs(rollLog) do
        count = count + 1
    end

    return count
end

-- Saves a roll for a player in the user's blame log.
-- Returns true if the log count matches group count
-- (so we can trigger the end ceremony), and false otherwise.
function IWM_RollUtility.LogRollForPlayer(roll, playerName)
    rollLog[playerName] = roll

    local playersInGroup = GetNumGroupMembers()
    local rollCount = GetRollCount()
    return playersInGroup == rollCount
end

-- Returns the name(s) of the players who logged
-- the lowest roll. If there is more than one
-- player with this roll, their names are returned
-- with a space separating each name.
function IWM_RollUtility.GetLowestRollerNames()
    local lowestNames = ''
    local lowestRoll = 101

    for name, stringRoll in pairs(rollLog) do
        local roll = tonumber(stringRoll)
        if roll <= lowestRoll and roll ~= 69 then
            if roll == lowestRoll then
                -- concat if it was a tie
                lowestNames = lowestNames .. ' ' .. name
            else
                -- overwrite if it loses to previous low
                lowestNames = name
            end

            lowestRoll = roll
        end
    end

    return lowestNames
end

-- Resets the rolls we have saved in the user's roll log.
-- Should be called each time the user starts a blame request.
function IWM_RollUtility.ResetRollLog()
    for k, _ in pairs(rollLog) do
        rollLog[k] = nil
    end
end
