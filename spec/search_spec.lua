local fakeRollers = {
    'Basin',
    'Bullshizzle',
    'Congo',
    'Dyamito',
    'Eragdash',
    'Ixojos',
    'Karuga',
    'Lawlpwned',
    'Mosdef',
    'Panzesto',
    'Swischeese',
    'Waffles',
    'Zashin',
    'Zoke',
}

function FakeRollSession(numRollers, item)
    assert(numRollers >= 1 and numRollers <= 5)
    local session = {rolls = {}, item = item}

    for i = 0, numRollers do
        table.insert(session.rolls, {
            name = fakeRollers[math.random(#fakeRollers)],
            type = math.random(0, 3),
            roll = math.random(100),
        })
    end

    -- needs winner
    return session
end

_G._TEST = true
_G.GimmeTheLoot = {db = {profile = {records = {}}}}
require 'GimmeTheLoot'

describe('record searching', function()
    it('should match a record with a substring', function()
        local record = FakeRollSession(5, {
            link = '\124cffa335ee\124Hitem:29037::::::::120:::::\124h[Cyclone Shoulderguards]\124h\124r',
            name = 'Cyclone Shoulderguards',
            quality = 4,
        })

        assert.is.truthy(GimmeTheLoot:SearchMatchItemText('Cyclone', record))
        assert.is.falsy(GimmeTheLoot:SearchMatchItemText('NotCyclone', record))
    end)

    it('should match a record with a differently cased substring', function()
        local record = FakeRollSession(5, {
            link = '\124cffa335ee\124Hitem:29037::::::::120:::::\124h[Cyclone Shoulderguards]\124h\124r',
            name = 'Cyclone Shoulderguards',
            quality = 4,
        })

        assert.is.truthy(GimmeTheLoot:SearchMatchItemText('CyClONE', record))
        assert.is.falsy(GimmeTheLoot:SearchMatchItemText('NotCyclone', record))
    end)

    it('should match a record with a specific quality level', function()
        local record = FakeRollSession(5, {
            link = '\124cffa335ee\124Hitem:29037::::::::120:::::\124h[Cyclone Shoulderguards]\124h\124r',
            name = 'Cyclone Shoulderguards',
            quality = 4,
        })

        -- empty inputs for quality are trivially truthy
        assert.is.truthy(GimmeTheLoot:SearchMatchItemQuality(nil, record))
        assert.is.truthy(GimmeTheLoot:SearchMatchItemQuality({}, record))

        assert.is.truthy(GimmeTheLoot:SearchMatchItemQuality({[4] = true}, record))
        assert.is.truthy(GimmeTheLoot:SearchMatchItemQuality(
                             {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true}, record))

        assert.is.falsy(GimmeTheLoot:SearchMatchItemQuality(
                            {[1] = true, [2] = true, [3] = true, [5] = true}, record))
    end)
end)

describe('record searching over multiple records', function()
    it('should match a record with a substring', function()

        table.insert(_G.GimmeTheLoot.db.profile.records, FakeRollSession(5, {
            link = '\124cffa335ee\124Hitem:29037::::::::120:::::\124h[Cyclone Shoulderguards]\124h\124r',
            name = 'Cyclone Shoulderguards',
            quality = 4,
        }))
        table.insert(_G.GimmeTheLoot.db.profile.records, FakeRollSession(5, {
            link = '\124cff0070dd\124Hitem:22101::::::::60:::::\124h[Pauldrons of The Five Thunders]\124h\124r',
            name = 'Pauldrons of The Five Thunders',
            quality = 3,
        }))

        assert.is.equal(#GimmeTheLoot:SearchRecords(), 2)
        assert.is.equal(#GimmeTheLoot:SearchRecords(nil), 2)
        assert.is.equal(#GimmeTheLoot:SearchRecords({}), 2)

        assert.is.equal(#GimmeTheLoot:SearchRecords({quality = {[4] = true}}), 1)
        assert.is.equal(#GimmeTheLoot:SearchRecords({quality = {[3] = true}}), 1)
        assert.are_not.same(GimmeTheLoot:SearchRecords({quality = {[4] = true}}),
                            GimmeTheLoot:SearchRecords({quality = {[3] = true}}))

        assert.is.equal(#GimmeTheLoot:SearchRecords({text = 'r'}), 2)

        assert.is.equal(#GimmeTheLoot:SearchRecords({text = 'cyclone', quality = {[4] = true}}), 1)

        assert.is.equal(#GimmeTheLoot:SearchRecords({text = 'cyclone', quality = {[3] = true}}), 0)
    end)
end)
