pkg=unionfs
version=228091978e
rev=1
style=mk
wrksrc='unionfs-228091978e928c07612ede5efd6edcca1ccece38'
maintainer='Kyle Nusbaum <knusbaum@sdf.org>'

files='http://code.a-b.xyz/unionfs/snapshot/unionfs-228091978e928c07612ede5efd6edcca1ccece38.tar.gz'
sums='9b82055fe1eefd5e0ec94b88ad18b892e7c2cfa2'

fn pre_install {
	mkdir -p $home/bin/$objtype
}

fn post_install {
	mkdir -p /$objtype/bin
	mv $home/bin/$objtype/unionfs /$objtype/bin/unionfs
	rm -rf /usr
}

