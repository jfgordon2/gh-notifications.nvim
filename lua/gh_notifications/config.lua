local M = {}

---@class GHNotificationsConfig
---@field unread_only boolean: Fetch only unread notifications
---@field notification_reasons string[]: List of notification reasons to fetch
M.options = {
    unread_only = false,
    pull_request_filter = {
        enabled = true,
        states = {
            'open',
            --'closed',
        },
    },
    notification_reasons = {
        'assign',
        'author',
        'comment',
        'manual',
        'mention',
        'review_requested',
        'security_alert',
        'subscribed',
        'team_mention',
        -- See: https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28
        -- for a full list of notification reasons
    },
}

---@param user_opts? GHNotificationsConfig
function M.setup(user_opts)
    M.options = vim.tbl_deep_extend('force', M.options, user_opts or {})
end

return M
