-- Note: The name of the .toc file must  match the name of the addon's folder
-- Also, apparently Lua wants functions to be defined before they're used,
-- at least when they're thrown in ad hoc like this.

-- Group Utility functions attach to this
IWM_GroupUtility = {}

-- Roll Utility functions attach to this
IWM_RollUtility = {}

-----------------------------------------------
-- MAIN BLAME LOGIC
-----------------------------------------------

local myName = UnitName('player')

-- Register our addon's chat prefix

local addonMessagePrefix = 'IWM_CHAT_PREFIX'
local addonChannel = 'RAID'
C_ChatInfo.RegisterAddonMessagePrefix(addonMessagePrefix)

-- Initiates a raid-wide blame roll by sending an addon
-- message to the raid channel with the blame start token.
local startBlameToken = 'IWM_BLAME_START'
local function StartBlameProcess()
    IWM_RollUtility.ResetRollLog()
    SendChatMessage('It\'s blamin\' time.', 'PARTY')

    -- local myName = UnitName('player')
    local addonPayload = startBlameToken .. ' ' .. myName
    C_ChatInfo.SendAddonMessage(addonMessagePrefix, addonPayload, addonChannel)
end

-- Sends a message for everyone to poke fun at the 'loser'
local function PerformEndCeremony()
    local lowestRollerNames = IWM_RollUtility.GetLowestRollerNames()
    local message = 'Looks like ' .. lowestRollerNames .. ' is our clown.'
    SendChatMessage(message, 'PARTY')
end

-- When the raid leader initiates a blame roll,
-- generate a random d100 value, and then send
-- it via addon message in the format
-- [rollToken] [initiatedByName] [rolledByName] [rollValue]
-- so that we can parse the roll & who rolled it.
-- Make an emote based on the roll.
local rollBlameToken = 'IWM_BLAME_ROLL'
local function MakeBlameRoll(initiatedByName)
    local roll = math.random(100)
    -- local rolledByName = UnitName('player')
    local addonPayload = rollBlameToken .. ' ' .. initiatedByName .. ' ' .. myName .. ' ' .. roll
    C_ChatInfo.SendAddonMessage(addonMessagePrefix, addonPayload, addonChannel)
    IWM_RollUtility.EmoteForRoll(roll)
end

-----------------------------------------------
-- REGISTER SLASH COMMAND
-----------------------------------------------

-- We'll register this later to run when our slash command is recognized.
local function SlashCommandHandler(msg, _) -- _ here is 'editBox'
    StartBlameProcess()
end

-- Name the slash command. When the game sees this /[command] input,
-- it takes the name from SLASH_[YourNameHere] (ITWASNTME in our case)
-- and then uses that to check the global SlashCmdList.
SLASH_ITWASNTME1 = '/iwm'

-- Tell the game's chat handler what to run when the slash command is entered.
SlashCmdList['ITWASNTME'] = SlashCommandHandler

-----------------------------------------------
-- EVENT HANDLING
-- List of events: https://wowpedia.fandom.com/wiki/Events
-----------------------------------------------

-- Create a frame for listening to events
-- Events must come through a frame
local frame = CreateFrame('Frame')

-- A container to hold events we want to register
local events = {}

-- Fired when an addon sends a chat message
-- It sounds like these are supposed to be visible to players,
-- but I haven't been able to verify that. I don't see the
-- whisper that is sent as part of PLAYER_ENTERING_WORLD.
function events:CHAT_MSG_ADDON(prefix, message, channel, sender, ...)
    -- Filter out other addon's messages
    if prefix ~= addonMessagePrefix then
        return
    end

    -- Debug log our addon's events
    -- print(sender .. ' sent \'' .. message .. '\' ' .. ' in ' .. channel)

    -- Split the message into its event & parameters.
    -- The first parameter should always be our custom event.
    local iwmEvent, parameters = strsplit(' ', message, 2)
    if iwmEvent == startBlameToken then
        local initiatedBy = parameters -- start token is just the name
        local shouldRespondToBlame = IWM_GroupUtility.ShouldRespondToBlameRequest(initiatedBy)
        if shouldRespondToBlame then
            MakeBlameRoll(initiatedBy)
        end
    elseif iwmEvent == rollBlameToken then
        -- blame tokens are INITIATED_BY, ROLLING_PLAYER, ROLL
        local initiatedByName, playerName, roll = strsplit(' ', parameters)
        if initiatedByName == myName then -- only log rolls you asked for
            local isGroupDoneRolling = IWM_RollUtility.LogRollForPlayer(roll, playerName)
            if isGroupDoneRolling then
                PerformEndCeremony()
            end
        end
    end
end

-- Parameters sent by the event are
local function DispatchEvent(self, event, ...)
    events[event](self, ...)
end

-- Register the events we added to the events var
for event, _ in pairs(events) do
    frame:RegisterEvent(event)
end

-- Pass incoming events to the correct event handler
frame:SetScript("OnEvent", DispatchEvent)
