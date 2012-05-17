#!/bin/bash
#generate tags for VIM plugin
#including ctags, cscope and lookupfile

#usage: ./tags.sh dir
if [ -z "$1" ]; then
    path=$(pwd)
else
    path=$(cd "$1"; pwd)
fi

flist_name=filelist
lookup_name=filenametags
ctags_name=ctags
cscope_name=cscope.out

tmpfile_name=$(mktemp -q)

#1.create list for lookupfile
#The list also will be used for scope and ctags

typelist="h c cc cpp java cxx hpp py js php"

echo "get file list..."

for ty in $typelist; do
    find $path -iname "*.$ty" >> "$flist_name"
done


echo "create lookupfile tags..."

echo -e "!_TAG_FILE_SORTED\t2\t/2=foldercase/" > "$lookup_name"
#for file in $(cat "$flist_name"); do
for file in $(find $path -name "*"); do
    echo -ne "$(basename $file)\t$file\t1\n" >> "$tmpfile_name"
done

cat "$tmpfile_name" | sort -f >> "$lookup_name"


#2.for cscope
echo "create cscope tags..."

cscope -bq -i "$flist_name"


#3.for ctags
echo "create ctags tags..."

ctags -L "$flist_name"


rm -f "$tmpfile_name"
rm -f "$flist_name"
