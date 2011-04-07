echo 'Generating tags'
ctags -R --c++-kinds=+p --fields=+iaS --extra=+q
echo 'Generating cscope info'
find . -name '*.h' -o -name '*.c' -o -name '*.C' -o -name '*.hpp' -o -name '*.hxx' -o -name '*.cpp' -o -name '*.java' > cscope.files
cscope -bq
echo 'End'
