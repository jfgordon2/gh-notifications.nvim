local vim = vim
local uv = vim.uv
local config = require 'gh_notifications.config'
local notify = require 'gh_notifications.notify'

local M = {}

---@class GHNotification
---@field last_read_at string | nil: datetime string object was last read
---@field pr_url string: URL to the PR
---@field reason string: Reason for the notification
---@field repository string: URL to the repository
---@field title string: Title of the notification
---@field unread boolean: Whether the notification is unread
---@field url string: GH API URL of the notification

-- Execute a shell command and return its output
---@param cmd string[]: Command to execute
---@param callback function: Callback function to process the output
function M.exec_cmd(cmd, callback)
    local on_exit = function(obj)
        if obj.code == 0 then
            return callback(obj.stdout)
        else
            notify.send_error('ERROR', string.format('Failed to execute command: %s', obj.stderr))
            return callback(nil)
        end
    end
    vim.system(cmd, { text = true }, on_exit)
end

-- Fetch notifications using gh CLI
---@param callback function: Callback function to process the notifications
function M.fetch_notifications(callback)
    local reasons = config.options.notification_reasons
    local reasons_filter = table.concat(
        vim.tbl_map(function(reason)
            return string.format('.reason == "%s"', reason)
        end, reasons),
        ' or '
    )

    local cmd = {
        'gh',
        'api',
        'notifications?all=true',
        '--jq',
        string.format(
            '.[] | select(%s) | {repository: .repository.html_url, title: .subject.title, reason: .reason, last_read_at: .last_read_at, unread: .unread, url: .subject.url}',
            reasons_filter
        ),
    }

    M.exec_cmd(cmd, function(output)
        ---@type GHNotification[] | nil
        if output == nil then
            return callback(nil)
        end
        local split_output = vim.split(output, '\n')
        local notifications = {}
        for _, line in ipairs(split_output) do
            if line ~= '' then
                local notification = vim.json.decode(line)
                notification.pr_url = notification.url:gsub('api.github.com/repos', 'github.com'):gsub('/pulls/', '/pull/')
                table.insert(notifications, notification)
            end
        end
        callback(notifications)
    end)
end

return M
