pkg=pfx
version=92d3d9d1a4
rev=1
style=fetch
maintainer='Kyle Nusbaum <knusbaum@sdf.org>'
description='fast parallel file copy'
noarch=true

files='http://code.a-b.xyz/bin.rc/plain/bin/pfx?id=92d3d9d1a431f20df9ce8d3d42ac7fb428281a01'
sums='02d891b3840757f2c89a0c9afa4e8a0dc7312a08'


fn install {
	#hget 'http://code.a-b.xyz/bin.rc/plain/bin/pfx?id=92d3d9d1a431f20df9ce8d3d42ac7fb428281a01' >/rc/bin/pfx
	name=`{basename $files}
	cp $fcache/$name /rc/bin/pfx
}
