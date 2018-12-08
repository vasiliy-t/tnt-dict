FROM tarantool/tarantool

RUN apk add --update alpine-sdk cmake

WORKDIR /opt/tarantool

COPY dict-scm-1.rockspec .
RUN tarantoolctl rocks make

RUN mkdir data

COPY . .

CMD ["tarantool", "dict/storage/init.lua"]
