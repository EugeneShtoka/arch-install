-- Blink.cmp source adapter for supermaven-nvim.
-- Reads from supermaven's already-computed inlay_instance so the suggestion
-- appears in blink's ranked completion list (scored below path/LSP) instead
-- of rendering its own ghost text that races with blink.
local M = {}

function M.new()
  return setmetatable({}, { __index = M })
end

function M:get_trigger_characters() return {} end

function M:get_completions(ctx, callback)
  callback = vim.schedule_wrap(callback)

  local ok, preview = pcall(require, 'supermaven-nvim.completion_preview')
  if not ok then
    return callback { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }
  end

  local inlay = preview:get_inlay_instance()
  if not inlay or not inlay.is_active or not inlay.completion_text or inlay.completion_text == '' then
    return callback { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }
  end

  local completion_text = inlay.line_before_cursor .. inlay.completion_text
  local split = vim.split(completion_text, '\n', { plain = true })

  local label = split[1]:gsub('^%s*', '')
  if #label > 40 then
    label = label:sub(1, 20) .. ' ... ' .. label:sub(#label - 14)
  end

  -- ctx.cursor = {row (1-indexed), col (0-indexed byte)}
  local line = ctx.cursor[1] - 1
  local prior_delete = inlay.prior_delete or 0
  local start_char = math.max(ctx.cursor[2] - prior_delete - #inlay.line_before_cursor, 0)
  local end_char = vim.fn.col '$' - 1 -- exclusive, 0-indexed

  callback {
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = {
      {
        label = label,
        kind = 1, -- Text
        insertTextFormat = #split > 1 and 2 or 1,
        textEdit = {
          newText = completion_text,
          insert = {
            start = { line = line, character = start_char },
            ['end'] = { line = line, character = end_char },
          },
          replace = {
            start = { line = line, character = start_char },
            ['end'] = { line = line, character = end_char },
          },
        },
        documentation = {
          kind = 'markdown',
          value = '```' .. (vim.bo.filetype or '') .. '\n' .. completion_text .. '\n```',
        },
      },
    },
  }
end

return M
