return {
  "nvim-pack/nvim-spectre",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local spectre = require("spectre")

    -- Setup spectre
    spectre.setup({
      color_devicons = true,
      open_cmd = "vnew",
      live_update = false, -- auto execute search and replace when you write to the file
      lnum_for_startline = false, -- use `true` to set the line number of the buffer line as the start line of match range
      line_sep = "━━━━━━━━━━━━━━━━",
      result_padding = "│ ",
      on_open_cmd = function(win)
        -- Commands triggered only when opening the search window
      end,
      is_insert_mode = false, -- start open file on is_insert_mode
      mapping = {
        ["toggle_line"] = {
          map = "dd",
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = "toggle current item",
        },
        ["enter_file"] = {
          map = "<cr>",
          cmd = "<cmd>lua require('spectre.actions').enter_file()<CR>",
          desc = "open file",
        },
        ["send_to_qf"] = {
          map = "<leader>q",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all items to quickfix",
        },
        ["replace_cmd"] = {
          map = "<leader>c",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "input replace vim command",
        },
        ["show_option_menu"] = {
          map = "<leader>o",
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = "show options",
        },
        ["run_current_replace"] = {
          map = "<leader>rc",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current line",
        },
        ["run_replace"] = {
          map = "<leader>ra",
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all",
        },
        ["change_view_mode"] = {
          map = "<leader>v",
          cmd = "<cmd>lua require('spectre').change_view()<CR>",
          desc = "results only / last search / both",
        },
        ["change_replace_sed"] = {
          map = "crs",
          cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
          desc = "use sed to replace",
        },
        ["change_replace_oxi"] = {
          map = "cro",
          cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
          desc = "use oxi to replace",
        },
        ["toggle_live_update"] = {
          map = "crl",
          cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
          desc = "toggle live update",
        },
        ["toggle_ignore_case"] = {
          map = "cri",
          cmd = "<cmd>lua require('spectre').toggle_ignore_case()<CR>",
          desc = "toggle ignore case",
        },
        ["toggle_ignore_hidden"] = {
          map = "crh",
          cmd = "<cmd>lua require('spectre').toggle_ignore_hidden()<CR>",
          desc = "toggle search hidden files",
        },
        ["resume_last_search"] = {
          map = "<leader>l",
          cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
          desc = "resume last search before close",
        },
        ["quit"] = {
          map = "q",
          cmd = "<cmd>lua require('spectre').close()<CR>",
          desc = "quit",
        },
      },
      find_engine = {
        -- rg is map with finder_cmd
        ["rg"] = {
          cmd = "rg",
          -- all the option from rg works here; and don't forget to add `--vimgrep` to job inner args will devide from `args`
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          } --[[ args placeholder ]],
        },
      },
      replace_engine = {
        ["sed"] = {
          cmd = "sed",
          args = nil,
        },
      },
      default = {
        find = {
          --pick one of the search engine
          cmd = "rg",
          options = {},
        },
        replace = {
          --pick one of the replace enum
          cmd = "sed",
        },
      },
      replace_vim_cmd = "cfdo",
      is_block_ui_break = false,
      popups = {
        close_and_resume_normal_mode = true,
      },
    })

    -- Keymaps
    local keymap = vim.keymap
    keymap.set("n", "<leader>S", "<cmd>Spectre<cr>", { desc = "Open Spectre" })
    keymap.set("n", "<leader>sw", "<cmd>Spectre<cr><cmd>lua require('spectre').change_view()<CR>", { desc = "Spectre word" })
    keymap.set("n", "<leader>sp", "viw:Spectre<CR>", { desc = "Spectre on selection", silent = false })
  end,
}
