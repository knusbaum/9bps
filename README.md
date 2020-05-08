# 9bps - 9 Binary Packaging System

This is an experimental prototype for a binary packaging system for Plan 9. It is (clearly) inspired by XBPS.

Currently, the code makes a lot of assumptions about how the host system is set up.
It expects a 9front system, and constructs a new 9front root in `/n/other/usr/$user/bpsroot` to build against.

9bps expects to be checked out onto a 9front system, onto the root FS (not in ramfs/etc.), and have all scripts executed from the checked-out directory. This is an inconvenient restriction that will be fixed. Eventually, the programs/directories will be moved into sensible locations, but that has not happened yet.

Building with 9bps relies on [`unionfs`](http://code.a-b.xyz/unionfs). Unionfs is available for 386 and amd64 through [pkg](https://github.com/knusbaum/pkg)

## Use

### Building Packages

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

## Building procedure

The pkgbuild script goes through a number of stages to produce a `.pkg` file from a template.

### .pkg files
The `.pkg` file is a gzipped tar file (`.tar.gz`) that contains 3 files:
 * meta - a file sourcable by rc that defines several variables like pkg (package name), version (package version), arch (architecture the package is for), description, and maintainer.
 * manifest - a file that contains a list of files *owned* by the package. `pkg/remove` will delete all files listed in the package manifest. In practice so far, this manifest always reflects what is contained in the root.tar file. It may differ in the future in special cases, for example if root.tar installs a default config and we don't want to delete that config on `pkg/remove`. The config file will exist in root.tar, but won't be in manifest, and therefore not *owned* by the package and not removed by `pkg/remove`. It remains to be seen whether this is a good idea or not. Side note: We may want a `pkg/nuke` that will remove everything installed by root.tar, not just what is in the manifest.
 * root.tar - the file containing the package's contents. This tarball is meant to be unpacked or unioned with /.

### Template 
A template consists of a directory named after the package in the `templates` directory, e.g. `templates/$pkgname/`

There may be 3 members of this directory:
* `template` - File describing how to build the package
* `files` - Directory containing extra files required to build the package. (should contain mostly small things such as a mkfile or config. Should not contain things like source tarballs.)
* `patches` - Directory containing patches which will be automatically applied to the extracted source. (see Stages)

The only file **required** for a template is the rc-readable file named `template`: `templates/$pkgname/template`. This file is readable by rc, and needs to define the following variables:

#### Required Variables
* `pkg` - Just the package name.
* `version` - Version of the thing we're packaging. Currently must match `[a-zA-Z0-9.]+`
* `rev` - Revision of the package (basically a version of the package. Can bump the revision without needing a new `$version`)
* `style` - The style of the package being built. One of `styles/*` except for `base`. Style defines how the package is built and installed. For example, the `mk` style will run `mk all` for the build stage and `mk install` for the install stage.
* `maintainer` - The name and email of whoever is responsible for maintaining the package.
* `description` - a short description of what the package contains.
* `files` - A list or single string containing artifacts for the package. 
* `sums` - A list or single string containing the `sha1` sum(s) of `$files`. `sha1 $files(n) == $sums(n)`

#### Optional Variables
Additional variables are optional, but may be required to get a package to build:

* `wrksrc` - Top-level directory in the source artifact. Defaults to `$pkg-$version`.
	In the case that you have only one source artifact in `$files`, 9bps will try to extract that artifact if it is a tarball or zip file (See the extract stage below), expecting the package source to be in there. By default, 9bps expects the source artifact to extract into a directory named `$pkg-$version`. This is a comman pattern, but not always the case. If your source artifact has a different top-level directory, set `wrksrc=[my-source-tarball-top-directory]` in the template. See [`templates/spin/template`](templates/spin/template) for an example of defining `wrksrc`.
* `arches` - A list containing the set of arches the package will build for. Useful if the package will only build for a subset of the architectures that 9front runs on. If not defined, 9bps assumes it will build for all arches.
* `noarch` - If defined at all, it marks this package as architecture-independent, meaning it contains no architecture-specific files. Useful, for example, for packages containing only rc scripts.
* `hostmakedeps` - A list of packages that the host needs to have installed in order to build the package. (`objtype=$cputype pkg/install`) These will be built if necessary, and installed into an overlay on bpsroot before the build is run.
* `makedeps` - A list of packages that the host needs to have installed *in the target architecture* in order to build the package. (`pkg/install`) **This is not currently working**
* `dependencies` - A list of packages that the package depends on at runtime, which need to be installed on any system that installs this package. **This is not currently working**

The template may also define functions that will be called during the various stages. They are described in the Stages section.

#### Variables defined or used by 9bps
In the template, many rc variables are available. Some will be useful others not.
* `objtype` - This is the usual `objtype`. It will hold the architecture of the target machine.
* `fcache` - Directory that holds the artifact cache.
* `builddir` - Directory where artifacts are copied and/or unpacked. `$wrksrc` is expected to be in `$builddir`.
* `installdir` - Directory which gets overlaid on root during the install stage. This eventually gets packed into `root.tar`.
* `filesdir` - Directory from `templates/$pkg/files` See [`templates/spin/files`](templates/spin/files)
* `patchdir` - Directory from `templates/$pkg/patches` See [`templates/spin/patches`](templates/spin/patches)

The combination of these with the template definition can lead to interesting results. For example, dependencies can be conditionally defined for cross-compilation:

```
if(~ $cputype $objtype) {
	hostmakedepends=(some-dependency)
}
if not {
	hostmakedepends=(different-dependency)
}
```

### Stages 

Every package goes through the same stages, but what happens in the stages differs based on the "style" of build. (see styles directory). Stages can be overridden as necessary in the templates.

Each stage is defined by an rc function. named after that stage. For example, the `build` stage is done by an rc function named `build`.
Each stage (say $stage) also has a pre_$stage and post_$stage. These are **always** empty functions ready to be overridden by user templates. To add a pre_build stage, define `fn pre_build { ... }` in the template.

For every stage, first pre_$stage is run, then $stage, then post_$stage. If any function fails, the entire pkgbuild should fail.

Each build goes through these stages in order:
1. fetch - If not already present, pulls artifacts described by the template into the cache and verifies their checksums.
2. deps - Looks at `$hostmakedeps` (and in the future `$makedeps` and `$dependencies`) and installs what is required to build.
3. extract - If the template defines a single artifact, attempt to extract that artifact. Currently extract handles `.tar`, `.tgz`, `.tar.gz` and `.zip` files, although `.zip` is discouraged since plan 9 unzip does not seem to preserve permissions.
4. patch - if there is a `templates/$pkg/patches` directory, every file in that directory is applied with `ape/patch -p 0 -u -i $patchfile` against `$builddir/$wrksrc` if it exists, else against `$builddir`. Patches should be created with `ape/diff -u`
5. build - This stage should do the actual building of the installable artifacts (e.g. `mk all` with `style=mk`)
6. install - This stage should install the package artifacts. They can be installed on the root / as you would on a live system. `$installdir` is unioned over the root, and catches all the files which are installed. One issue here is that if the file already exists in bpsroot (as is the case for the spin package), then you will get permission denied errors. In that case, the files must be manually installed to `$installdir`. I hope this can be solved by adding a "copy-on-write" feature to unionfs.
7. normalize - This stage should validate and normalize the file tree in `$installdir`. Currently it does nothing.
8. package - This stage builds the `.pkg` file out of `$installdir`.

## installing packages

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

## TODO

* Make `makedeps` and `dependencies` work. `dependencies` should go into the `.pkg` meta and be picked up by `pkg/install`
* Write `go` style
* Write more templates to exercise code and find bugs

## Warning
This is basically an experiment designed to explore how to build and package software on Plan 9.

All of this is changing quickly, makes assumptions about your system. It is software designed to build, install, and remove other software, and so bugs can really mess up a system. Please use at your own risk.

