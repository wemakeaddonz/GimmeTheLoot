insulate('an insulated test', function()
    describe('roll tracking', function()
        it('should track rolls from chat messages', function()
            _G._TEST = true
            _G.GimmeTheLoot = {db = {profile = {rolls = {}}}}
            _G.pendingLootSessions = {}
            _G.time = function()
                return 12345
            end
            _G.GetItemInfo = function()
                return 'Pattern: Heavy Woolen Cloak'
            end
            require 'GimmeTheLoot'

            local item =
                '|cff1eff00|Hitem:4346::::::::60:::1::::|h[Pattern: Heavy Woolen Cloak]|h|r'

            GimmeTheLoot:START_LOOT_ROLL(1, nil, 1)
            GimmeTheLoot:LOOT_ITEM_AVAILABLE(item, 1)

            -- shouldn't do any processing of this

            GimmeTheLoot:CHAT_MSG_LOOT('|HlootHistory:3|h[Loot]|h: You have selected Greed for: ' ..
                                           item)

            GimmeTheLoot:CHAT_MSG_LOOT('|HlootHistory:3|h[Loot]|h: Swazzle passed on: ' .. item)

            -- vald greed 45
            GimmeTheLoot:CHAT_MSG_LOOT('|HlootHistory:3|h[Loot]|h: Greed Roll - 45 for ' .. item ..
                                           ' by Valdmere')
            GimmeTheLoot:CHAT_MSG_LOOT('You won: ' .. item)

            local rollResults = GimmeTheLoot:LOOT_ROLLS_COMPLETE(1)

            assert.are.same({
                item = 'Pattern: Heavy Woolen Cloak',
                rollID = 1,
                rollTime = 12345,
                rolls = {greeds = {Valdmere = 45}, needs = {}, passes = {Swazzle = true}},
                winner = 'You',
            }, rollResults)
        end)
    end)
end)
