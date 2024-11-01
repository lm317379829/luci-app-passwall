local fs = require("nixio.fs")
local tpl = require("luci.template")
local dispatcher = require("luci.dispatcher")

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
            return a < b  -- 长度相同时按字母排序
        else
            return #a < #b  -- 按长度从短到长排序
        end
    end)

    return files
end

-- 描述信息
local description = [[
domain：匹配完整域名<br>
domain_suffix：匹配域名后缀<br>
domain_keyword：匹配域名关键字<br>
ip_cidr：匹配 IP CIDR<br>
详见：<a href="https://sing-box.sagernet.org/zh/configuration/route/rule/" target="_blank">sing-box 规则配置</a>
]]

-- 创建 Map 对象
m = Map("passwall", translate("Passwall Rules Configuration"), translate(description))
local ruleFiles = getRuleFiles()

-- 如果没有找到规则文件，显示提示
if #ruleFiles == 0 then
    tpl.render_string([[
        <script type="text/javascript">
            alert('未找到有效的规则文件');
            window.location.href = ']] .. dispatcher.build_url("admin", "services", "passwall") .. [[';
        </script>
    ]])
else
    -- 创建一个 TypedSection
    local s = m:section(TypedSection, "passwall", translate("Rule Files"))
    s.anonymous = true

    -- 为每个规则文件生成一个 Tab 和编辑区域
    for _, file in ipairs(ruleFiles) do
        local filePath = rulesDir .. "/" .. file
        local fileName = file:gsub("%.%w+$", "")  -- 去除文件扩展名

        -- 创建 Tab
        s:tab(fileName, translate(fileName))

        -- 创建编辑区域
        local configTemplate = s:taboption(fileName, Value, fileName, translate("Edit ") .. fileName)
        configTemplate.template = "cbi/tvalue"
        configTemplate.rows = 20
        configTemplate.filePath = filePath

        -- 读取文件内容
        function configTemplate.cfgvalue(self, section)
            return fs.readfile(self.filePath) or ""
        end

        -- 保存编辑的内容
        function configTemplate.write(self, section, value)
            if self.option == fileName then
                fs.writefile(self.filePath, value)
            end
        end
    end
end

return m
