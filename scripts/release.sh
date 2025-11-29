#!/bin/bash

set -euo pipefail

refresh_tmp() {
	mkdir -p tmp
	mkdir -p tmp_keep
	__keep_tmp_dirs() {
		local dir
		for dir in "${@}"
		do
			if [ -d "tmp/$dir" ]
			then
				mv "tmp/$dir" "tmp_keep/$dir"
			fi
		done
	}
	__keep_tmp_dirs maps
	rm -rf tmp/*
	if [ ! -z "$(ls tmp_keep)" ]
	then
		mv tmp_keep/* tmp
	fi
	rm -rf tmp_keep
}

get_map_bundle() {
	cd tmp
	if [ ! -d maps ]
	then
		git clone https://github.com/ddnet-insta/maps
	else
		cd maps
		git pull
		cd ..
	fi
	cd ..
}

# expects a github CI built
# release archive named
# ddnet-windows-latest.zip
# in the current directory
#
# and will include the ddnet-insta map bundle
# and remove the client stuff
patch_windows_zip() {
	if [ ! -f ddnet-windows-latest.zip ]
	then
		echo "Error: missing file ddnet-windows-latest.zip"
		echo "       get it from the github CI"
		exit 1
	fi

	cp ddnet-windows-latest.zip tmp
	pushd tmp
	{
		unzip ddnet-windows-latest.zip
		rm ddnet-windows-latest.zip
		unzip ./DDNet-*.zip
		rm ./DDNet-*.zip

		mv ./DDNet-*/ ddnet-insta-windows

		cd ./ddnet-insta-windows
		{
			# TODO: place some sample autoexec_server.cfg here

			# TODO: remove more dll's needed only by the client
			rm libogg.dll libfreetype.dll libopusfile.dll libpng16-16.dll
			rm vulkan-1.dll avcodec-*.dll avformat-*.dll avutil-*.dll
			rm SDL2.dll

			rm DDNet.exe
			rm dilate.exe
			rm demo_extract_chat.exe

			pushd data
			{
				rm ./*.png
				rm touch_controls.json
				rm autoexec_server.cfg
				rm -rf ./{maps,maps7,mapres,skins,skins7}/
				rm -rf ./{editor,assets,audio,fonts,shader}
				rm -rf ./{countryflags,communityicons}/
				rm -rf ./{languages,themes,menuimages}/

				# map bundle
				# https://github.com/ddnet-insta/maps
				cp -r ../../maps/maps .
				cp -r ../../maps/maps7 .
			}
			popd # data
		}
		cd .. # ddnet-insta-windows

		zip -r ddnet-insta-windows.zip ddnet-insta-windows
		rm -rf ddnet-insta-windows
	}
	popd # tmp
}

# expects a github CI built
# release archive named
# ddnet-ubuntu-latest.zip
# in the current directory
#
# and will include the ddnet-insta map bundle
# and remove the client stuff
patch_linux_zip() {
	if [ ! -f ddnet-ubuntu-latest.zip ]
	then
		echo "Error: missing file ddnet-ubuntu-latest.zip"
		echo "       get it from the github CI"
		exit 1
	fi

	cp ddnet-ubuntu-latest.zip tmp
	pushd tmp
	{
		unzip ddnet-ubuntu-latest.zip
		rm ddnet-ubuntu-latest.zip
		tar xvf ./DDNet-*.tar.xz
		rm ./DDNet-*.tar.xz

		mv ./DDNet-*/ ddnet-insta-linux

		cd ./ddnet-insta-linux
		{
			# TODO: place some sample autoexec_server.cfg here

			rm DDNet
			rm dilate
			rm demo_extract_chat

			pushd data
			{
				rm ./*.png
				rm touch_controls.json
				rm autoexec_server.cfg
				rm -rf ./{maps,maps7,mapres,skins,skins7}/
				rm -rf ./{editor,assets,audio,fonts,shader}
				rm -rf ./{countryflags,communityicons}/
				rm -rf ./{languages,themes,menuimages}/

				# map bundle
				# https://github.com/ddnet-insta/maps
				cp -r ../../maps/maps .
				cp -r ../../maps/maps7 .
			}
			popd # data
		}
		cd .. # ddnet-insta-linux

		zip -r ddnet-insta-linux.zip ddnet-insta-linux
		rm -rf ddnet-insta-linux
	}
	popd # tmp
}

# expects a github CI built
# release archive named
# ddnet-macOS-latest.zip
# in the current directory
#
# and will include the ddnet-insta map bundle
# and remove the client stuff
patch_macos_zip() {
	if [ ! -f ddnet-macOS-latest.zip ]
	then
		echo "Error: missing file ddnet-macOS-latest.zip"
		echo "       get it from the github CI"
		exit 1
	fi

	# TODO: implement
	cp ddnet-macOS-latest.zip tmp/ddnet-insta-macOS.zip
}

add_html_links() {
	echo "[*] There are now new zip files in the tmp/ directory"
	echo "[*] upload them here https://github.com/ddnet-insta/ddnet-insta/releases"
	echo "[*] then patch something like this in index.html:"
	echo ""
	cat <<-EOF
	  <a href="https://github.com/ddnet-insta/ddnet-insta/releases/download/v1.7/ddnet-insta-windows.zip">Windows</a>
	  <a href="https://github.com/ddnet-insta/ddnet-insta/releases/download/v1.7/ddnet-insta-macOS.zip">macOS</a>
	  <a href="https://github.com/ddnet-insta/ddnet-insta/releases/download/v1.7/ddnet-insta-linux.zip">Linux</a>
	EOF
}

refresh_tmp
get_map_bundle
patch_windows_zip
patch_linux_zip
patch_macos_zip
add_html_links
