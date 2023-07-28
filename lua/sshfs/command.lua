local fn = vim.fn

local command = {}

local handle_output = function(chan_id, data, name)
	-- interact with user
end


-- executes function, opens dialogue if the command writes to stdin or stdout
function command.execute(cmd)

	local ret = fn.jobstart(cmd, {on_stdout = handle_output, pty = true})

end

return command
