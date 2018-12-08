local log = require("log")
local replica_uuid = os.getenv("REPLICA_UUID")

local config = require("dict.config")
local dict_storage_cfg = config["dict.storage"]

dict_storage_cfg.listen = 3301

vshard = require("vshard")
vshard.storage.cfg(config["dict.storage"], replica_uuid)

box.once("create dictinary schema", function() 
    local dictionary = box.schema.space.create("dictionary")

    dictionary:format({
        { name = "bucket_id", type = "unsigned" },
        { name = "id", type = "unsigned" },
        { name = "name", type = "string" },
        { name = "value", type = "string" }
    })

    dictionary:create_index("id", { type = "hash", parts = { "id" }})
    dictionary:create_index("name", { type = "hash", parts = { "name" }})
    dictionary:create_index("bucket_id", { type = "tree",  parts = { "bucket_id" }, unique = false })

    box.schema.func.create('storage_dictionary_insert')
    box.schema.role.grant('public', 'execute', 'function', 'storage_dictionary_insert')

    box.schema.func.create('storage_dictionary_find')
    box.schema.role.grant('public', 'execute', 'function', 'storage_dictionary_find')
end)

local function storage_dictionary_insert(val)
    local t, err = box.space.dictionary:frommap(val)
    return box.space.dictionary:insert(t)
end

local function storage_dictionary_find(name)
    local val = box.space.dictionary.index.name:get(name)
    if val ~= nil then
        return val:tomap({ names_only = true })
    end

    return nil
end

rawset(_G, 'storage_dictionary_insert', storage_dictionary_insert)
rawset(_G, 'storage_dictionary_find', storage_dictionary_find)
