local fn = vim.fn
local ui = vim.ui
local popup = require("plenary").popup

local command = {}

local cmd_output = ""
local cmd_input = ""

local exit = function(job_id, exit_code, event)
	--vim.api.nvim_echo({{"exit"}}, true, {})
	local msg = ""
	if exit_code ~= 0 then
		msg = msg .. "Command exited with code " .. exit_code .. ':\n'
	end

	msg = msg .. cmd_output
	if #msg > 0 then
		vim.notify(msg)
	end

	cmd_output = ""

end


local prompt = function(chan_id, secret)

	local input_func = secret and vim.ui.inputsecret or vim.ui.input
	input_func({prompt = cmd_output}, function (input)
		-- reset for new output
		cmd_output = ""

		-- save to discard output it produces
		cmd_input = input
		vim.fn.chansend(chan_id, input .. '\n')
	end)

end

local handle_output = function(chan_id, data, name)

	for key, value in ipairs(data) do
		-- discard user input
		if cmd_input ~= "" and vim.fn.matchstr(value, "^" .. cmd_input) ~= "" then
			-- clear
			cmd_input = ""
		-- discard empty fields
		elseif cmd_input ~= "" then
			cmd_output = cmd_output .. value .. '\n'
		end

	end

	if vim.fn.matchstr(cmd_output,
		"The authenticity of host.*Are you sure you want to continue connecting \\(yes\\/no\\/\\[fingerprint]\\)\\?") ~= ""
	then
		prompt(chan_id)
	elseif vim.fn.matchstr(cmd_output, ".*Password:")  ~= "" then
		prompt(chan_id, true)
	end

end


-- executes function, opens dialogue if the command writes certain output
-- to stderr or stdout
function command.execute(cmd)
	local ret = fn.jobstart(cmd, {on_stdout = handle_output, on_exit = exit,
				pty = true})

	if ret <= 0 then
		error("Cannot execute command")
	end
end

return command
