local M = {}

-- Function to safely require telescope modules
local function safe_require()
  local ok_pickers, pickers = pcall(require, 'telescope.pickers')
  local ok_finders, finders = pcall(require, 'telescope.finders')
  local ok_make_entry, make_entry = pcall(require, 'telescope.make_entry')
  local ok_conf, conf = pcall(require, 'telescope.config')
  local ok_actions, actions = pcall(require, 'telescope.actions')
  local ok_action_state, action_state = pcall(require, 'telescope.actions.state')

  if not (ok_pickers and ok_finders and ok_make_entry and ok_conf and ok_actions and ok_action_state) then
    vim.notify('Telescope is not available. Please ensure it is installed and loaded.', vim.log.levels.ERROR)
    return nil
  end

  return {
    pickers = pickers,
    finders = finders,
    make_entry = make_entry,
    conf = conf.values,
    actions = actions,
    action_state = action_state,
  }
end

-- Function to get all git branches
local function get_git_branches()
  local handle = io.popen 'git branch -a --format="%(refname:short)"'
  if not handle then
    return {}
  end

  local branches = {}
  for line in handle:lines() do
    local branch = line:gsub('^%s*%*?%s*', '')
    if branch ~= '' and not branch:match 'HEAD' then
      table.insert(branches, branch)
    end
  end
  handle:close()

  -- Remove duplicates
  local unique_branches = {}
  local seen = {}
  for _, branch in ipairs(branches) do
    if not seen[branch] then
      seen[branch] = true
      table.insert(unique_branches, branch)
    end
  end

  return unique_branches
end

-- Function to get current branch
local function get_current_branch()
  local handle = io.popen 'git branch --show-current'
  if not handle then
    return 'main'
  end
  local current = handle:read('*a'):gsub('\n', '')
  handle:close()
  return current ~= '' and current or 'main'
end

-- Function to get diff files with status (similar to git status)
local function get_diff_files_with_status(base_branch, current_branch)
  local cmd = string.format('git diff --name-status %s..%s', base_branch, current_branch)
  local handle = io.popen(cmd)
  if not handle then
    return {}
  end

  local files = {}
  for line in handle:lines() do
    if line ~= '' then
      local status, file = line:match '^(%S+)%s+(.+)$'
      if status and file then
        table.insert(files, {
          status = status,
          file = file,
          display = string.format('%s  %s', status, file),
        })
      end
    end
  end
  handle:close()
  return files
end

-- Branch picker function
local function pick_branch(telescope_modules, callback)
  local branches = get_git_branches()
  local current_branch = get_current_branch()

  if #branches == 0 then
    vim.notify('No git branches found', vim.log.levels.ERROR)
    return
  end

  telescope_modules.pickers
    .new({}, {
      prompt_title = 'Select Branch to Compare',
      finder = telescope_modules.finders.new_table {
        results = branches,
        entry_maker = function(branch)
          local display = branch
          if branch == current_branch then
            display = branch .. ' (current)'
          end
          return {
            value = branch,
            display = display,
            ordinal = branch,
          }
        end,
      },
      sorter = telescope_modules.conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        telescope_modules.actions.select_default:replace(function()
          local selection = telescope_modules.action_state.get_selected_entry()
          telescope_modules.actions.close(prompt_bufnr)
          if selection then
            callback(selection.value)
          end
        end)
        return true
      end,
    })
    :find()
end

-- Show diff status like git_status
local function show_diff_status(telescope_modules, base_branch, opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local current_branch = get_current_branch()
  local diff_files = get_diff_files_with_status(base_branch, current_branch)

  if #diff_files == 0 then
    vim.notify(string.format('No differences found between %s and %s', base_branch, current_branch), vim.log.levels.INFO)
    return
  end

  telescope_modules.pickers
    .new(opts, {
      prompt_title = string.format('Diff Status: %s..%s (%d files)', base_branch, current_branch, #diff_files),
      finder = telescope_modules.finders.new_table {
        results = diff_files,
        entry_maker = function(entry)
          return {
            value = entry.file,
            display = entry.display,
            ordinal = entry.file,
            path = entry.file,
            status = entry.status,
          }
        end,
      },
      previewer = telescope_modules.conf.file_previewer(opts),
      sorter = telescope_modules.conf.file_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        -- Default action: open file
        telescope_modules.actions.select_default:replace(function()
          local selection = telescope_modules.action_state.get_selected_entry()
          telescope_modules.actions.close(prompt_bufnr)
          if selection then
            vim.cmd('edit ' .. selection.path)
          end
        end)

        -- Add action to grep within all diff files
        map('i', '<C-g>', function()
          local current_picker = telescope_modules.action_state.get_current_picker(prompt_bufnr)
          local all_files = {}

          -- Get all files from the current picker
          for entry in current_picker.manager:iter() do
            table.insert(all_files, entry.value)
          end

          telescope_modules.actions.close(prompt_bufnr)

          -- Open live_grep scoped to these files
          require('telescope.builtin').live_grep {
            search_dirs = all_files,
            prompt_title = string.format('Live Grep in Diff Files (%d files)', #all_files),
          }
        end)

        -- Add action to show git diff for selected file
        map('i', '<C-d>', function()
          local selection = telescope_modules.action_state.get_selected_entry()
          if selection then
            telescope_modules.actions.close(prompt_bufnr)
            local cmd = string.format('git diff %s..%s -- %s', base_branch, current_branch, selection.path)
            vim.cmd 'new'
            vim.cmd 'setlocal buftype=nofile bufhidden=wipe noswapfile'
            vim.fn.setline(1, vim.split(vim.fn.system(cmd), '\n'))
            vim.bo.filetype = 'diff'
          end
        end)

        -- Add action to open file in split
        map('i', '<C-s>', function()
          local selection = telescope_modules.action_state.get_selected_entry()
          telescope_modules.actions.close(prompt_bufnr)
          if selection then
            vim.cmd('split ' .. selection.path)
          end
        end)

        -- Add action to open file in vsplit
        map('i', '<C-v>', function()
          local selection = telescope_modules.action_state.get_selected_entry()
          telescope_modules.actions.close(prompt_bufnr)
          if selection then
            vim.cmd('vsplit ' .. selection.path)
          end
        end)

        return true
      end,
    })
    :find()
end

-- Main function
function M.diff_status(opts)
  local telescope_modules = safe_require()
  if not telescope_modules then
    return
  end

  pick_branch(telescope_modules, function(selected_branch)
    show_diff_status(telescope_modules, selected_branch, opts)
  end)
end

-- Convenience function that directly uses current branch vs main/master
function M.diff_status_main(opts)
  local telescope_modules = safe_require()
  if not telescope_modules then
    return
  end

  local current_branch = get_current_branch()
  local main_branch = 'main'

  -- Check if main branch exists, otherwise try master
  local handle = io.popen 'git rev-parse --verify main 2>/dev/null'
  if handle then
    local result = handle:read '*a'
    handle:close()
    if result == '' then
      main_branch = 'master'
    end
  end

  if current_branch == main_branch then
    vim.notify('Already on ' .. main_branch .. ' branch', vim.log.levels.INFO)
    return
  end

  show_diff_status(telescope_modules, main_branch, opts)
end

return M
