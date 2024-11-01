local fs = require "nixio.fs"
local Map, Section, Value = require("luci.model.uci").cursor(), Map, Value

m = Map("passwall", _("Passwall Configuration"))
s = m:section(TypedSection, "passwall", _("Configuration Settings"))
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
configTemplate = s:option(Value, "configTemplate", _("Configuration Template"))
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
