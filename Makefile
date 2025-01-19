.PHONY: test generate_filetypes lint luarocks_upload test_luarocks_install
test:
	LUA_INIT="@tests/setup.lua" luarocks test gh-notifications-scm-1.rockspec tests --test-type=busted

.PHONY: lint
lint:
	luacheck lua/gh_notifications
