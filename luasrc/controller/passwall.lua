module("luci.controller.passwall", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/passwall") then
        return
    end

    entry({"admin", "services", "passwall"}, firstchild(), "翻墙控制", 10).dependent = false
    entry({"admin", "services", "passwall", "control"}, cbi("passwall/control"), "控制面板", 1).leaf = true
    entry({"admin", "services", "passwall", "config"}, cbi("passwall/config"), "编辑配置", 2).leaf = true
    entry({"admin", "services", "passwall", "rules"}, cbi("passwall/rules"), "编辑规则", 3).leaf = true
end
