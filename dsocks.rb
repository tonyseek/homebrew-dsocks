require 'formula'

class Dsocks < Formula
  desc "SOCKS client wrapper for *BSD/OS X"
  homepage "http://monkey.org/~dugsong/dsocks/"
  url "https://dsocks.googlecode.com/files/dsocks-1.8.tar.gz"
  sha256 "2b57fb487633f6d8b002f7fe1755480ae864c5e854e88b619329d9f51c980f1d"

  conflicts_with "dsocks", :because => "shipped dynamic library is conflict with official formula."

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
diff --git a/dsocks.c b/dsocks.c
--- a/dsocks.c	(revision 12)
+++ b/dsocks.c	(working copy)
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
diff --git a/dsocks.sh b/dsocks.sh
--- a/dsocks.sh	(revision 12)
+++ b/dsocks.sh	(working copy)
@@ -7,7 +7,7 @@
 #export DSOCKS_VERSION="Tor"
 
 # local SOCKS4 proxy server - e.g. ssh -D10080 example.com
-export DSOCKS_PROXY="127.0.0.1:10080"
+#export DSOCKS_PROXY="127.0.0.1:10080"
 
 # internal nameservice
 #export DSOCKS_NAMESERVER="10.0.0.1"
