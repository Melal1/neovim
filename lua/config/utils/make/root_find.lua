local RootFinder = {}

function RootFinder.FindRoot(StartingPoint, MaxSearchLevels, RootMarkers)
	StartingPoint = StartingPoint or vim.fn.expand("%:p:h")

	if not StartingPoint or StartingPoint == "" then
		return nil, "Invalid starting location"
	end

	if not vim.fn.isdirectory(StartingPoint) then
		return nil, "Starting point is not a directory: " .. StartingPoint
	end

	MaxSearchLevels = MaxSearchLevels or 5
	RootMarkers = RootMarkers or { ".git", "src", "include", "build", "Makefile" }

	local CurrentPath = StartingPoint
	for i = 1, MaxSearchLevels do
		for _, Marker in ipairs(RootMarkers) do
			local MarkerPath = CurrentPath .. "/" .. Marker
			local Stat = vim.loop.fs_stat(MarkerPath)
			if Stat then
				return {
					Path = CurrentPath,
					Marker = Marker,
					Level = i,
				}
			end
		end

		local ParentPath = vim.fn.fnamemodify(CurrentPath, ":h")
		if ParentPath == CurrentPath then
			break
		end
		CurrentPath = ParentPath
	end

	return nil, "No project root found within " .. MaxSearchLevels .. " levels"
end

return RootFinder
