local unistd = require("posix.unistd")
local stdio = require("posix.stdio")

local command = {}

local function close(fd)
	for key, value in ipairs(fd)
	do
		local ret = unistd.close(value)

		if not ret
		then
			error("Close failed")
		end
	end
end

-- executes function, opens dialogue if the command writes to stdin or stdout
function command.execute(cmd)

	-- pipes for communication
	local stdin_r, stdin_w = unistd.pipe()
	local stdout_r, stdout_w = unistd.pipe()
	local stderr_r, stderr_w = unistd.pipe()

	if not (stdin_r and stdout_r and stderr_r)
	then
		error("Unable to create pipes")
	end


	local pid = unistd.fork()

	if not pid
	then
		error("Fork failed")
	end

	if pid == 0 then
		-- child
		unistd.dup2(stdin_r, stdio.fileno(io.stdin))
		unistd.dup2(stdout_w, stdio.fileno(io.stdout))
		unistd.dup2(stderr_w, stdio.fileno(io.stderr))

		close({stdin_r, stdin_w, stdout_r, stdout_w, stderr_r, stderr_w})

		unistd.execp(cmd[1], cmd)

		-- exec failed
		error("exec failed")
		unistd._exit(-1)

	end

	-- parent
	close({stdin_r, stdout_w, stderr_w})

	-- interact with user

	close({stdin_w, stdout_r, stderr_r,})

	-- wait for child
	require("posix.sys.wait").wait(pid)

end

return command
