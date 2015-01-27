pushd %~dp0

7z u -tzip vyzor.mpackage^
 *.lua -r^
 vyzor.trigger^
 license.txt

popd
