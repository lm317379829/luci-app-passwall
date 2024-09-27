include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Passwall
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+jq

PKG_NAME:=luci-app-passwall
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/passwall $(1)/etc/config/passwall

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/passwall $(1)/etc/init.d/passwall

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
