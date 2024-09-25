include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Passwall
LUCI_PKGARCH:=all
LUCI_DEPENDS:=

PKG_NAME:=luci-app-passwall
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  PKGARCH:=$(LUCI_PKGARCH)
  DEPENDS:=$(LUCI_DEPENDS)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/passwall $(1)/etc/config/passwall

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/passwall $(1)/etc/init.d/passwall

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
