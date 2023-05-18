-- BUFFER BROWSER
-- Author: Marc Coquand
-- See readme for explanation on what it does.
-- This code contains examples that can be used to test the code.
-- Run them in `lua %`
-- or with a code runner, like sniprun.
local api = vim.api

local function StateAppend(bufName, state, filters)
	-- State has three fields, current = current buffer, previous = previous buffer, and future = future buffers
	-- This function clears the future, and appends the current to the previous, and sets the current to the next

	-- If filters matches the bufName, skip the buffer
	if filters ~= nil then
		for _, filter in ipairs(filters) do
			if string.match(bufName, filter) then
				return state
			end
		end
	end

	-- Clear the future
	state.future = {}
	-- Append the current to the previous
	table.insert(state.previous, state.current)
	-- Set the current to the next
	state.current = bufName

	return state
end
-- Test StateAppend
-- local state = { current = 1, previous = { 2, 3 }, future = { 4, 5 } }
-- print(StateAppend(6, state, {})['current'])
-- -- > 6
-- state = { current = 1, previous = { 2, 3 }, future = { 4, 5 } }
-- print(StateAppend(6, state, {})['previous'][1])
-- -- > 2
-- state = { current = 1, previous = { 2, 3 }, future = { 4, 5 } }
-- print(StateAppend(6, state, { 6 })['current'])
-- -- > 1

local function StateGoBack(state)
	-- Go back in the state by setting current to the first element of previous, and appending the current to the future
	-- Check if past is empty, if so return state as is
	if #state.previous == 0 then
		return state
	end

	table.insert(state.future, state.current)
	state.current = table.remove(state.previous, 1)
	return state
end
-- Test StateGoBack
-- local state = { current = 1, previous = { 2, 3 }, future = { 4, 5 } }
-- print(StateGoBack(StateGoBack(StateGoBack(state)))['current'])
-- > 3

local function StateGoForward(state)
	-- Go forward in the state by setting current to the first element of future, and appending the current to the previous

	-- Check if future is empty, if so return state as is
	if #state.future == 0 then
		return state
	end

	table.insert(state.previous, state.current)
	state.current = table.remove(state.future, 1)

	return state
end
-- Test StateGoForward
-- local state = { current = 1, previous = { 2, 3 }, future = { 4, 5 } }
-- print(StateGoForward(StateGoForward(StateGoForward(state)))['current'])
-- > 5

function BufferEnter()
	local bufName = api.nvim_buf_get_name(0)
	local state = vim.g.buffer_browser_state
	local filters = vim.g.buffer_browser_filters
	vim.g.buffer_browser_state = StateAppend(bufName, state, filters)
end

local BufferBrowserGroup = api.nvim_create_augroup('BufferBrowser')

api.nvim_create_autocmd('WinEnter', {
	'*',
	'lua BufferEnter()',
	{ group = BufferBrowserGroup }
})
api.nvim_create_autocmd('BufEnter', {
	'*',
	'lua BufferEnter()',
	{ group = BufferBrowserGroup }
})
