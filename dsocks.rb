require 'formula'

class Dsocks < Formula
  homepage 'http://monkey.org/~dugsong/dsocks/'
  url 'https://dsocks.googlecode.com/files/dsocks-1.8.tar.gz'
  sha1 'd9d58e0ed6ca766841c94b5d15dd268a967c60bc'

  conflicts_with 'dsocks', :because => "shipped dynamic library is conflict with official formula."

  patch :DATA

  def install
    system "#{ENV.cc} #{ENV.cflags} -shared -o libdsocks.dylib dsocks.c atomicio.c -lresolv"
    inreplace "dsocks.sh", "/usr/local", HOMEBREW_PREFIX

    lib.install "libdsocks.dylib"
    bin.install "dsocks.sh" => "dsocks"
  end
end

__END__

Index: dsocks.c
===================================================================
--- dsocks.c	(revision 12)
+++ dsocks.c	(working copy)
@@ -21,6 +21,7 @@
 # define __DARWIN_LDBL_COMPAT(x) /* nothing */
 #endif
 #include <dlfcn.h>
+#include <fcntl.h>
 #include <err.h>
 #include <errno.h>
 #include <netdb.h>
@@ -212,6 +213,11 @@
 	    IS_LOOPBACK(sa) || oval != SOCK_STREAM) {
 		return ((*_sys_connect)(fd, sa, len));
 	}
+
+	/* Cancel non-block mode to prevent EINPROGRESS while connecting */
+	if (fcntl(fd, F_GETFL, 0) & O_NONBLOCK) {
+		fcntl(fd, F_SETFL, !O_NONBLOCK);
+	}
 	if ((*_sys_connect)(fd, (struct sockaddr *)&_dsocks_sin,
 		sizeof(_dsocks_sin)) == -1) {
 		warnx("(dsocks) couldn't connect to proxy at %s",
Index: dsocks.sh
===================================================================
--- dsocks.sh	(revision 12)
+++ dsocks.sh	(working copy)
@@ -7,7 +7,7 @@
 #export DSOCKS_VERSION="Tor"
 
 # local SOCKS4 proxy server - e.g. ssh -D10080 example.com
-export DSOCKS_PROXY="127.0.0.1:10080"
+#export DSOCKS_PROXY="127.0.0.1:10080"
 
 # internal nameservice
 #export DSOCKS_NAMESERVER="10.0.0.1"
