
ROOT="vim-cool"

PKGS="
	tpope/vim-commentary
	tpope/vim-repeat
	tpope/vim-surround
	tpope/vim-fugitive
	marcs-feh/vim-compile
	junegunn/vim-easy-align
"
set -eu

FetchPlugins(){
	mkdir -p plugins
	cd plugins

	for pkg in $PKGS; do
		pkg="$(echo $pkg | sed -E 's/\s*//g')"
		[ ! -z "$pkg" ] \
			&& git clone --quiet --depth=1 "https://github.com/$pkg" &
	done

	wait

	for repo in $(ls .); do
		cd "$repo"
		git archive HEAD --format=zip > "../../$repo.zip"  &
		cd ..
	done

	wait

	cd ..
	wget -q https://raw.githubusercontent.com/marcs-feh/udark.vim/main/udark.vim -O udark.vim &
	rm -rf plugins
	wait
}

UnpackPlugins(){
	rootFolder="$ROOT/start"

	mkdir -p "$rootFolder"
	for f in *.zip; do
		{
			dirname="$(echo $f | sed 's/.zip//g')"
			mkdir -p "$rootFolder/$dirname"
			mv "$f" "$rootFolder/$dirname"
			cd "$rootFolder/$dirname"
			unzip -q "$f"
			cd ..
		} &
	done
	wait
}

CleanFiles(){
	cleanup="$(find $ROOT \
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


[ -d "$ROOT" ] || {
	echo 'Downloading plugins with git'
	FetchPlugins
	echo 'Unpacking'
	UnpackPlugins
	echo 'Cleaning files'
	CleanFiles
}

mkdir -p .vim/pack
mkdir -p .vim/colors

cp _vimrc .vimrc
cp udark.vim .vim/colors
cp -r "$ROOT" .vim/pack

echo 'Generating zip archive'
zip -q -r -9 vim-config.zip .vimrc .vim
echo 'Generating base64 encoded zip archive'
base64 -w 0 vim-config.zip > vim-config.zip.txt

rm -rf .vim .vimrc
