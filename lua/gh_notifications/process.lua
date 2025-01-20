local notify = require 'gh_notifications.notify'
local fetch = require 'gh_notifications.fetch'
local config = require 'gh_notifications.config'

local M = {}

-- Function to get PR status using gh CLI
---@param url string: URL of the PR
---@param callback function: Callback function to process the PR status
---@return string | nil: PR status
local function get_pr_status(url, callback)
    if url == nil or url:match '/pull' == nil then
        callback 'N/A'
        return
    end
    local cmd = {
        'gh',
        'api',
        string.format('%s', url),
        '--jq',
        '.state',
    }
    local transform = function(result)
        if result == nil then
            callback 'N/A'
            return
        end
        result = result:gsub('"', ''):gsub('\n', '')
        if result == '' then
            callback 'N/A'
        else
            callback(result)
        end
    end
    fetch.exec_cmd(cmd, transform)
end

function M.apply_pr_filter(notifications, callback)
    local filtered_notifications = {}
    local total = #notifications
    -- Function to handle each notification
    local function handle_notification(index)
        if index > total then
            callback(filtered_notifications)
            return
        end
        local notification = notifications[index]
        if config.options.pull_request_filter.enabled then
            if string.match(notification.url, '/pulls/') then
                get_pr_status(notification.url, function(status)
                    if vim.tbl_contains(config.options.pull_request_filter.states, status) then
                        table.insert(filtered_notifications, notification)
                    end
                    handle_notification(index + 1)
                end)
            else
                handle_notification(index + 1)
            end
        else
            table.insert(filtered_notifications, notification)
            handle_notification(index + 1)
        end
    end
    handle_notification(1)
end

function M.apply_unread_only_filter(notifications, callback)
    local filtered_notifications = {}
    local total = #notifications
    -- Function to handle each notification
    local function handle_notification(index)
        if index > total then
            callback(filtered_notifications)
            return
        end
        local notification = notifications[index]
        if config.options.unread_only and notification.last_read_at ~= 'null' then
            -- Skip read notifications if unread_only is true
        else
            table.insert(filtered_notifications, notification)
        end
        handle_notification(index + 1)
    end
    handle_notification(1)
end

-- Process notifications and return relevant notifications
---@param notifications table: List of notifications to process
---@param display_callback function: Callback function to display notifications
function M.process_notifications(notifications, display_callback)
    -- Apply Unread Only filter
    M.apply_unread_only_filter(notifications, function(filtered_notifications)
        -- Apply PR filter
        M.apply_pr_filter(filtered_notifications, function(pr_filtered_notifications)
            -- Display notifications
            display_callback(pr_filtered_notifications)
        end)
    end)
end

return M
