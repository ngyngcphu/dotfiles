local jdtls = require('jdtls')
local jdtls_setup = require('jdtls.setup')

local root_dir = jdtls_setup.find_root({ 'pom.xml', 'mvnw', 'gradlew', '.git' })
if not root_dir then
  return
end

local redisson_repo_root = '/Users/lap60627/Documents/redis-platform/redisson'
local is_redisson_repo = root_dir == redisson_repo_root
  or root_dir == redisson_repo_root .. '/redisson'

local project_name = vim.fs.basename(root_dir)
local workspace_key = root_dir .. (is_redisson_repo and ':unit-test-v2' or '')
local workspace_suffix = vim.fn.sha256(workspace_key):sub(1, 8)
local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls_workspace/' .. project_name .. '-' .. workspace_suffix

local java_home = nil
if vim.uv.fs_stat('/opt/homebrew/opt/openjdk@25') then
  java_home = '/opt/homebrew/opt/openjdk@25'
elseif vim.uv.fs_stat('/opt/homebrew/opt/openjdk') then
  java_home = '/opt/homebrew/opt/openjdk'
end

local function client_uses_workspace(client)
  local cmd = client.config and client.config.cmd or {}
  for i = 1, #cmd - 1 do
    if cmd[i] == '-data' and cmd[i + 1] == workspace_dir then
      return true
    end
  end
  return false
end

pcall(vim.lsp.enable, 'jdtls', false)

for _, client in ipairs(vim.lsp.get_clients({ name = 'jdtls' })) do
  if client.config.root_dir == root_dir and not client_uses_workspace(client) then
    client:stop(true)
  end
end

jdtls.start_or_attach({
  cmd = {
    'jdtls',
    '-data', workspace_dir,
  },
  cmd_env = java_home and {
    JAVA_HOME = java_home,
  } or nil,
  init_options = {
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
  },
  on_attach = function(_, bufnr)
    vim.keymap.set('n', '<leader>rs', '<cmd>JdtRestart<CR>', {
      buffer = bufnr,
      silent = true,
      desc = 'Restart JDTLS',
    })
  end,
  root_dir = root_dir,
}, nil, {
  reuse_client = function(client)
    return client.name == 'jdtls'
      and client.config.root_dir == root_dir
      and client_uses_workspace(client)
  end,
})
