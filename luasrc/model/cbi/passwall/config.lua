m = Map("passwall")
s = m:section(TypedSection, "passwall")
local fs = require "nixio.fs"
local filePath = "/usr/local/etc/passwall/config.json"
local dirPath = "/usr/local/etc/passwall"

-- 检查文件是否存在，如果目录不存在则创建目录，如果文件不存在则创建空文件
if not fs.stat(dirPath) then
    fs.mkdirr(dirPath)  -- 创建目录
end

if not fs.stat(filePath) then
    fs.writefile(filePath, "")  -- 创建空白文件
end

configTemplate = s:option(Value, "configTemplate")
configTemplate.template = "cbi/tvalue"
configTemplate.rows = 20

function configTemplate.cfgvalue(self, section)
    return fs.readfile(filePath)
end

function configTemplate.write(self, section, value)
    value = value:gsub("\r\n?", "\n")
    nixio.fs.writefile(filePath, value)
end

return m
