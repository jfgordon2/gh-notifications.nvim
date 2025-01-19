local config = require 'gh_notifications.config'
local fetch = require 'gh_notifications.fetch'
local process = require 'gh_notifications.process'
local display = require 'gh_notifications.display'

local M = {}

-- Setup function to be called by user
---@param user_opts? GHNotificationsConfig
function M.setup(user_opts)
    config.setup(user_opts)
end

-- Main function to get and display in a buffer
function M.get_notifications()
    fetch.fetch_notifications(function(notifications)
        process.process_notifications(notifications, function(processed_notifications)
            display.display_notifications(processed_notifications)
        end)
    end)
end

-- Function to display notifications using the notify api
function M.toast_notifications()
    fetch.fetch_notifications(function(notifications)
        process.process_notifications(notifications, function(processed_notifications)
            display.notify_notifications(processed_notifications)
        end)
    end)
end

-- Expose commands to Neovim
vim.api.nvim_create_user_command('GHNotificationsDisplay', function()
    M.get_notifications()
end, {})

vim.api.nvim_create_user_command('GHNotifications', function()
    M.toast_notifications()
end, {})

return M
