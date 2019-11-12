require'strict'.on()

box.cfg({})

box.once('access:v1', function()
    box.schema.user.grant('guest', 'super')
end)

box.schema.create_space('queue', {
    format = {
        { name = 'id';     type = 'number' },
        { name = 'status'; type = 'string' },
        { name = 'data';   type = '*'      },
    };
    if_not_exists = true;
})

box.space.queue:create_index('primary', {
    parts = {1,'number'};
    if_not_exists = true;
})

box.space.queue:create_index('status', {
    parts = {2, 'string', 1, 'number'};
    if_not_exists = true;
})

STATUS = {}
STATUS.READY = 'R'
STATUS.TAKEN = 'T'

fiber = require 'fiber'
local wait = fiber.channel(0)

queue = {}

local clock = require 'clock'
local function gen_id()
    local new_id = clock.realtime64()/1e3
    while box.space.queue:get(new_id) do
        new_id = new_id + 1
    end
    return new_id
end

function queue.put(...)
    local id = gen_id()

    if wait:has_readers() then
        wait:put(true, 0)
    end

    return box.space.queue:insert{ id, STATUS.READY, ... }
end

local F = {
    id     = 1;
    status = 2;
    data   = 3;
}

function queue.take(timeout)
    if not timeout then timeout = 0 end
    local now = fiber.time()
    local found
    while not found do
        found = box.space.queue.index.status
            :pairs({STATUS.READY},{ iterator = box.index.EQ }):nth(1)
        if not found then
            local left = (now + timeout) - fiber.time()
            if left <= 0 then return end
            wait:get(left)
        end
    end
    return box.space.queue:update({found.id},
       {{'=', F.status, STATUS.TAKEN }})
end

function queue.ack(id)
    local t = assert(box.space.queue:get{id}, "Task not exists")
    if t and t.status == STATUS.TAKEN then
        return box.space.queue:delete{t.id}
    else
        error("Task not taken")
    end
end

function queue.release(id)
    local t = assert(box.space.queue:get{id}, "Task not exists")
    if t and t.status == STATUS.TAKEN then
        return box.space.queue:update({t.id}, {{'=', F.status, STATUS.READY }})
    else
        error("Task not taken")
    end
end

function queue.test()
    fiber.create(function()
        fiber.sleep(0.1)
        queue.put("task 1")
    end)
    local start = fiber.time()
    return queue.take(3), {wait = fiber.time() - start}
end
