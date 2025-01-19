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

function M.has_dependencies()
    if not vim.fn.executable 'gh' then
        vim.schedule(function()
            vim.notify('gh is not installed. Please install it to use this plugin.', vim.log.levels.ERROR, { title = 'Missing Dependency' })
        end)
        return false
    end
    return true
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

-- Function to get text results only for custom interface
function M.get_notifications_text()
    fetch.fetch_notifications(function(notifications)
        process.process_notifications(notifications, function(processed_notifications)
            display.display_notifications_text(processed_notifications)
        end)
    end)
end

-- Expose commands to Neovim
vim.api.nvim_create_user_command('GHNotificationsDisplay', function()
    if M.has_dependencies() then
        M.get_notifications()
    end
end, {})

vim.api.nvim_create_user_command('GHNotifications', function()
    if M.has_dependencies() then
        M.toast_notifications()
    end
end, {})

vim.api.nvim_create_user_command('GHNotificationsText', function()
    if M.has_dependencies() then
        M.get_notifications_text()
    end
end, {})

return M
