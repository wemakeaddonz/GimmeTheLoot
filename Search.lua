if not _TEST then
    Search = GimmeTheLoot:NewModule('Search')
end

function Search:SearchMatchItemText(text, record)
    return not text or text == '' or string.find(string.lower(record.item.name), string.lower(text))
end

-- consider memoizing
function Search:SearchMatchItemQuality(quality, record)
    return not quality or next(quality) == nil or quality[record.item.quality]
end

function Search:SearchRecords(search)
    local results = {}
    search = search or {}

    for _, record in pairs(GimmeTheLoot.db.profile.records) do
        if record.item.name and record.item.quality then
            if self:SearchMatchItemText(search.text, record) and
                self:SearchMatchItemQuality(search.quality, record) then
                table.insert(results, record)
            end
        end
    end

    return results
end
