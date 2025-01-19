local M = {}

-- Send a notification with (hopefully) some useful extra options
-- depending on what plugin is installed and how it's configured
---@param title string: Notification title
---@param subtitle? string: Notification subtitle
---@param message string: Notification message
---@param url? string: URL to open on notification click (if supported)
function M.send_notification(title, subtitle, message, url)
    if subtitle ~= nil then
        message = subtitle .. '\n' .. message
    end
    if message ~= nil then
        vim.schedule(function()
            vim.notify(message, vim.log.levels.INFO, { title = title, url = url })
        end)
    end
end

---@param title string: Notification title (if supported)
---@param message string: Error message to display
function M.send_error(title, message)
    if message == nil then
        message = 'Unknown GHNotification Error'
        title = 'Error'
    end
    vim.schedule(function()
        vim.notify(message, vim.log.levels.ERROR, { title = title })
    end)
end

return M
