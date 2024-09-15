return {

  "lewis6991/gitsigns.nvim",
  event = "BufRead",
  config = function ()
      vim.keymap.set( 'n', '<leader>gnh', '<cmd>lua require"gitsigns".next_hunk()<CR>' )
      vim.keymap.set( 'n', '<leader>gph', '<cmd>lua require"gitsigns".prev_hunk()<CR>' )
      vim.keymap.set( 'n', '<leader>gsh', '<cmd>lua require"gitsigns".stage_hunk()<CR>' )
      vim.keymap.set( 'n', '<leader>guh', '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>' )
      vim.keymap.set( 'n', '<leader>grh', '<cmd>lua require"gitsigns".reset_hunk()<CR>' )
      vim.keymap.set( 'n', '<leader>gRb', '<cmd>lua require"gitsigns".reset_buffer()<CR>' )
      vim.keymap.set( 'n', '<leader>gph', '<cmd>lua require"gitsigns".preview_hunk()<CR>' )
      vim.keymap.set( 'n', '<leader>gbh', '<cmd>lua require"gitsigns".blame_line()<CR>' )
      vim.keymap.set( 'n', '<leader>gts', '<cmd>lua require"gitsigns".toggle_signs()<CR>' )
    require('gitsigns').setup({
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable = true,
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
})
  end

}

