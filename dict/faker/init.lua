local log = require("log")
local json = require("json")
local math = require("math")
local uuid = require("uuid")

local vshard = require("vshard")
local config = require("dict.config")

local function generate()
    for i = 1, 1000 * 1000, 1 do
        local name = uuid.str()
        local record = {
            bucket_id = vshard.router.bucket_id(name),
            id = math.random(1, 1000000000),
            name = name,
            value = uuid.str(),
        }

        local res, err = vshard.router.call(record.bucket_id, 'write', 'storage_dictionary_insert', {record})
        if err ~= nil then
            log.error("dict.faker: failed to store record %s, err %s", json.encode(record), json.encode(err))
        end
    end
end

return {
    generate = generate
}
