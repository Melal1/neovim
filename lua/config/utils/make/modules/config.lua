---@class MakefileVars
---@field CXX string             -- The C++ compiler command (e.g. "g++" or "clang++")
---@field DEBUGFLAGS string      -- Compiler flags used for debug builds
---@field RELEASEFLAGS string    -- Compiler flags used for release builds
---@field CXXFLAGS string        -- General C++ compiler flags (can refer to DEBUGFLAGS or RELEASEFLAGS)
---@field BUILD_MODE string      -- Build mode (debug/release)
---@field BUILD_DIR string       -- Base build directory name (e.g. build, out, bin)
---@field CC? string             -- (Optional) The C compiler command (e.g. "gcc" or "clang")
---@field CFLAGS? string         -- (Optional) C compiler flags
local Config = {}

Config.DefaultConfig = {
	BuildDir = "./build",
	SourceExtensions = { ".cpp", ".c", ".cc", ".cxx" },
	RootMarkers = { ".git", "src", "include", "build", "Makefile" },
	MaxSearchLevels = 5,
	CacheUseHash = true,
	EnableBackup = false,
	LinkOptions = {}, -- deprecated: link options are stored in the Makefile links block
	MakefileVars = {
		CXX = "g++",
		DEBUGFLAGS = "-std=c++17 -g -O0",
		RELEASEFLAGS = "-std=c++17 -O3 -DNDEBUG",
		CXXFLAGS = "$(DEBUGFLAGS)",
		BUILD_MODE = "debug",
		BUILD_DIR = "./build",
	},
}

return Config
