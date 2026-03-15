require("folder-rules"):setup()

require("mime-ext.local"):setup({
	with_exts = {
		epub = "application/epub+zip",
	},
	fallback_file1 = true,
})

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
	mp3 = true,
	flac = true,
	wav = true,
	m4a = true,
	ogg = true,
	aac = true,
	wma = true,
	opus = true,
	ape = true,
	alac = true,
	aiff = true,
	dsf = true,
	dff = true,
}

local SCRIPT_EXTS = {
	sh = true,
	bash = true,
	zsh = true,
	fish = true,
	py = true,
	rb = true,
	pl = true,
	lua = true,
}

-- Column widths
local W_DUR = 8 -- "00:03:42"
local W_BR = 8 -- "320kbps"
local W_SIZE = 8 -- "3.2 MiB"
local W_PERM = 10 -- "rwxr-xr-x"
local W_DATE = 10 -- "2024-03-10"
local W_TYPE = 6 -- "pdf", "flac", "dir"

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

	local type_col = pad(cha.is_dir and "" or (ext or ""), W_TYPE)

	-- Music: length  bitrate  type  size  date
	if ext and AUDIO_EXTS[ext] then
		local dur = self:ffmpeg_duration()
		local br = self:ffmpeg_bitrate()
		return string.format("%s  %s  %s  %s  %s", pad(dur, W_DUR), pad(br, W_BR), type_col, size_col, date_col)
	end

	-- Scripts/executables (not folders): chmod  type  size  date
	if not cha.is_dir then
		local perm = cha:perm() or ""
		local is_exec = #perm >= 4 and perm:sub(4, 4) == "x"
		local is_script = ext and SCRIPT_EXTS[ext]
		if (is_exec or is_script) and perm ~= "" then
			return string.format("%s  %s  %s  %s", pad(perm, W_PERM), type_col, size_col, date_col)
		end
	end

	-- Folders and regular files: type  size  date
	return string.format("%s  %s  %s", type_col, size_col, date_col)
end

-- Helpers for RTL (Hebrew/Arabic) display correction
local function has_rtl(s)
	for _, cp in utf8.codes(s) do
		if
			(cp >= 0x0590 and cp <= 0x05FF) -- Hebrew
			or (cp >= 0xFB1D and cp <= 0xFB4F) -- Hebrew presentation forms
		then
			return true
		end
	end
	return false
end

local MIRROR = { [40] = 41, [41] = 40, [91] = 93, [93] = 91, [123] = 125, [125] = 123 }
-- 40/41 = (/)  91/93 = [/]  123/125 = {/}

local function reverse_utf8(s)
	local chars = {}
	for _, cp in utf8.codes(s) do
		table.insert(chars, 1, utf8.char(MIRROR[cp] or cp))
	end
	return table.concat(chars)
end

-- Override Entity:highlights() to:
--   1. Strip file extension (shown in type column instead)
--   2. Fix RTL filenames (Hebrew/Arabic) which appear reversed in LTR terminals
local orig_highlights = Entity.highlights
function Entity:highlights()
	local stem = self._file.url.stem
	local name = self._file.name
	local display = (stem and stem ~= "" and stem ~= name) and stem or name

	local p = ui.printable

	-- RTL text: reverse codepoints for correct visual order in LTR terminal
	if has_rtl(display) then
		return p(reverse_utf8(display))
	end

	-- No extension to strip: delegate to original (handles highlights correctly)
	if display == name then
		return orig_highlights(self)
	end

	-- Has extension: render stem with highlights clamped to stem length
	local hl = self._file:highlights()
	if not hl or #hl == 0 then
		return p(display)
	end
	local stem_len = #display
	local spans, last = {}, 0
	for _, h in ipairs(hl) do
		if h[1] >= stem_len then
			break
		end
		local h2 = math.min(h[2], stem_len)
		if h[1] > last then
			spans[#spans + 1] = p(display:sub(last + 1, h[1]))
		end
		spans[#spans + 1] = ui.Span(p(display:sub(h[1] + 1, h2))):style(th.mgr.find_keyword)
		last = h2
	end
	if last < stem_len then
		spans[#spans + 1] = p(display:sub(last + 1))
	end
	return ui.Line(spans)
end
