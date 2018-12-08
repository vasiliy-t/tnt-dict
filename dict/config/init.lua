local config = {
    ["dict.storage"] = {
        memtx_memory = 100 * 1024 * 1024,
        sharding = {
            ["1437b89c-d73f-4612-be07-e59b566f09f1"] = {
                replicas = {
                    ["b713e340-6df3-44c7-b55b-dbc9413c46f2"] = {
                        name = "storage_1",
                        uri = "storage:storage@storage_1:3301",
                        master = true
                    }
                }
            },
            ["40ae3b60-471c-4784-a0c8-43d1f3743d8d"] = {
                replicas = {
                    ["0e44fbf7-ebf9-45e0-9672-aeaaf09c508e"] = {
                        name = "storage_2",
                        uri = "storage:storage@storage_2:3301",
                        master = true
                    }
                }
            }

        }
    }
}

return config
