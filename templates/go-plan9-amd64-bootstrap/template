pkg=go-plan9-amd64-bootstrap
version=0.0.1
rev=1
style=extract
wrksrc='go-plan9-amd64-bootstrap'
maintainer='Kyle Nusbaum <knusbaum@sdf.org>'
description='Precompiled bootstrap code for go'

files='http://knusbaum.com/go-plan9-amd64-bootstrap.tar.gz'
sums='8b5263c6b8c3b4ce1424af24f53ba7ced2245e03'
arches=(amd64)

fn install {
	mkdir /sys/lib/go
	cd ..
	dircp $wrksrc /sys/lib/go
}
