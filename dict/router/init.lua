local log = require("log")
local json = require("json")

local vshard = require("vshard")
local config = require("dict.config")

vshard.router.cfg(config["dict.storage"])
vshard.router.bootstrap()

local function get_dictionary_record_handler(ctx)
    local record_name = ctx:stash("record_name")
    local value, err = vshard.router.call(vshard.router.bucket_id(record_name), 'read', 'storage_dictionary_find', {record_name})

    if value == nil or err ~= nil then
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
