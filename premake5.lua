assert(os.getenv("LEAP_SDK"), "LEAP_SDK environmental variable not set")

local LEAP_SDK = os.getenv("LEAP_SDK")

solution "gm_leap"
	language "C++"
	location "project"
	targetdir "bin"

	flags { "StaticRuntime" }

	includedirs {
		"include",
		LEAP_SDK .. "/include"
	}

	libdirs {
		LEAP_SDK .. "/lib/x86"
	}
	

	configurations {
		"Debug",
		"Release"
	}

	configuration "Debug"
		flags { "symbols" }

		links {
			"Leapd.lib"
		}

	configuration "Release"
		optimize "On"
		
		links {
			"Leap.lib"
		}
		

	project "gmcl_leap"
		kind "SharedLib"
		
		files {
			"src/**.cpp",
			"src/**.h"
		}

		defines { "GMMODULE" }

		if os.is "windows" then
			targetsuffix "_win32"
		elseif os.is "linux" then
			targetsuffix "_linux"
		elseif os.is "macosx" then
			targetsuffix "_osx"
		end