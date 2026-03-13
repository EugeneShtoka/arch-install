--- @since 25.5.31
--- @sync entry

local function setup(self, opts) self.open_multi = opts.open_multi end

local function entry(self)
	local h = cx.active.current.hovered
	if #cx.active.selected > 0 then
		local pf = io.open("/tmp/yazi-chooser-path", "r")
		local chooser = pf and pf:read("*l")
		if pf then pf:close() end
		local dl = io.open("/tmp/yazi-debug.log", "w")
		if dl then
			dl:write("chooser: " .. tostring(chooser) .. "\n")
			dl:write("selected len: " .. #cx.active.selected .. "\n")
			local count = 0
			for _, url in pairs(cx.active.selected) do
				count = count + 1
				dl:write("pairs[" .. count .. "]: " .. tostring(url) .. "\n")
			end
			dl:write("pairs total: " .. count .. "\n")
			dl:close()
		end
		if chooser then
			local f = io.open("/tmp/yazi-multi-result", "w")
			if f then
				for _, url in pairs(cx.active.selected) do
					f:write(tostring(url) .. "\n")
				end
				f:close()
			end
			ya.emit("quit", {})
		else
			ya.emit("open", {})
		end
	elseif h and h.cha.is_dir then
		ya.emit("enter", {})
	else
		ya.emit("open", { hovered = true })
	end
end

return { entry = entry, setup = setup }
