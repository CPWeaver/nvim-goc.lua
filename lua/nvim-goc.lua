local M = {
  hi = vim.api.nvim_create_namespace("goc"),
  errBuf = nil,
  splitCmd = 'sp ',
  splitSBCmd = 'to ',
}

M.setup = function(opts)
  vim.highlight.link('GocNormal', 'Comment')
  vim.highlight.link('GocCovered', 'String')
  vim.highlight.link('GocUncovered', 'Error')

  if opts then
      verticalSplit = opts.verticalSplit or false
      assert(type(verticalSplit) == "boolean", "verticalSplit must be boolean or nil")
      M.splitCmd = verticalSplit and 'vsp ' or 'sp '
      M.splitSBCmd = verticalSplit and 'vert ' or 'to '
  end
end

M.Coverage = function()
  print('[goc] ...')
  if M.errBuf ~= nil then
    vim.api.nvim_buf_set_lines(M.errBuf, 0, -1, false, {"..."})
  else
    M.errBuf = vim.api.nvim_create_buf(true, true)
  end
  local fullPathFile = string.gsub(vim.api.nvim_buf_get_name(0), "_test", "")
  local bufnr = vim.uri_to_bufnr("file://" .. fullPathFile)

  -- use '%:.' to ensure the current path is relative (required for matching
  -- coverage output)
  local relativeFile = string.gsub(vim.fn.expand('%:.'), "_test", "")
  local package = vim.fn.expand('%:p:h')
  local tmp = vim.api.nvim_eval('tempname()')

  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  local handle = nil
  handle = vim.loop.spawn('go', {args = {'test', '-coverprofile', tmp, package}, stdio = {nil, stdout, stderr}}, vim.schedule_wrap(function(code, signal)

    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()

    -- shouldn't be needed but let's make sure we have a clean slate
    M.ClearCoverage(bufnr)

    -- 'go test' completed successfully
    if code == 0 then
      local percent = string.gmatch(table.concat(vim.api.nvim_buf_get_lines(M.errBuf, 0, -1, true)), 'coverage: (%d+)')()
      if percent ~= nil then
        print('[goc] coverage', percent .. '%')
        if #vim.fn.win_findbuf(M.errBuf) > 0 then
          vim.api.nvim_buf_delete(M.errBuf, {force=true})
          M.errBuf = nil
        end
      else
        print("[goc] check output!")
        if #vim.fn.win_findbuf(M.errBuf) == 0 then
          vim.cmd("vert sb " .. M.errBuf)
        end
      end

      if not vim.api.nvim_buf_is_loaded(bufnr) or #vim.fn.win_findbuf(bufnr) == 0 then
        vim.cmd(M.splitCmd .. string.gsub(fullPathFile, vim.fn.getcwd() .. '/', ''))
      elseif vim.tbl_contains(vim.opt.switchbuf:get(), 'useopen') then
        vim.cmd(":sb " .. string.gsub(fullPathFile, vim.fn.getcwd() .. '/', ''))
      end

      for i = 0,vim.fn.line('$') do
        vim.api.nvim_buf_add_highlight(bufnr, M.hi, "GocNormal", i, 0, -1)
      end

      local lines = vim.api.nvim_eval('readfile("' .. tmp .. '")')
      -- TODO: cleanup the tmp file in some way after reading it (they are
      -- deleted after nvim closes)

      -- Note: lua starts with '1' not '0'
      for i = 2,#lines do
        local path = string.gmatch(lines[i], '(.+):')()
        if string.find(path, relativeFile) then
          local marks = string.gmatch(string.gsub(lines[i], '[^:]+:', ''), '%d+')

          local startline = math.max(tonumber(marks()) - 1, 0)
          local startcol = math.max(tonumber(marks()) - 1, 0)
          local endline = math.max(tonumber(marks()) -1, 0)
          local endcol = tonumber(marks())
          local numstmt = tonumber(marks())
          local cnt = tonumber(marks())

          local hig = "GocUncovered"
          if cnt == 1 then
            hig = "GocCovered"
          end

          for y = startline,endline do
            local sc = 0
            local ec = -1
            if startline == y then
              sc = startcol
            end
            if endline == y then
              ec = endcol
            end

            vim.api.nvim_buf_add_highlight(bufnr, M.hi, hig, y, sc, ec)
          end
        end
      end
    else
      -- in case of error, show a message and then show the errBuf in a split
      print("[goc] fail!")
      if #vim.fn.win_findbuf(M.errBuf) == 0 then
        vim.cmd(M.splitSBCmd .. " sb " .. M.errBuf)
      end
    end
  end))

  local writeToScratch = function(err, data)
    vim.schedule(function()
      if err then
        vim.api.nvim_buf_set_lines(M.errBuf, -1, -1, false, vim.split(err, "\n"))
        return
      end
      if data then
        vim.api.nvim_buf_set_lines(M.errBuf, -1, -1, false, vim.split(data, "\n"))
      end
    end)
  end

  vim.loop.read_start(stdout, writeToScratch)
  vim.loop.read_start(stderr, writeToScratch)
end

M.ClearCoverage = function(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr or 0, M.hi, 0, -1)
end

M.AlternateSplit = function(split)
  M.Alternate(true)
end

M.Alternate = function(split)
  local path, file, ext = string.match(vim.api.nvim_buf_get_name(0), "(.+/)([^.]+)%.(.+)$")
  if ext == "go" then
    local aux = '_test.'
    if string.find(file, '_test') then
      aux = '.'
      path, file, ext = string.match(vim.api.nvim_buf_get_name(0), "(.+/)([^.]+)_test%.(.+)$")
    end

    local bufnr = vim.uri_to_bufnr("file://" .. path .. file .. aux .. ext)
    if not vim.api.nvim_buf_is_loaded(bufnr) or #vim.fn.win_findbuf(bufnr) == 0 then
      local cmd = split and M.splitCmd or 'e '
      vim.cmd(cmd .. path .. file .. aux .. ext)
    elseif vim.tbl_contains(vim.opt.switchbuf:get(), 'useopen') then
      vim.cmd(":" .. M.splitSBCmd .. "sb " .. path .. file .. aux .. ext)
    end
  end
end

return M
