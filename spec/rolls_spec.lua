describe("roll tracking", function()
    it("should append rolls to database", function()
         _G._TEST = true
         _G.GimmeTheLoot = {
           db = {
             profile = {
               rolls = {}
           }}
         }
        require 'GimmeTheLoot'
        GimmeTheLoot:TrackLootRoll(1, 123456, nil)

        assert.are.same(_G.GimmeTheLoot.db.profile.rolls[1], {
                          time = 123456,
                          itemId = 1
        })
    end)
end)
