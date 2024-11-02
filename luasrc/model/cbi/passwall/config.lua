local fs = require "nixio.fs"
local uci = require("luci.model.uci").cursor()  -- 用于操作 UCI 配置
local Map, TypedSection, Value = require("luci.cbi").Map, require("luci.cbi").TypedSection, require("luci.cbi").Value

m = Map("passwall", "Passwall配置")
s = m:section(TypedSection, "passwall", "配置")
s.anonymous = true

local filePath = "/usr/local/etc/passwall/config.json"
local dirPath = "/usr/local/etc/passwall"

-- 检查文件和目录是否存在
if not fs.stat(dirPath) then
    fs.mkdirr(dirPath)  -- 创建目录
end

if not fs.stat(filePath) then
    fs.writefile(filePath, "")  -- 创建空白文件
end

-- 配置模板
configTemplate = s:option(Value, "configTemplate")
configTemplate.template = "cbi/tvalue"
configTemplate.rows = 20

-- 读取配置文件内容
function configTemplate.cfgvalue(self, section)
    return fs.readfile(filePath) or ""
end

-- 写入配置文件内容
function configTemplate.write(self, section, value)
    value = value:gsub("\r\n?", "\n")
    fs.writefile(filePath, value)
end

return m
