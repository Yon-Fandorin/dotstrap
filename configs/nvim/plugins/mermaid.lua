-- Requirements:
--   brew install imagemagick
--   npm install -g @mermaid-js/mermaid-cli

return {
  -- Mermaid syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "mermaid" })
    end,
  },

  -- Inline images through the Kitty graphics protocol (for example, Ghostty).
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    cond = function()
      return vim.fn.executable("magick") == 1 and vim.fn.executable("mmdc") == 1
    end,
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = false,
          only_render_image_at_cursor = false,
          filetypes = { "markdown" },
        },
      },
      max_width = 100,
      max_height = 50,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
    config = function(_, opts)
      require("image").setup(opts)

      local function render_mermaid_blocks(buf)
        buf = buf or vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local api = require("image")

        local i = 1
        while i <= #lines do
          if lines[i]:match("^%s*```mermaid%s*$") then
            local block_start = i
            local mermaid_lines = {}
            i = i + 1
            while i <= #lines and not lines[i]:match("^%s*```%s*$") do
              table.insert(mermaid_lines, lines[i])
              i = i + 1
            end
            local block_end = i -- Render below the closing fence (zero-based row).

            if #mermaid_lines > 0 then
              local id = "mermaid_" .. buf .. "_" .. block_start
              local tmpfile = vim.fn.tempname() .. ".mmd"
              local outfile = vim.fn.tempname() .. ".png"

              local f = io.open(tmpfile, "w")
              if f then
                f:write(table.concat(mermaid_lines, "\n"))
                f:close()

                vim.fn.jobstart(
                  { "mmdc", "-i", tmpfile, "-o", outfile, "-b", "transparent", "-t", "default" },
                  {
                    on_exit = function(_, code)
                      if code == 0 then
                        vim.schedule(function()
                          local win = vim.fn.bufwinid(buf)
                          if win == -1 then
                            return
                          end
                          local img = api.from_file(outfile, {
                            id = id,
                            window = win,
                            buffer = buf,
                            row = block_end,
                            col = 0,
                            with_virtual_padding = true,
                          })
                          if img then
                            img:render()
                          end
                        end)
                      end
                    end,
                  }
                )
              end
            end
          end
          i = i + 1
        end
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
        pattern = "*.md",
        callback = function(ev)
          render_mermaid_blocks(ev.buf)
        end,
      })
    end,
  },
}
