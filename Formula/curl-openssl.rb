class CurlOpenssl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "https://curl.haxx.se/download/curl-7.65.2.tar.bz2"
  sha256 "8093398b51e7d8337dac6f8fa6f1f77d562bdd9eca679dff9d9c3b8160ebfd28"

  bottle do
    sha256 "e5c37bd7de02bbf8e493314b7efd2d3581e594640e6757cc0b3224433b9540cf" => :mojave
    sha256 "ebbfb605e86dd445fbd5191f711ef340eb9e150c6c32a986fb65f100a641f9ff" => :high_sierra
    sha256 "5899ccfda83d6592e36609ab8eb993eecf18a2067d265aaa330926ccb9bd7667" => :sierra
  end

  head do
    url "https://github.com/curl/curl.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  option "with-openssl@1.1", "Build with OpenSSL 1.1"

  depends_on "pkg-config" => :build
  depends_on "brotli"
  depends_on "c-ares"
  depends_on "libidn"
  depends_on "libmetalink"
  depends_on "libssh2"
  depends_on "nghttp2"
  depends_on "openldap"
  if build.with?("openssl@1.1")
    depends_on "openssl@1.1"
  else
    depends_on "openssl"
  end
  depends_on "rtmpdump"

  def install
    system "./buildconf" if build.head?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --enable-ares=#{Formula["c-ares"].opt_prefix}
      --with-gssapi
      --with-libidn2
      --with-libmetalink
      --with-librtmp
      --with-libssh2
    ]

    if build.with?("openssl@1.1")
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
      args << "--with-ca-bundle=#{etc}/openssl@1.1/cert.pem"
      args << "--with-ca-path=#{etc}/openssl@1.1/certs"
      args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
    else
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl"].opt_lib}/pkgconfig"
      args << "--with-ca-bundle=#{etc}/openssl/cert.pem"
      args << "--with-ca-path=#{etc}/openssl/certs"
      args << "--with-ssl=#{Formula["openssl"].opt_prefix}"
    end

    system "./configure", *args
    system "make", "install"
    libexec.install "lib/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_predicate testpath/"test.pem", :exist?
    assert_predicate testpath/"certdata.txt", :exist?
  end
end
