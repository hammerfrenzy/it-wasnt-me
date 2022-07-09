-- Note: The name of the .toc file must  match the name of the addon's folder
-- Also, apparently Lua wants functions to be defined before they're used,
-- at least when they're thrown in ad hoc like this.

-----------------------------------------------
-- The answer to splitting functionality across files
-- seems to be "everything is global so just do"
-- https://authors.curseforge.com/forums/world-of-warcraft/general-chat/lua-code-discussion/224909-how-to-spread-code-over-files
-----------------------------------------------

GroupUtility = {}
PendingRolls = {}

-----------------------------------------------
-- MAIN BLAME LOGIC
-----------------------------------------------

-- Register our addon's chat prefix
local addonMessagePrefix = 'IWM_CHAT_PREFIX'
C_ChatInfo.RegisterAddonMessagePrefix(addonMessagePrefix)

-- Initiates a raid-wide blame roll by sending an addon
-- message to the raid channel with the blame start token.
local startBlameToken = 'IWM_BLAME_START'
local function StartBlameProcess()
    -- TODO: Update to use raid channel when we can test that
    local myName = UnitName('player')
    local addonPayload = startBlameToken .. ' ' .. myName
    local channel = 'GUILD'
    SendChatMessage('Okay wise guys, whose fault is this?', channel)
    C_ChatInfo.SendAddonMessage(addonMessagePrefix, addonPayload, channel)
end

-- When the raid leader initiates a blame roll,
-- generate a random d100 value, and then send
-- it via addon message in the format
-- [rollToken] [playerName] [rollValue]
-- so that we can parse the roll & who rolled it.
-- Put a humorous message in the visible chat.
local rollBlameToken = 'IWM_BLAME_ROLL'
local function DoBlameRoll(startedByName)
    -- If you triggered the roll, don't roll again.
    local myName = UnitName('player')
    if startedByName == myName then
        return
    end

    local roll = math.random(100)
    local addonPayload = rollBlameToken .. ' ' .. myName .. ' ' .. roll
    -- TODO: Update to use raid channel when we can test that
    local channel = 'GUILD'

    SendChatMessage('Wasn\'t me, boss', channel)
    C_ChatInfo.SendAddonMessage(addonMessagePrefix, addonPayload, channel)
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
    print(sender .. ' sent \'' .. message .. '\' ' .. ' in ' .. channel)

    -- Split the message into its event & parameters.
    -- The first parameter should always be our custom event.
    local iwmEvent, parameters = strsplit(' ', message, 2)
    if iwmEvent == startBlameToken then
        DoBlameRoll(parameters)
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
