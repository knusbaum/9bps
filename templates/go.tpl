pkg=go
version=1.13.10
#version=1.14.2
rev=1
style=mk
wrksrc='go-go1.13.10'
maintainer='Kyle Nusbaum <knusbaum@sdf.org>'
description='the Go programming language'

## Unfortunately, the way I'm building go currently is to
## use a go bootstrap tarball that was cross compiled on 
## FreeBSD. This was build for amd64, and so to bootstrap
## go, we need to build the initial packages on amd64.
## Go *should* still be able to be build on other arches,
## but will depend on an existant go package for
## bootstrapping.
##
## Supposedly go1.4.3 can be built on plan9 and used for
## bootstrapping, but I always run into panics when building
## on amd64, even with the SMP patch. Maybe someone else
## has had better luck, in which case please submit a patch
## for this template.
if(~ $cputype amd64) {
	hostmakedeps=(go-plan9-amd64-bootstrap)
}
if not {
	hostmakedeps=(go)
}

files='https://github.com/golang/go/archive/go1.13.10.tar.gz'
sums='5c3ddb360c50fb79c16edb673c6a7670808af251'

fn build {
	echo BUILDING GO
	cd $wrksrc/src
	GOROOT_FINAL=/sys/lib/go GOROOT_BOOTSTRAP=/sys/lib/go ./make.rc
}

fn install {
	mkdir /sys/lib/go
	cd ..
	dircp $wrksrc /sys/lib/go
	cp /sys/lib/go/bin/go /$objtype/bin/
}