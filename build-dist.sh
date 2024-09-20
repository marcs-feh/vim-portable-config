
distRoot="mf-vim"

PKGS="
	tpope/vim-commentary
	tpope/vim-repeat
	tpope/vim-surround
	tpope/vim-fugitive
	marcs-feh/vim-compile
	marcs-feh/udark.vim
	junegunn/vim-easy-align
"
set -eu

FetchPlugins(){
	mkdir -p plugins
	cd plugins

	for pkg in $PKGS; do
		pkg="$(echo $pkg | sed -E 's/\s*//g')"
		[ -z "$pkg" ] || {
			pkgDir="$(basename "$pkg")"
			[ -d "$pkgDir" ] || {
				echo "    Downloading $pkg ..."
				git clone --quiet --depth=1 "https://github.com/$pkg"
			}

			cd "$pkgDir"
			git pull --quiet
			cd ..
		} &
	done

	wait
	cd ..
}

UnpackPlugins(){
	rootFolder="$distRoot/start"

	mkdir -p "$rootFolder"
	for pkg in $PKGS; do
		pkg="$(echo $pkg | sed -E 's/\s*//g')"
		[ -z "$pkg" ] || {
			pkgDir="$(basename "$pkg")"
			anchor="$(pwd)"

			mkdir -p "$distRoot/start/$pkgDir"
			cd "plugins/$pkgDir"
			git archive HEAD --format=zip > "$anchor/$distRoot/start/$pkgDir/plugin.zip"
			cd "$anchor/$distRoot/start/$pkgDir"
			unzip -q plugin.zip
		} &
	done
	wait
}

CleanFiles(){
	cleanup="$(find $distRoot \
		-name '*.zip' -o \
		-name '*.gif' -o \
		-name '*.png' -o \
		-name '*.jpg' -o \
		-name '*.webp' -o \
		-name '*.yml' -o \
		-name '*.markdown' -o \
		-name 'CONTRIBUTING.*' -o \
		-name '.github'
	)"

	rm -rf $cleanup
}


rm -rf "$distRoot" vim-config.zip .vimrc .vim

echo 'Downloading plugins with git'
FetchPlugins

echo 'Unpacking'
UnpackPlugins

echo 'Cleaning files'
CleanFiles

mkdir -p .vim/pack
mkdir -p .vim/colors

cp _vimrc .vimrc &
cp -r "$distRoot" .vim/pack &
wait

echo 'Generating zip archive'
zip -q -r -9 vim-config.zip .vimrc .vim
echo 'Generating base64 encoded zip archive'
base64 -w 0 vim-config.zip > vim-config.zip.txt

rm -rf .vim .vimrc "$distRoot"
