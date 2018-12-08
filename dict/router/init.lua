local log = require("log")
local vshard = require("vshard")
local config = require("dict.config")

vshard.router.cfg(config["dict.storage"])
vshard.router.bootstrap()
