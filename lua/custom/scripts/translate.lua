-- Simpler version using vim.notify
local function show_text_simple()
  local mode = vim.fn.mode()
  local text = ''

  if mode == 'v' or mode == 'V' or mode == '\22' then
    -- Get visual selection
    vim.cmd 'normal! "vy'
    text = vim.fn.getreg 'v'
  else
    -- Get word under cursor
    text = vim.fn.expand '<cword>'
  end

  if text and text ~= '' then
    -- Show in command line or notification
    local command = "trans -brief '" .. text .. "'"
    local handle = io.popen(command)
    local result = handle:read '*a'
    handle:close()
    vim.notify('Translation: ' .. result, vim.log.levels.INFO)
    -- Alternative: print to command line
    -- print("Text under cursor: " .. text)
  else
    vim.notify('No text under cursor', vim.log.levels.WARN)
  end
end

vim.keymap.set({ 'n', 'v' }, '<leader>st', show_text_simple, {
  desc = 'Show text under cursor/selection',
})
