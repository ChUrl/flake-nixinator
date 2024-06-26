local async = require('gitsigns.async')
local scheduler = require('gitsigns.async').scheduler

local log = require('gitsigns.debug.log')
local util = require('gitsigns.util')
local system = require('gitsigns.system').system

local gs_config = require('gitsigns.config')
local config = gs_config.config

local uv = vim.uv or vim.loop

local dprint = log.dprint
local dprintf = log.dprintf
local error_once = require('gitsigns.message').error_once

local check_version = require('gitsigns.git.version').check

local M = {}

--- @type fun(cmd: string[], opts?: vim.SystemOpts): vim.SystemCompleted
local asystem = async.wrap(3, system)

--- @param file string
--- @return boolean
local function in_git_dir(file)
  for _, p in ipairs(vim.split(file, util.path_sep)) do
    if p == '.git' then
      return true
    end
  end
  return false
end

--- @class Gitsigns.GitObj
--- @field file string
--- @field encoding string
--- @field i_crlf boolean Object has crlf
--- @field w_crlf boolean Working copy has crlf
--- @field mode_bits string
--- @field revision? string Revision the object is tracking against. Nil for index
--- @field object_name string The fixed object name to use.
--- @field relpath string
--- @field orig_relpath? string Use for tracking moved files
--- @field repo Gitsigns.Repo
--- @field has_conflicts? boolean
local Obj = {}

M.Obj = Obj

--- @class Gitsigns.RepoInfo
--- @field gitdir string
--- @field toplevel string
--- @field detached boolean
--- @field abbrev_head string

--- @class Gitsigns.Repo : Gitsigns.RepoInfo
--- @field username string
local Repo = {}
M.Repo = Repo

--- @class Gitsigns.Git.JobSpec : vim.SystemOpts
--- @field command? string
--- @field ignore_error? boolean

--- @async
--- @param args string[]
--- @param spec? Gitsigns.Git.JobSpec
--- @return string[] stdout, string? stderr
local function git_command(args, spec)
  spec = spec or {}

  local cmd = {
    spec.command or 'git',
    '--no-pager',
    '--no-optional-locks',
    '--literal-pathspecs',
    '-c',
    'gc.auto=0', -- Disable auto-packing which emits messages to stderr
    unpack(args),
  }

  if spec.text == nil then
    spec.text = true
  end

  -- Fix #895. Only needed for Nvim 0.9 and older
  spec.clear_env = true

  --- @type vim.SystemCompleted
  local obj = asystem(cmd, spec)
  local stdout = obj.stdout
  local stderr = obj.stderr

  if not spec.ignore_error and obj.code > 0 then
    local cmd_str = table.concat(cmd, ' ')
    log.eprintf("Received exit code %d when running command\n'%s':\n%s", obj.code, cmd_str, stderr)
  end

  local stdout_lines = vim.split(stdout or '', '\n')

  if spec.text then
    -- If stdout ends with a newline, then remove the final empty string after
    -- the split
    if stdout_lines[#stdout_lines] == '' then
      stdout_lines[#stdout_lines] = nil
    end
  end

  if log.verbose then
    log.vprintf('%d lines:', #stdout_lines)
    for i = 1, math.min(10, #stdout_lines) do
      log.vprintf('\t%s', stdout_lines[i])
    end
  end

  if stderr == '' then
    stderr = nil
  end

  return stdout_lines, stderr
end

--- @async
--- @param file_cmp string
--- @param file_buf string
--- @param indent_heuristic? boolean
--- @param diff_algo string
--- @return string[] stdout, string? stderr
function M.diff(file_cmp, file_buf, indent_heuristic, diff_algo)
  return git_command({
    '-c',
    'core.safecrlf=false',
    'diff',
    '--color=never',
    '--' .. (indent_heuristic and '' or 'no-') .. 'indent-heuristic',
    '--diff-algorithm=' .. diff_algo,
    '--patch-with-raw',
    '--unified=0',
    file_cmp,
    file_buf,
  }, {
    -- git-diff implies --exit-code
    ignore_error = true,
  })
end

--- @async
--- @param gitdir string
--- @param head_str string
--- @param cwd string
--- @param cmd? string
--- @return string
local function process_abbrev_head(gitdir, head_str, cwd, cmd)
  if not gitdir then
    return head_str
  end
  if head_str == 'HEAD' then
    local short_sha = git_command({ 'rev-parse', '--short', 'HEAD' }, {
      command = cmd,
      ignore_error = true,
      cwd = cwd,
    })[1] or ''
    if log.debug_mode and short_sha ~= '' then
      short_sha = 'HEAD'
    end
    if
      util.path_exists(gitdir .. '/rebase-merge')
      or util.path_exists(gitdir .. '/rebase-apply')
    then
      return short_sha .. '(rebasing)'
    end
    return short_sha
  end
  return head_str
end

local has_cygpath = jit and jit.os == 'Windows' and vim.fn.executable('cygpath') == 1

local cygpath_convert ---@type fun(path: string): string

if has_cygpath then
  cygpath_convert = function(path)
    --- @type vim.SystemCompleted
    local obj = asystem({ 'cygpath', '-aw', path })
    return obj.stdout
  end
end

--- @param path string
--- @return string
local function normalize_path(path)
  if path and has_cygpath and not uv.fs_stat(path) then
    -- If on windows and path isn't recognizable as a file, try passing it
    -- through cygpath
    path = cygpath_convert(path)
  end
  return path
end

--- @async
--- @param cwd string
--- @param cmd? string
--- @param gitdir? string
--- @param toplevel? string
--- @return Gitsigns.RepoInfo
function M.get_repo_info(cwd, cmd, gitdir, toplevel)
  -- Does git rev-parse have --absolute-git-dir, added in 2.13:
  --    https://public-inbox.org/git/20170203024829.8071-16-szeder.dev@gmail.com/
  local has_abs_gd = check_version({ 2, 13 })
  local git_dir_opt = has_abs_gd and '--absolute-git-dir' or '--git-dir'

  -- Wait for internal scheduler to settle before running command (#215)
  scheduler()

  local args = {}

  if gitdir then
    vim.list_extend(args, { '--git-dir', gitdir })
  end

  if toplevel then
    vim.list_extend(args, { '--work-tree', toplevel })
  end

  vim.list_extend(args, {
    'rev-parse',
    '--show-toplevel',
    git_dir_opt,
    '--abbrev-ref',
    'HEAD',
  })

  local results = git_command(args, {
    command = cmd,
    ignore_error = true,
    cwd = toplevel or cwd,
  })

  local toplevel_r = normalize_path(results[1])
  local gitdir_r = normalize_path(results[2])

  if gitdir_r and not has_abs_gd then
    gitdir_r = assert(uv.fs_realpath(gitdir_r))
  end

  return {
    toplevel = toplevel_r,
    gitdir = gitdir_r,
    abbrev_head = process_abbrev_head(gitdir_r, results[3], cwd, cmd),
    detached = toplevel_r and gitdir_r ~= toplevel_r .. '/.git',
  }
end

--------------------------------------------------------------------------------
-- Git repo object methods
--------------------------------------------------------------------------------

--- Run git command the with the objects gitdir and toplevel
--- @async
--- @param args string[]
--- @param spec? Gitsigns.Git.JobSpec
--- @return string[] stdout, string? stderr
function Repo:command(args, spec)
  spec = spec or {}
  spec.cwd = self.toplevel

  local args1 = {
    '--git-dir',
    self.gitdir,
  }

  if self.detached then
    vim.list_extend(args1, { '--work-tree', self.toplevel })
  end

  vim.list_extend(args1, args)

  return git_command(args1, spec)
end

--- @return string[]
function Repo:files_changed()
  --- @type string[]
  local results = self:command({ 'status', '--porcelain', '--ignore-submodules' })

  local ret = {} --- @type string[]
  for _, line in ipairs(results) do
    if line:sub(1, 2):match('^.M') then
      ret[#ret + 1] = line:sub(4, -1)
    end
  end
  return ret
end

--- @param encoding string
--- @return boolean
local function iconv_supported(encoding)
  -- TODO(lewis6991): needs https://github.com/neovim/neovim/pull/21924
  if vim.startswith(encoding, 'utf-16') then
    return false
  elseif vim.startswith(encoding, 'utf-32') then
    return false
  end
  return true
end

--- Get version of file in the index, return array lines
--- @param object string
--- @param encoding? string
--- @return string[] stdout, string? stderr
function Repo:get_show_text(object, encoding)
  local stdout, stderr = self:command({ 'show', object }, { text = false, ignore_error = true })

  if encoding and encoding ~= 'utf-8' and iconv_supported(encoding) then
    for i, l in ipairs(stdout) do
      --- @diagnostic disable-next-line:param-type-mismatch
      stdout[i] = vim.iconv(l, encoding, 'utf-8')
    end
  end

  return stdout, stderr
end

--- @async
function Repo:update_abbrev_head()
  self.abbrev_head = M.get_repo_info(self.toplevel).abbrev_head
end

--- @private
--- @param dir string
--- @param gitdir? string
--- @param toplevel? string
function Repo:try_yadm(dir, gitdir, toplevel)
  if not config.yadm.enable or self.gitdir then
    return
  end

  local home = os.getenv('HOME')

  if not home or not vim.startswith(dir, home) then
    return
  end

  if #git_command({ 'ls-files', dir }, { command = 'yadm' }) == 0 then
    return
  end

  M.get_repo_info(dir, 'yadm', gitdir, toplevel)
  local yadm_info = M.get_repo_info(dir, 'yadm', gitdir, toplevel)
  for k, v in
    pairs(yadm_info --[[@as table<string,any>]])
  do
    ---@diagnostic disable-next-line:no-unknown
    self[k] = v
  end
end

--- @async
--- @param dir string
--- @param gitdir? string
--- @param toplevel? string
--- @return Gitsigns.Repo
function Repo.new(dir, gitdir, toplevel)
  local self = setmetatable({}, { __index = Repo })

  self.username = git_command({ 'config', 'user.name' }, { ignore_error = true })[1]
  local info = M.get_repo_info(dir, nil, gitdir, toplevel)
  for k, v in
    pairs(info --[[@as table<string,any>]])
  do
    ---@diagnostic disable-next-line:no-unknown
    self[k] = v
  end

  self:try_yadm(dir, gitdir, toplevel)

  return self
end

--------------------------------------------------------------------------------
-- Git object methods
--------------------------------------------------------------------------------

--- Run git command the with the objects gitdir and toplevel
--- @param args string[]
--- @param spec? Gitsigns.Git.JobSpec
--- @return string[] stdout, string? stderr
function Obj:command(args, spec)
  return self.repo:command(args, spec)
end

--- @param revision? string
function Obj:update_revision(revision)
  revision = util.norm_base(revision)
  self.revision = revision
  self:update()
end

--- @param update_relpath? boolean
--- @param silent? boolean
--- @return boolean
function Obj:update(update_relpath, silent)
  local old_object_name = self.object_name
  local props = self:file_info(self.file, silent)

  if update_relpath then
    self.relpath = props.relpath
  end
  self.object_name = props.object_name
  self.mode_bits = props.mode_bits
  self.has_conflicts = props.has_conflicts
  self.i_crlf = props.i_crlf
  self.w_crlf = props.w_crlf

  return old_object_name ~= self.object_name
end

--- @class (exact) Gitsigns.FileInfo
--- @field relpath string
--- @field i_crlf? boolean
--- @field w_crlf? boolean
--- @field mode_bits? string
--- @field object_name? string
--- @field has_conflicts? true

--- @param file? string
--- @param silent? boolean
--- @return Gitsigns.FileInfo
function Obj:file_info(file, silent)
  if self.revision and not vim.startswith(self.revision, ':') then
    return self:file_info_tree(file, silent)
  else
    return self:file_info_index(file, silent)
  end
end

--- @private
--- @param file? string
--- @param silent? boolean
--- @return Gitsigns.FileInfo
function Obj:file_info_index(file, silent)
  local has_eol = check_version({ 2, 9 })

  local cmd = {
    '-c',
    'core.quotepath=off',
    'ls-files',
    '--stage',
    '--others',
    '--exclude-standard',
  }

  if has_eol then
    cmd[#cmd + 1] = '--eol'
  end

  cmd[#cmd + 1] = file or self.file

  local results, stderr = self:command(cmd, { ignore_error = true })

  if stderr and not silent then
    -- ignore_error for the cases when we run:
    --    git ls-files --others exists/nonexist
    if not stderr:match('^warning: could not open directory .*: No such file or directory') then
      log.eprint(stderr)
    end
  end

  local relpath_idx = has_eol and 2 or 1

  local result = {}
  for _, line in ipairs(results) do
    local parts = vim.split(line, '\t')
    if #parts > relpath_idx then -- tracked file
      local attrs = vim.split(parts[1], '%s+')
      local stage = tonumber(attrs[3])
      if stage <= 1 then
        result.mode_bits = attrs[1]
        result.object_name = attrs[2]
      else
        result.has_conflicts = true
      end

      if has_eol then
        result.relpath = parts[3]
        local eol = vim.split(parts[2], '%s+')
        result.i_crlf = eol[1] == 'i/crlf'
        result.w_crlf = eol[2] == 'w/crlf'
      else
        result.relpath = parts[2]
      end
    else -- untracked file
      result.relpath = parts[relpath_idx]
    end
  end

  return result
end

--- @private
--- @param file? string
--- @param silent? boolean
--- @return Gitsigns.FileInfo
function Obj:file_info_tree(file, silent)
  local results, stderr = self:command({
    '-c',
    'core.quotepath=off',
    'ls-tree',
    self.revision,
    file or self.file,
  }, { ignore_error = true })

  if stderr then
    if not silent then
      log.eprint(stderr)
    end
    return {}
  end

  local info_line = results[1]
  if not info_line then
    return {}
  end

  local info, relpath = unpack(vim.split(info_line, '\t'))
  local mode_bits, objtype, object_name = unpack(vim.split(info, '%s+'))
  assert(objtype == 'blob')

  return {
    mode_bits = mode_bits,
    object_name = object_name,
    relpath = relpath,
  }
end

--- @param revision? string
--- @return string[] stdout, string? stderr
function Obj:get_show_text(revision)
  if revision and not self.relpath then
    dprint('no relpath')
    return {}
  end

  local object = revision and (revision .. ':' .. self.relpath) or self.object_name

  if not object then
    dprint('no revision or object_name')
    return { '' }
  end

  local stdout, stderr = self.repo:get_show_text(object, self.encoding)

  if not self.i_crlf and self.w_crlf then
    -- Add cr
    -- Do not add cr to the newline at the end of file
    for i = 1, #stdout - 1 do
      stdout[i] = stdout[i] .. '\r'
    end
  end

  return stdout, stderr
end

local function autocmd_changed(file)
  vim.schedule(function()
    vim.api.nvim_exec_autocmds('User', {
      pattern = 'GitSignsChanged',
      modeline = false,
      data = { file = file },
    })
  end)
end

function Obj:unstage_file()
  self:command({ 'reset', self.file })
  autocmd_changed(self.file)
end

--- @class Gitsigns.CommitInfo
--- @field author string
--- @field author_mail string
--- @field author_time integer
--- @field author_tz string
--- @field committer string
--- @field committer_mail string
--- @field committer_time integer
--- @field committer_tz string
--- @field summary string
--- @field sha string
--- @field abbrev_sha string
--- @field boundary? true

--- @class Gitsigns.BlameInfoPublic: Gitsigns.BlameInfo, Gitsigns.CommitInfo
--- @field body? string[]
--- @field hunk_no? integer
--- @field num_hunks? integer
--- @field hunk? string[]
--- @field hunk_head? string

--- @class Gitsigns.BlameInfo
--- @field orig_lnum integer
--- @field final_lnum integer
--- @field commit Gitsigns.CommitInfo
--- @field filename string
--- @field previous_filename? string
--- @field previous_sha? string

local NOT_COMMITTED = {
  author = 'Not Committed Yet',
  author_mail = '<not.committed.yet>',
  committer = 'Not Committed Yet',
  committer_mail = '<not.committed.yet>',
}

--- @param file string
--- @return Gitsigns.CommitInfo
function M.not_commited(file)
  local time = os.time()
  return {
    sha = string.rep('0', 40),
    abbrev_sha = string.rep('0', 8),
    author = 'Not Committed Yet',
    author_mail = '<not.committed.yet>',
    author_tz = '+0000',
    author_time = time,
    committer = 'Not Committed Yet',
    committer_time = time,
    committer_mail = '<not.committed.yet>',
    committer_tz = '+0000',
    summary = 'Version of ' .. file,
  }
end

---@param x any
---@return integer
local function asinteger(x)
  return assert(tonumber(x))
end

--- @param lines string[]
--- @param lnum? integer
--- @param opts? Gitsigns.BlameOpts
--- @return table<integer,Gitsigns.BlameInfo?>?
function Obj:run_blame(lines, lnum, opts)
  local ret = {} --- @type table<integer,Gitsigns.BlameInfo>

  if not self.object_name or self.repo.abbrev_head == '' then
    -- As we support attaching to untracked files we need to return something if
    -- the file isn't isn't tracked in git.
    -- If abbrev_head is empty, then assume the repo has no commits
    local commit = M.not_commited(self.file)
    for i in ipairs(lines) do
      ret[i] = {
        orig_lnum = 0,
        final_lnum = i,
        commit = commit,
        filename = self.file,
      }
    end
    return ret
  end

  local args = { 'blame', '--contents', '-', '--incremental' }

  opts = opts or {}

  if opts.ignore_whitespace then
    args[#args + 1] = '-w'
  end

  if lnum then
    vim.list_extend(args, { '-L', lnum .. ',+1' })
  end

  if opts.extra_opts then
    vim.list_extend(args, opts.extra_opts)
  end

  local ignore_file = self.repo.toplevel .. '/.git-blame-ignore-revs'
  if uv.fs_stat(ignore_file) then
    vim.list_extend(args, { '--ignore-revs-file', ignore_file })
  end

  args[#args + 1] = opts.rev
  args[#args + 1] = '--'
  args[#args + 1] = self.file

  local results, stderr = self:command(args, { stdin = lines, ignore_error = true })
  if stderr then
    error_once('Error running git-blame: ' .. stderr)
    return
  end

  if #results == 0 then
    return
  end

  local commits = {} --- @type table<string,Gitsigns.CommitInfo>
  local i = 1

  while i <= #results do
    --- @param pat? string
    --- @return string
    local function get(pat)
      local l = assert(results[i])
      i = i + 1
      if pat then
        return l:match(pat)
      end
      return l
    end

    local function peek(pat)
      local l = results[i]
      if l and pat then
        return l:match(pat)
      end
      return l
    end

    local sha, orig_lnum_str, final_lnum_str, size_str = get('(%x+) (%d+) (%d+) (%d+)')
    local orig_lnum = asinteger(orig_lnum_str)
    local final_lnum = asinteger(final_lnum_str)
    local size = asinteger(size_str)

    if peek():match('^author ') then
      --- @type table<string,string|true>
      local commit = {
        sha = sha,
        abbrev_sha = sha:sub(1, 8),
      }

      -- filename terminates the entry
      while peek() and not (peek():match('^filename ') or peek():match('^previous ')) do
        local l = get()
        local key, value = l:match('^([^%s]+) (.*)')
        if key then
          if vim.endswith(key, '_time') then
            value = tonumber(value)
          end
          key = key:gsub('%-', '_') --- @type string
          commit[key] = value
        else
          commit[l] = true
          if l ~= 'boundary' then
            dprintf("Unknown tag: '%s'", l)
          end
        end
      end

      -- New in git 2.41:
      -- The output given by "git blame" that attributes a line to contents
      -- taken from the file specified by the "--contents" option shows it
      -- differently from a line attributed to the working tree file.
      if
        commit.author_mail == '<external.file>'
        or commit.author_mail == 'External file (--contents)'
      then
        commit = vim.tbl_extend('force', commit, NOT_COMMITTED)
      end
      commits[sha] = commit
    end

    local previous_sha, previous_filename = peek():match('^previous (%x+) (.*)')
    if previous_sha then
      get()
    end

    local filename = assert(get():match('^filename (.*)'))

    for j = 0, size - 1 do
      ret[final_lnum + j] = {
        final_lnum = final_lnum + j,
        orig_lnum = orig_lnum + j,
        commit = commits[sha],
        filename = filename,
        previous_filename = previous_filename,
        previous_sha = previous_sha,
      }
    end
  end

  return ret
end

--- @param obj Gitsigns.GitObj
local function ensure_file_in_index(obj)
  if obj.object_name and not obj.has_conflicts then
    return
  end

  if not obj.object_name then
    -- If there is no object_name then it is not yet in the index so add it
    obj:command({ 'add', '--intent-to-add', obj.file })
  else
    -- Update the index with the common ancestor (stage 1) which is what bcache
    -- stores
    local info = string.format('%s,%s,%s', obj.mode_bits, obj.object_name, obj.relpath)
    obj:command({ 'update-index', '--add', '--cacheinfo', info })
  end

  obj:update()
end

--- Stage 'lines' as the entire contents of the file
--- @param lines string[]
function Obj:stage_lines(lines)
  local stdout = self:command({
    'hash-object',
    '-w',
    '--path',
    self.relpath,
    '--stdin',
  }, { stdin = lines })

  local new_object = stdout[1]

  self:command({
    'update-index',
    '--cacheinfo',
    string.format('%s,%s,%s', self.mode_bits, new_object, self.relpath),
  })

  autocmd_changed(self.file)
end

--- @param hunks Gitsigns.Hunk.Hunk[]
--- @param invert? boolean
function Obj:stage_hunks(hunks, invert)
  ensure_file_in_index(self)

  local gs_hunks = require('gitsigns.hunks')

  local patch = gs_hunks.create_patch(self.relpath, hunks, self.mode_bits, invert)

  if not self.i_crlf and self.w_crlf then
    -- Remove cr
    for i = 1, #patch do
      patch[i] = patch[i]:gsub('\r$', '')
    end
  end

  self:command({
    'apply',
    '--whitespace=nowarn',
    '--cached',
    '--unidiff-zero',
    '-',
  }, {
    stdin = patch,
  })

  autocmd_changed(self.file)
end

--- @return string?
function Obj:has_moved()
  local out = self:command({ 'diff', '--name-status', '-C', '--cached' })
  local orig_relpath = self.orig_relpath or self.relpath
  for _, l in ipairs(out) do
    local parts = vim.split(l, '%s+')
    if #parts == 3 then
      local orig, new = parts[2], parts[3]
      if orig_relpath == orig then
        self.orig_relpath = orig_relpath
        self.relpath = new
        self.file = self.repo.toplevel .. '/' .. new
        return new
      end
    end
  end
end

--- @param file string
--- @param revision string?
--- @param encoding string
--- @param gitdir string?
--- @param toplevel string?
--- @return Gitsigns.GitObj?
function Obj.new(file, revision, encoding, gitdir, toplevel)
  if in_git_dir(file) then
    dprint('In git dir')
    return nil
  end
  local self = setmetatable({}, { __index = Obj })

  if not vim.startswith(file, '/') and toplevel then
    file = toplevel .. util.path_sep .. file
  end

  self.file = file
  self.revision = util.norm_base(revision)
  self.encoding = encoding
  self.repo = Repo.new(util.dirname(file), gitdir, toplevel)

  if not self.repo.gitdir then
    dprint('Not in git repo')
    return nil
  end

  -- When passing gitdir and toplevel, suppress stderr when resolving the file
  local silent = gitdir ~= nil and toplevel ~= nil

  self:update(true, silent)

  return self
end

return M
