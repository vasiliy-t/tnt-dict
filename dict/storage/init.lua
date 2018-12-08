local vshard = require("vshard")
local config = require("dict.config")
local log = require("log")
local replica_uuid = os.getenv("REPLICA_UUID")

log.info(replica_uuid)

vshard.storage.cfg(config["dict.storage"], replica_uuid)

