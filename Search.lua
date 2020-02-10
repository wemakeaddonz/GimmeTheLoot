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

function Search:SearchIterator(search, pageSize)
    local search = search or {}
    local pageSize = pageSize or 30
    local offset = 0

    return function()
        local currentPage = {}

        for i = offset + 1, #GimmeTheLoot.db.profile.records do
            offset = i
            local record = GimmeTheLoot.db.profile.records[i]
            if self:SearchMatchItemText(search.text, record) and
                self:SearchMatchItemQuality(search.quality, record) then
                currentPage[#currentPage + 1] = record

                if #currentPage == pageSize then
                    break
                end
            end
        end

        if #currentPage > 0 then
            return currentPage
        else
            return nil
        end
    end
end
