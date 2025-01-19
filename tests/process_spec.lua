---@diagnostic disable: undefined-global

local process = require 'gh_notifications.process'

describe('PR Status Function', function()
    it("should return 'open' for an open PR", function()
        -- Mock function to simulate 'gh api' response
        local original_exec = process.get_pr_status
        process.get_pr_status = function(url, callback)
            callback 'open'
        end

        local status
        process.get_pr_status('https://api.github.com/repos/owner/repo/pulls/1', function(result)
            status = result
        end)

        assert.are.equal('open', status)

        -- Restore original function
        process.get_pr_status = original_exec
    end)

    it("should return 'closed' for a closed PR", function()
        local original_exec = process.get_pr_status
        process.get_pr_status = function(url, callback)
            callback 'closed'
        end

        local status
        process.get_pr_status('https://api.github.com/repos/owner/repo/pulls/2', function(result)
            status = result
        end)

        assert.are.equal('closed', status)

        process.get_pr_status = original_exec
    end)
end)
