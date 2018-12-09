local expirationd = require("expirationd")
local log = require("log")

local function is_expired(args, tuple)
    local t = tuple:tomap({names_only = true})
    return (os.time() - t.created) > 10
end

local function delete(space_id, args, tuple)
    local t = tuple:tomap({names_only=true})
    box.space[space_id]:delete(t.name)

    log.verbose("expirationd: collecting tuple %s from space %s", t.name, box.space[space_id].name)
end

local function init(space_id)
    expirationd.start('expire_dict_cache', space_id, is_expired, {
	process_expired_tuple = delete,
	args = nil,
	tuples_per_iteration = 50,
	full_scan_time = 3600
    }) 
end

return {
    init = init
}