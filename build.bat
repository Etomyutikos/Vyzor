pushd %~dp0

7z u -tzip vyzor.mpackage^
 *.lua -r^
 vyzor.trigger^
 license.txt

mkdir d:\dev\doc\github.com\oneymus\vyzor
ldoc ./ -p Vyzor -d d:\dev\doc\github.com\oneymus\vyzor

popd
