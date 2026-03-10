-- Disable ffmpeg-stats children_add display; we call its methods directly in our linemode
require("ffmpeg-stats"):setup({
	duration = false,
	resolution = false,
	codec = false,
	fps = false,
	bitrate = false,
	audio_codec = false,
	audio_channels = false,
	format = false,
	aspect = false,
})

local AUDIO_EXTS = {
	mp3 = true, flac = true, wav = true, m4a = true, ogg = true,
	aac = true, wma = true, opus = true, ape = true, alac = true,
	aiff = true, dsf = true, dff = true,
}

local SCRIPT_EXTS = {
	sh = true, bash = true, zsh = true, fish = true,
	py = true, rb = true, pl = true, lua = true,
}

-- Column widths
local W_DUR  = 8   -- "00:03:42"
local W_BR   = 8   -- "320kbps"
local W_SIZE = 8   -- "3.2 MiB"
local W_PERM = 10  -- "rwxr-xr-x"
local W_DATE = 10  -- "2024-03-10"

local function pad(s, w)
	return string.format("%" .. w .. "s", s)
end

function Linemode:size_and_info()
	local file = self._file
	local cha = file.cha
	local ext = file.url.ext and file.url.ext:lower()

	local size = file:size()
	local size_col = pad(size and ya.readable_size(size) or "-", W_SIZE)

	local btime = math.floor(cha.btime or 0)
	local date_col = pad(btime > 0 and os.date("%Y-%m-%d", btime) or "", W_DATE)

	-- Music: length  bitrate  size  date
	if ext and AUDIO_EXTS[ext] then
		local dur = self:ffmpeg_duration()
		local br  = self:ffmpeg_bitrate()
		return string.format("%s  %s  %s  %s",
			pad(dur, W_DUR), pad(br, W_BR), size_col, date_col)
	end

	-- Scripts/executables (not folders): chmod  size  date
	if not cha.is_dir then
		local perm = cha:perm() or ""
		local is_exec = #perm >= 4 and perm:sub(4, 4) == "x"
		local is_script = ext and SCRIPT_EXTS[ext]
		if (is_exec or is_script) and perm ~= "" then
			return string.format("%s  %s  %s",
				pad(perm, W_PERM), size_col, date_col)
		end
	end

	-- Folders and regular files: size  date
	return string.format("%s  %s", size_col, date_col)
end
