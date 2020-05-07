pkg=pkg
version=96915d1032
rev=1
style=extract
wrksrc='pkg-96915d1032aff66ea947deaf9a21c0e1594c5076'
maintainer='Kyle Nusbaum <knusbaum@sdf.org>'
description='packaging tools for 9bps '
noarch=true

files='https://github.com/knusbaum/pkg/archive/96915d1032aff66ea947deaf9a21c0e1594c5076.tar.gz'
sums='a06cbec2813551d7f65c7d2c2d058eecedda67c4'

fn deps {}

fn install {
	mkdir /rc/bin/pkg
	dircp pkg /rc/bin/pkg
}
