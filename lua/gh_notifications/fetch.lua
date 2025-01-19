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

-- Function to execute a shell command and capture its output
---@param cmd string[]: Command to execute
---@param callback function: Callback function to process the output
---@return string | nil: Output of the command, unless errored
local function exec_cmd(cmd, callback)
    local on_exit = function(obj)
        if obj.code ~= 0 then
            notify.send_error('ERROR', string.format('Error: %s', obj.stderr))
            return
        else
            callback(obj.stdout)
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
        '.[]',
        '|',
        string.format('select(%s)', reasons_filter),
        '|',
        '{repository: .repository.html_url, title: .subject.title, reason: .reason, last_read_at: .last_read_at, unread: .unread, url: .subject.url, pr_url: (.subject.url | sub("api.github.com/repos"; "github.com") | sub("/pulls/"; "/pull/"))}',
        '|',
        'jq',
        '-s',
    }

    exec_cmd(cmd, function(output)
        ---@type GHNotification[] | nil
        local notifications = vim.json.decode(output)
        callback(notifications)
    end)
end

return M
