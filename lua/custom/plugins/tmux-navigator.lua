return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<C-w>h", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<C-w>j", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<C-w>k", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<C-w>l", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<C-w>\\", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
