local log = require("log")
local json = require("json")
local expirationd = require("expirationd")

local vshard = require("vshard")
local config = require("dict.config")
local dict_storage_cfg = config["dict.storage"]

dict_storage_cfg.log_level = 6

vshard.router.cfg(dict_storage_cfg)
vshard.router.bootstrap()

box.once('create dict cache space', function() 
    local dict_cache = box.schema.space.create('dict_cache', { is_local = true, temporary = true })
    dict_cache:format({
        { name = 'bucket_id', type = 'unsigned' },
        { name = 'id', type = 'unsigned' },
        { name = 'name', type = 'string' },
        { name = 'value', type = 'string' },
        { name = 'created', type = 'unsigned' }
    })
    dict_cache:create_index("primary", { type = "hash", parts = { "name" }})
end)

local function is_expired(args, tuple)
    local t = tuple:tomap({names_only = true})
    return (os.time() - t.created) > 10
end

local function delete(space_id, args, tuple)
    local t = tuple:tomap({names_only=true})
    log.verbose("expirationd: collecting tuple %s from space %s", t.name, box.space[space_id].name)
    box.space[space_id]:delete(t.name)
end

expirationd.start('expire_dict_cache', box.space.dict_cache.id, is_expired, {
    process_expired_tuple = delete,
    args = nil,
    tuples_per_iteration = 50,
    full_scan_time = 3600
})

local function load_record(name)
    local val = box.space.dict_cache:get(name)
    if val ~= nil then
        log.verbose("cache hit")
        return val:tomap({ names_only = true })
    end

    local val, err = vshard.router.call(vshard.router.bucket_id(name), 'read', 'storage_dictionary_find', {name})
    if val == nil or err ~= nil then
        return nil, ("load_record: failed to get record %s, err %s"):format(name, json.encode(err))
    end
    
    if val ~= nil then
        log.verbose("cache miss")

        val.created = os.time()
        box.space.dict_cache:replace(box.space.dict_cache:frommap(val))

	return val
    end

    return nil, "unexpected behaviour"
end

local function get_dictionary_record_handler(ctx)
    local record_name = ctx:stash("record_name")
    local value, err = load_record(record_name)
    if err ~= nil then
        log.error("get_dictionary_record_handler: record by name %s not found, value %s, err %s", record_name, json.encode(value), json.encode(err))
        return {
            status = 404,
            body = 'not found'
        }
    end

    return ctx:render({ json = value })
end

local httpd = require("http.server").new("0.0.0.0", 9000, {})
httpd:route({ path = "/dictionary/:record_name", method = "GET" }, get_dictionary_record_handler)
httpd:start()
