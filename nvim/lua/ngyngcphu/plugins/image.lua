return {
  "3rd/image.nvim",
  build = false, -- don't build the magick rock, we use magick_cli processor
  event = "VeryLazy",
  init = function()
    -- magick_cli renders SVGs with ImageMagick's built-in renderer, which needs a font map.
    -- Homebrew's ImageMagick has none, so any SVG with text fails ("unable to read font `'").
    local dir = vim.fn.stdpath("config") .. "/imagemagick"
    if vim.uv.fs_stat(dir .. "/type.xml") then
      local current = vim.env.MAGICK_CONFIGURE_PATH
      vim.env.MAGICK_CONFIGURE_PATH = current and (dir .. ":" .. current) or dir
    end
  end,
  opts = {
    -- `kitty` backend uses the Kitty Graphics Protocol.
    -- iTerm2 >= 3.5 supports it natively, and it works inside Tmux
    -- (tmux >= 3.3 with `allow-passthrough on`).
    backend = "kitty",
    processor = "magick_cli",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        only_render_image_at_cursor_mode = "popup",
        floating_windows = false,
        filetypes = { "markdown", "vimwiki" },
      },
      asciidoc = {
        enabled = true,
        filetypes = { "asciidoc", "adoc" },
      },
      neorg = {
        enabled = true,
        filetypes = { "norg" },
      },
      rst = { enabled = true },
      typst = {
        enabled = true,
        filetypes = { "typst" },
      },
      html = { enabled = false },
      css = { enabled = false },
    },
    max_width_window_percentage = 50,
    max_height_window_percentage = 50,
    window_overlap_clear_enabled = false,
    tmux_show_only_in_active_window = false,
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
  },
  config = function(_, opts)
    require("image").setup(opts)
    -- image.nvim rebuilds every image on each text change and asks ImageMagick for its format
    -- and size each time: two blocking calls per image (~0.1 s each for an SVG), so typing in a
    -- Markdown file with diagrams lags. Cache both answers per file and modification time.
    local magick = require("image/processors/magick_cli")
    for _, name in ipairs({ "get_format", "get_dimensions" }) do
      local original, cache = magick[name], {}
      magick[name] = function(path, ...)
        local key = path .. "@" .. vim.fn.getftime(path)
        if cache[key] == nil then cache[key] = original(path, ...) end
        return cache[key]
      end
    end
  end,
}
