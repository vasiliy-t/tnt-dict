local log = require("log")
local replica_uuid = os.getenv("REPLICA_UUID")

local config = require("dict.config")
local dict_storage_cfg = config["dict.storage"]

dict_storage_cfg.listen = 3301

vshard = require("vshard")
vshard.storage.cfg(config["dict.storage"], replica_uuid)

