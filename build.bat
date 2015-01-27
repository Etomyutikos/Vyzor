pushd %~dp0

7z u -tzip vyzor.mpackage^
 *.lua -r^
 vyzor.trigger^
 license.txt

mkdir f:\projects\dev\doc\github.com\oneymus\vyzor\doc
ldoc ./ -p Vyzor -d f:\projects\dev\doc\github.com\oneymus\vyzor\doc

popd
