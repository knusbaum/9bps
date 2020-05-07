# 9bps - 9 Binary Packaging System

This is an experimental prototype for a binary packaging system for Plan 9.

Currently, the code makes a lot of assumptions about how the host system is set up.
It expects a 9front system, and constructs a new 9front root in `/n/other/usr/$user/bpsroot` to build against.

9bps expects to be checked out onto a 9front system, onto the root FS (not in ramfs/etc.), and have all scripts executed from the checked-out directory. This is an inconvenient restriction that will be fixed. Eventually, the programs/directories will be moved into sensible locations, but that has not happened yet.

Building with 9bps relies on [`unionfs`](http://code.a-b.xyz/unionfs)

## Use

### building packages

First, configure which arches you want to build for in the `arches` file.
The bpsroot will be constructed so that it can build against the arches listed there. By default it
sets up bpsroot to build for `$cputype` and `386`. Arches can be added later with `rootaddarch`.

After that, you should be able to run `mkroot`. This can take a while if your system is slow, or you
have selected a lot of arches. `mkroot` requires `/n/other/usr/$user` to exist. Running `mkroot` again
will recreate the bpsroot.

After bpsroot is created with `mkroot`, packages can be build under that root. The packages will
be installed into `pkg/$objtype` in the 9bps directory. Packages are built from templates under `templates`.
You should be able to add your own package templates under `templates`. Please use the existing templates in `templates` as examples. Currently 9bps only supports building with `mk`, or fetching files to install.

A package can be built with `pkgbuild [package name]`.

If you want to build a package for another arch, set objtype before calling pkgbuild, e.g. building `clone` for `arm64`:
```
objtype=arm64 pkgbuild clone
```
(your bpsroot must be set up to build against the objtype.)

If you want to build all packages for all arches listed in the `arches` file, run `buildall`.

### installing packages

Installation can be done with the [`pkg` scripts](https://github.com/knusbaum/pkg). The `pkg` directory constructed by `pkgbuild` is suitable for mounting over `/n/pkg`

## Updating bpsroot

The first run of `mkroot` will `hg clone` the 9front repo into `/n/other/usr/$user/bpsrootsrc`
and then copy that into `/n/other/usr/$user/bpsroot`. Subsequent runs of `mkroot` will copy from the
existing `/n/other/usr/$user/bpsrootsrc`.

To get an updated root, update the hg repo in `/n/other/usr/$user/bpsrootsrc.` and then run `mkroot`.

## Full example use
```
git9/clone git://github.com/knusbaum/9bps
cd 9bps
mkroot
pkgbuild clone
bind pkg /n/pkg
pkg/install clone
## use clone
pkg/remove clone
```

## Warning
All of this is changing quickly, makes assumptions about your system. It is software designed to build, install, and remove other software, and so bugs could really mess up a system. Please use at your own risk.

