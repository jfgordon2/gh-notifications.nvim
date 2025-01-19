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

-- Function to execute a shell command in a thread and capture its output
---@param cmd string[]: Command to execute
---@param callback function: Callback function to process the output
---@return string | nil: Output of the command, unless errored
function M.async_exec_cmd(cmd, callback)
    local str_cmd = table.concat(cmd, ' ')
    local work = uv.new_work(M.exec_cmd, callback)
    work:queue(str_cmd)
end

-- Execute a shell command and return its output
---@param cmd string: Command to execute
---@return string | nil: Output of the command, unless errored
function M.exec_cmd(cmd)
    local handle = io.popen(cmd)
    if handle == nil then
        notify.send_error('ERROR', 'Failed to open a handle to the command')
        return
    end
    local result = handle:read '*a'
    handle:close()
    return result
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
            '\'.[] | select(%s) | {repository: .repository.html_url, title: .subject.title, reason: .reason, last_read_at: .last_read_at, unread: .unread, url: .subject.url, pr_url: (.subject.url | sub("api.github.com/repos"; "github.com") | sub("/pulls/"; "/pull/"))}\'',
            reasons_filter
        ),
        '|',
        'jq',
        '-s',
    }

    M.async_exec_cmd(cmd, function(output)
        ---@type GHNotification[] | nil
        local notifications = vim.json.decode(output)
        callback(notifications)
    end)
end

return M
