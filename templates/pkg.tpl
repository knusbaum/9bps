pkg=pkg
version=ce37a5cfbf
rev=1
style=extract
wrksrc='pkg-ce37a5cfbfee96b9e6f5ecd2c8409e40a14ced18'
maintainer='Kyle Nusbaum <knusbaum@sdf.org>'
description='packaging tools for 9bps '
noarch=true

files='https://github.com/knusbaum/pkg/archive/ce37a5cfbfee96b9e6f5ecd2c8409e40a14ced18.tar.gz'
sums='684315117e651f6ebed21302ade8b3dd1fa080f8'

fn deps {}

fn install {
	mkdir /rc/bin/pkg
	dircp pkg /rc/bin/pkg
}
