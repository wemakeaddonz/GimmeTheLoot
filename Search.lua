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

function Search:SearchMatchItemType(itemType, record)
    return not itemType or itemType == -1 or itemType == record.item.type
end

function Search:SearchMatchItemSubType(itemSubType, record)
    return not itemSubType or itemSubType == -1 or itemSubType == record.item.subtype
end

function Search:SearchRecords(search, limit, offset)
    local results = {}
    offset = offset or 0
    search = search or {}

    for _, record in ipairs(GimmeTheLoot.db.profile.records) do
        if self:SearchMatchItemText(search.text, record) and
            self:SearchMatchItemQuality(search.quality, record) and 
            self:SearchMatchItemType(search.type, record) and 
            self:SearchMatchItemSubType(search.subtype, record) then
            if offset ~= 0 then
                offset = offset - 1
            else
                table.insert(results, record)

                if limit and #results == limit then
                    break
                end
            end
        end
    end

    return results
end
