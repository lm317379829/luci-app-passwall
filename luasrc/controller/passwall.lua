module("luci.controller.passwall", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/passwall") then
        return
    end

    -- 添加菜单项
    entry({"admin", "services", "passwall"}, firstchild(), _("翻墙控制"), 10).dependent = false
    entry({"admin", "services", "passwall", "control"}, cbi("passwall/control"), _("控制面板"), 1).leaf = true
    entry({"admin", "services", "passwall", "config"}, cbi("passwall/config"), _("编辑配置"), 2).leaf = true
    entry({"admin", "services", "passwall", "rules"}, cbi("passwall/rules"), _("编辑规则"), 3).leaf = true
end
