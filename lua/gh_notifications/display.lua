local notify = require 'gh_notifications.notify'

local M = {}

local notify_no_notifications = function()
    notify.sent_notification('No notifications to display 🎉', nil, 'GitHub Notifications')
end

-- Function to create a floating window and display notifications
---@param notifications GHNotification[] | nil: List of notifications to display
function M.display_notifications(notifications)
    if notifications == nil or #notifications == 0 then
        notify_no_notifications()
        return
    end

    -- Sort notifications by last_read_at descending
    table.sort(notifications, function(a, b)
        return a.last_read_at > b.last_read_at
    end)

    -- Prepare the display content
    local lines = {}
    for _, notification in ipairs(notifications) do
        table.insert(lines, string.format('- [%s] %s (%s)', notification.repository, notification.title, notification.pr_url))
    end

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Calculate window dimensions
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2 - 1)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Define window options
    local opts = {
        style = 'minimal',
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        border = 'rounded',
    }

    -- Create the floating window
    vim.api.nvim_open_win(buf, true, opts)

    -- Keybindings to close the window
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
end

---@param notifications GHNotification[] | nil: List of notifications to notify
function M.notify_notifications(notifications)
    if notifications == nil or #notifications == 0 then
        notify_no_notifications()
        return
    end

    for _, notification in ipairs(notifications) do
        notify.send_notification(notification.title, notification.reason, notification.pr_url, notification.pr_url)
    end
end

return M
