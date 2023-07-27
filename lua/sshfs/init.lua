local sshfs = {}

local config = {
	-- set om setup
}

function sshfs.setup(opts)
	config.ssh_config = opts.ssh_config or "~/.ssh/config"
	congig.sshfs_opts = opts.sshfs_opts or ""
	config.mountpoint = opts.mountpoint or "~/.ssh/.sshfs.nvim"


end

function sshfs.connect(host)

end


return sshfs


