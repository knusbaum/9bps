pkg=gobootstrap
version=1.4.3
rev=1
style=mk
wrksrc='go-go1.4.3'
maintainer='Kyle Nusbaum <knusbaum@sdf.org>'
description='Bootstrap code for go'

files='https://github.com/golang/go/archive/go1.4.3.tar.gz'
sums='fc5b37f07357ad2672db4b893529d627b24e3889'

fn build {
	cd $wrksrc/src
	hget http://9legacy.org/go/patch/syscall-exec.diff | ape/patch -p2
	GOROOT_FINAL=/sys/lib/gobootstrap GOOS=plan9 GOARCH=$objtype ./make.rc
}

fn install {
	mkdir /sys/lib/gobootstrap
	cd ..
	dircp $wrksrc /sys/lib/gobootstrap
}
