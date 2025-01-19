# GitHub Notifications for Neovim

View your GitHub notifications in NeoVim, with sensible defaults, and the ability to filter 
for just the types of notifications you want to see.

## Installation

### lazy.nvim

```lua
return {
  'jfgordon2/gh-notifications.nvim',
  opts = {},
}
```

```lua
-- These are the default config settings
require('gh_notifications').setup({
  unread_only = true,
  notification_reasons = {
    "assign",
    "author",
    "comment",
    "manual",
    "mention",
    "review_requested",
    "security_alert",
    "subscribed",
    "team_mention",
  },
})
```

### Packer

```lua
-- in your init.lua or a separate plugins.lua
require('packer').startup(function()
  use {
    'jfgordon2/gh-notifications.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gh_notifications').setup({
        unread_only = true,
        notification_reasons = {
          "mention",
          "review_requested",
          "subscribed",
          "team_mention",
        },
      })
    end
  }
end)
```

## Usage

```shell
# view notifications using the vim.notify api
:GHNotifications

# view notifications in a windowed buffer
:GHNotificationsDisplay
```

### Configuration

**unread_only** (default: true) - only show unread notifications

**notification_reasons** - filter notifications by type
See [GitHub docs]( https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28) for full list of values.

Keybind

```lua
vim.api.nvim_set_keymap('n', '<leader>gn', '<cmd>GHNotifications<CR>', { noremap = true, silent = true, desc = "GitHub Notifications" })
```

## Testing

### Pre-requisites

Get [luarocks](https://luarocks.org/)

```shell
brew install luarocks
```

Install [nlua](https://github.com/mfussenegger/nlua)

```shell
luarocks --local install nlua
```

Then install [busted](https://lunarmodules.github.io/busted/)
and create a `~/.luarocks/config-nlua.lua` as described.

```shell
luarocks --local install busted
# add the below to your ~/.zshrc or similar
eval $(luarocks path --no-bin)
export PATH=$PATH:$HOME/.luarocks/bin:
```

### Running tests

```shell
make test
```
