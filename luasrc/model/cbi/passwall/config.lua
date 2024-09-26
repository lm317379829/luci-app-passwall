m = Map("passwall")
s = m:section(TypedSection, "passwall")
local fs = require "nixio.fs"
local filePath = "/usr/local/etc/passwall/config.json"

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
