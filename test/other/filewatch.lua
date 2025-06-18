local thread = require 'bee.thread'
local fw     = require 'filewatch'
local fs     = require 'bee.filesystem'
local fsu    = require 'fs-utility'

local path = fs.path(LOGPATH) / 'fw'

local ok, err = pcall(fs.create_directories, path)
if not ok then
    io.stderr:write(string.format("Failed to create test directory %s: %s\n", path:string(), err))
    return
end

os.remove((path / 'test.txt'):string())

local _ <close> = fw.watch(path:string(), true)
fsu.saveFile(path / 'test.txt', 'test')

local events
fw.event(function (ev, filename)
    events[#events+1] = {ev, filename}
end)

thread.sleep(1000)
events = {}
fw.update()
assert(#events == 1)
assert(events[1][1] == 'create')

fsu.saveFile(path / 'test.txt', 'modify')

thread.sleep(1000)
events = {}
fw.update()
assert(#events == 1)
assert(events[1][1] == 'change')

local f <close> = io.open((path / 'test.txt'):string(), 'w')
assert(f)
f:write('xxx')
f:flush()
f:close()

thread.sleep(1000)
events = {}
fw.update()
assert(#events == 1)
assert(events[1][1] == 'change')
