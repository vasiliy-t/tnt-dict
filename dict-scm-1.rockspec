package = "dict"
version = "scm-1"

description = {
    summary = "clustered dictionary storage",
    homepage = "https://github.com/vasiliy-t/tarantool.git"
}

dependencies = {
    'http == 1.0.5',
    'lua >= 5.1',
    'lua-term == 0.7',
    'checks == 2.1.1',
    'vshard == 0.1.7',
    'icu-date == 1.2.1'
}

source = {
    url = "git@github.com/vasiliy-t/tarantool.git"
}

build = {
    type = "none",
}
