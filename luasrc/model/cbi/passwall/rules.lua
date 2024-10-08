local fs = require("nixio.fs")
local rulesDir = "/usr/local/etc/passwall/rules"

-- 获取规则文件列表
local function getRuleFiles()
    local files = {}
    for file in fs.dir(rulesDir) do
        if file:match("%.json$") or file:match("%.txt$") then
            table.insert(files, file)
        end
    end

    -- 排序函数：先按长度排序，如果长度相同，按第一个字符排序
    table.sort(files, function(a, b)
        if #a == #b then
            return a:sub(1, 1) < b:sub(1, 1)  -- 长度相同时，按第一个字符排序
        else
            return #a < #b  -- 按长度从短到长排序
        end
    end)

    return files
end

local description = [[
domain：匹配完整域名<br>
domain_suffix：匹配域名后缀<br>
domain_keyword：匹配域名关键字<br>
ip_cidr：匹配 IP CIDR<br>
详见：<a href="https://sing-box.sagernet.org/zh/configuration/route/rule/" target="_blank">https://sing-box.sagernet.org/zh/configuration/route/rule/</a>
]]

m = Map("passwall", translate(""), translate(description))
local ruleFiles = getRuleFiles()
if #ruleFiles == 0 then
    local tpl = require("luci.template")
    tpl.render_string([[<script type="text/javascript">
        alert('未找到有效的规则文件');
        window.location.href = ']] .. luci.dispatcher.build_url("admin", "services", "passwall") .. [[';
    </script>]])
else
    local s = m:section(TypedSection, "passwall")
    
    -- 为每个文件生成一个 Tab 选项
    for _, file in ipairs(ruleFiles) do
        local filePath = rulesDir .. "/" .. file
        local fileName = file:gsub("%.%w+$", "")
        -- 创建 Tab
        s:tab(fileName, translate(fileName))
        -- 创建 configTemplate 选项
        local configTemplate = s:taboption(fileName, Value, fileName)
        configTemplate.template = "cbi/tvalue"
        configTemplate.rows = 20
        -- 设置文件路径
        configTemplate.filePath = filePath
        -- 读取文件内容
        function configTemplate.cfgvalue(self, section)
            return fs.readfile(self.filePath) or ""
        end
        -- 保存修改后的内容
        function configTemplate.write(self, section, value)
            if self.option == fileName then
                fs.writefile(self.filePath, value)
            end
        end
    end
end

return m
