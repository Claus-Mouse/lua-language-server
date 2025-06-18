local fs  = require 'bee.filesystem'
local fsu = require 'fs-utility'

local thirdPath = fs.path 'meta/3rd'

for dir in fs.pairs(thirdPath) do
    local libraryPath = dir / 'library'
    if fs.is_directory(libraryPath) then
        fsu.scanDirectory(libraryPath, function (fullPath)
            if fullPath:stem():string():find '%.'
            then
                local newPath = fullPath:parent_path() / (fullPath:stem():string():gsub('%.', '/') .. '.lua')
                local ok, err = pcall(fs.create_directories, newPath:parent_path())
                if not ok then
                    log.error("Failed to create directory:", newPath:parent_path():string(), err)
                    return
                end
                fs.rename(fullPath, newPath)
            end
        end)
    end
end
