-- Seamless navigation between nvim splits and tmux panes with <C-h/j/k/l>.
-- Pairs with the vim-tmux-navigator plugin configured in ~/.tmux.conf.
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
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left (tmux/nvim)" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down (tmux/nvim)" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up (tmux/nvim)" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (tmux/nvim)" },
    { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate previous (tmux/nvim)" },
  },
}
