local mq = require('mq')

local helpers = {}

function helpers.query(peer, query, timeout)
    mq.cmdf('/dquery %s -q "%s"', peer, query)
    if timeout > 0 then
        mq.delay(25)
        mq.delay(timeout or 1000, function() return mq.TLO.DanNet(peer).Q(query).Received() > 0 end)
    end
    local value = mq.TLO.DanNet(peer).Q(query)()
    RGMercsLogger.log_verbose('\ayQuerying - mq.TLO.DanNet(%s).Q(%s) = %s', peer, query, value)
    return value
end

function helpers.observe(peer, query, timeout)
    if not mq.TLO.DanNet(peer).OSet(query)() then
        mq.cmdf('/dobserve %s -q "%s"', peer, query)
        RGMercsLogger.log_verbose('\ayAdding Observer - mq.TLO.DanNet(%s).O(%s)', peer, query)
    end
    ---@diagnostic disable-next-line: undefined-field
    mq.delay(timeout or 1000, function() return mq.TLO.DanNet(peer).O(query).Received() > 0 end)
    local value = mq.TLO.DanNet(peer).O(query)()
    RGMercsLogger.log_verbose('\ayObserving - mq.TLO.DanNet(%s).O(%s) = %s', peer, query, value)
    return value
end

function helpers.unobserve(peer, query)
    mq.cmdf('/dobserve %s -q "%s" -drop', peer, query)
    RGMercsLogger.log_verbose('\ayRemoving Observer - mq.TLO.DanNet(%s).O(%s) = %s', peer, query, mq.TLO.DanNet(peer).O(query)())
end

return helpers
