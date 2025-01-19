rockspec_format = '3.0'
package = 'gh-notifications'
version = 'scm-1'
source = {
    url = 'git+https://github.com/jfgordon2/gh-notifications.nvim',
}
dependencies = {
    -- Add runtime dependencies here
    -- e.g. "plenary.nvim",
}
test = {
    type = 'busted',
}
test_dependencies = {
    'nlua',
}
build = {
    type = 'builtin',
    copy_directories = {
        -- Add runtimepath directories, like
        -- 'plugin', 'ftplugin', 'doc'
        -- here. DO NOT add 'lua' or 'lib'.
    },
}
