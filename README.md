# GitHub Notifications for Neovim

View your GitHub notifications in NeoVim, with sensible defaults, and the ability to filter for just the types of notifications you want to see.

<img width="1280" alt="gh-notifications" src="https://github.com/user-attachments/assets/3ff5a317-ddb6-44eb-aed9-334e66506953" />

By default, this tries to narrow down notifications to just what I, personally, like to see, filtering out the vast majority.  It also doesn't give full insights into what is contained in each notification, limiting to just the type, title, and URL.  If this isn't for you, there are good alternatives with much better options listed at the bottom.

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
  pull_request_filter = {
    enabled = true,
    states = {
      'open',
    },
  },
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

### Extra: Snacks Dashboard Config

See [snacks.nvim](https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md#github) for full config.

```lua
{
  title = 'Notifications',
  cmd = "nvim --headless -c ':GHNotificationsText' -c 'sleep 20000m' -c 'qa!'",
  action = function()
    vim.ui.open 'https://github.com/notifications'
  end,
  key = 'n',
  icon = ' ',
  height = 8,
  enabled = true,
}
```

## Usage

```shell
# view notifications using the vim.notify api
:GHNotifications

# view notifications in a windowed buffer
:GHNotificationsDisplay

# print out notifications as text
# for use in custom context such as your dashboard
:GHNotificationsText
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

## Similar Plugins

- [gh.nvim](https://github.com/ldelossa/gh.nvim) - truly impressive, fully featured, and excellent.
- [github-notifications.nvim](https://github.com/rlch/github-notifications.nvim) - simple, with more detail and interactivity!

