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
        string.format('"%s"', url),
        '--jq',
        '.state',
    }
    local transform = function(result)
        result = result:gsub('"', ''):gsub('\n', '')
        if result == '' then
            callback 'N/A'
        else
            callback(result)
        end
    end
    fetch.async_exec_cmd(cmd, transform)
end

-- Process notifications and return relevant notifications
---@param notifications table: List of notifications to process
---@param display_callback function: Callback function to display notifications
function M.process_notifications(notifications, display_callback)
    local open_prs = {}
    local total = #notifications

    -- Function to handle each notification
    local function handle_notification(index)
        if index > total then
            display_callback(open_prs)
            return
        end

        local notification = notifications[index]
        get_pr_status(notification.url, function(status)
            if status == 'open' then
                if config.options.unread_only and notification.last_read_at ~= 'null' then
                -- Skip read notifications if unread_only is true
                else
                    table.insert(open_prs, notification)
                end
            end
            handle_notification(index + 1)
        end)
    end

    handle_notification(1)
end

return M
