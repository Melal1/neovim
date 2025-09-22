local Config = {}

Config.DefaultConfig = {
	BuildDir = "./build",
	SourceExtensions = { ".cpp", ".c", ".cc", ".cxx" },
  --TODO: Headers
	RootMarkers = { ".git", "src", "include", "build", "Makefile" },
	MaxSearchLevels = 5,

	MakefileVars = {
		CXX = "g++",
		CXXFLAGS = "-Wall -Wextra -std=c++17",
		BUILD_DIR = "./build",
	},
}

return Config
