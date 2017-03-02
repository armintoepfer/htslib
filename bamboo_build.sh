#!/bin/bash -ex
rm -rf htslib-*
type module >& /dev/null || \
. /mnt/software/Modules/current/init/bash
module load gcc/4.9.2
module load zlib/1.2.8
module load ccache/3.2.3

VERSION=${bamboo_buildNumber}
builddir=htslib-${VERSION}
mkdir -p $builddir/include/cram $builddir/lib
make -C htslib \
    prefix=$PWD/$builddir \
    CFLAGS="-fPIC -Wall -O2 -Wno-unused-function -D_GNU_SOURCE -I/mnt/software/z/zlib/1.2.8/include" \
    LDFLAGS="-L/mnt/software/z/zlib/1.2.8/lib -static-libstdc++" \
    PACKAGE_VERSION="1.1" \
    install -j10

# cmake could do this; at any rate we must incorporate the build number so it's unique each time
f=htslib-${VERSION}-bin.tgz
# workaround pbbam dependency on this file
cp htslib/cram/*.h $builddir/include/cram/
rm -f $builddir/lib/libhts.so*
cd htslib-${VERSION}
tar cfz ../$f {include,lib}
cd -

# gradle or maven could do this...
md5sum $f | awk -e '{print $1}' >| ${f}.md5
sha1sum $f | awk -e '{print $1}' >| ${f}.sha1

for ext in "" .md5 .sha1 ; do
  # TODO use https once available
  NEXUS_URL=http://ossnexus.pacificbiosciences.com/repository/maven-releases/pacbio/sat/htslib/htslib/${VERSION}/htslib-${VERSION}-x86_64.tgz${ext}
  curl -fv -n --upload-file $f${ext} ${NEXUS_URL}
done
