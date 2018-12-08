FROM tarantool/tarantool

WORKDIR /opt/tarantool

RUN mkdir data

COPY ./ ./

CMD ["tarantool", "dict/storage/init.lua"]
