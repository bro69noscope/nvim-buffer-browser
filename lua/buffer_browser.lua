--[[
BUFFER BROWSER
Author: Marc Coquand
]]
local api = vim.api

--[[ STATE MANAGEMENT
We make use of a Zipper to keep track of the state of the buffers
(https://stackoverflow.com/questions/380438/what-is-the-zipper-data-structure-and-should-i-be-using-it)
]]
local function matchesFilter(filters, name)
	if filters == nil then
		return false
	end

	for _, filter in ipairs(filters) do
		if name == filter then
			return true
		end
	end
	return false
end


local function stateAppend(bufNr, stateFiletype, state, filters)
	if (state.current == bufNr) then
		return state
	end

	-- if filters matches the filetype of the buffer we change from, don't add it to history
	if (stateFiletype ~= nil and matchesFilter(filters, stateFiletype)) then
		state.current = bufNr
		return state
	else
		state.future = {}
		table.insert(state.previous, 1, state.current)
		state.current = bufNr

		return state
	end
end

local function stateGoBack(state)
	-- Go back in the state by setting current to the first element of previous, and appending the current to the future
	-- Check if past is empty, if so return state as is
	if #state.previous == 0 then
		return state
	end

	table.insert(state.future, 1, state.current)
	state.current = table.remove(state.previous, 1)
	return state
end

local function stateGoForward(state)
	-- Go forward in the state by setting current to the first element of future, and appending the current to the previous

	-- Check if future is empty, if so return state as is
	if #state.future == 0 then
		return state
	end

	table.insert(state.previous, 1, state.current)
	state.current = table.remove(state.future, 1)

	return state
end

local function StateDelete(state, bufNr)
	-- Delete bufNr from state.previous
	for i, v in ipairs(state.previous) do
		if v == bufNr then
			table.remove(state.previous, i)
		end
	end

	-- Delete bufNr from state.future
	for i, v in ipairs(state.future) do
		if v == bufNr then
			table.remove(state.future, i)
		end
	end

	-- If bufNr is current, set current to the first element of previous
	if state.current == bufNr and #state.previous > 0 then
		state.current = table.remove(state.previous, 1)
		return state
	end

	-- If bufNr is current and we have a future
	if state.current == bufNr and #state.future > 0 then
		state.current = table.remove(state.future, 1)
		return state
	end

	-- If bufNr is current, set current to the first element of future
	if state.current == bufNr then
		state.current = nil
		return state
	end
	return state
end

local function stateIsEmpty(state)
	return (state.current == nil and state.previous == nil and state.future == nil)
end


-- [[ EFFECTS ]]
local function setState(state)
	vim.w.buffer_browser_previous = state.previous
	vim.w.buffer_browser_current = state.current
	vim.w.buffer_browser_future = state.future
end

local function getState()
	local current = vim.w.buffer_browser_current
	local previous = vim.w.buffer_browser_previous
	local future = vim.w.buffer_browser_future
	return {
		current = current,
		previous = previous,
		future = future,
	}
end

local function initState(bufNr)
	vim.w.buffer_browser_current = bufNr
	vim.w.buffer_browser_previous = {}
	vim.w.buffer_browser_future = {}
end

local function getBufNr()
	local winnr = api.nvim_tabpage_get_win(0)
	return api.nvim_win_get_buf(winnr)
end

local function getFiletype(bufnr)
	if (bufnr == nil and api.nvim_buf_is_valid(bufnr)) then
		return nil
	end
	return vim.bo[bufnr].filetype
end

--[[ AUTO COMMANDS ]]
function BufferBrowserBufferEnter(args)
	local bufNr = args.buf
	local filters = vim.g.buffer_browser_filters

	local state = getState()
	if stateIsEmpty(state) then
		initState(bufNr)
	else
		if (state.current ~= bufNr) then
			local stateFiletype = getFiletype(state.current)
			stateAppend(bufNr, stateFiletype, state, filters)
			setState(state)
		end
	end
end

function BufferBrowserBufferWipeOut(args)
	local buf = args.buf
	local state = getState()
	if not stateIsEmpty(state) then
		StateDelete(state, buf)
		setState(state)
	end
end

local BufferBrowserGroup = api.nvim_create_augroup('BufferBrowser', { clear = true })

api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' },
	{
		group = BufferBrowserGroup,
		pattern = '*',
		callback = function(args)
			BufferBrowserBufferEnter(args)
		end
	}
)

-- BufWipeout is called before deletion
api.nvim_create_autocmd('BufWipeout',
	{
		group = BufferBrowserGroup,
		pattern = '*',
		callback = function(args)
			BufferBrowserBufferWipeOut(args)
		end
	}
)


--[[ COMMANDS ]]
local function next()
	local bufnr = getBufNr()
	local state = getState()

	if stateIsEmpty(state) then
		initState(bufnr)
	else
		stateGoForward(state)
		setState(state)
	end
	api.nvim_command('buffer ' .. state.current)
end

local function prev()
	local bufnr = getBufNr()
	local state = getState()

	if stateIsEmpty(state) then
		initState(bufnr)
	else
		stateGoBack(state)
		setState(state)
	end
	api.nvim_command('buffer ' .. state.current)
end

--[[ DEBUG ]]
local function printBrowserHistory()
	local state = getState()
	print('Browser State Previous: ' .. vim.inspect(state.previous))
	print('Browser State Current: ' .. vim.inspect(state.current))
	print('Browser State Future: ' .. vim.inspect(state.future))
end


--[[ SETUP ]]
local function setup(opts)
	if (opts == nil) then
		local default = {
			'gitcommit', 'TelescopePrompt'
		}
		vim.g.buffer_browser_filters = default
	else
		-- Filter is based on filetype
		vim.g.buffer_browser_filters = opts.filetype_filters
	end
end

return {
	next = next,
	prev = prev,
	printBrowserHistory = printBrowserHistory,
	setup = setup
}
