class Nettle < Formula
  desc "Low-level cryptographic library"
  homepage "https://www.lysator.liu.se/~nisse/nettle/"
  url "https://www.lysator.liu.se/~nisse/archive/nettle-2.7.1.tar.gz"
  sha1 "e7477df5f66e650c4c4738ec8e01c2efdb5d1211"

  bottle do
    cellar :any
    revision 1
    sha1 "41d80787422ed29f084c147b49e2f7c3a223eded" => :yosemite
    sha1 "89238f83e4f3f18145553d3c442fe022680cbd7b" => :mavericks
    sha1 "8f2a4c261926f2f62e9d8f197a8466a2489b37e0" => :mountain_lion
    sha1 "6c56084887da5b7e99d7c730bf22a68c9af360e9" => :lion
  end

  depends_on "gmp"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"
    system "make"
    system "make", "install"
    system "make", "check"

    # Move lib64/* to lib/ on Linuxbrew
    lib64 = Pathname.new "#{lib}64"
    if lib64.directory?
      lib.mkdir
      system "mv #{lib64}/* #{lib}/"
      rmdir lib64
      inreplace Dir[lib/"pkgconfig/*"], "/lib64", "/lib"
    end
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <nettle/sha1.h>
      #include <stdio.h>

      int main()
      {
        struct sha1_ctx ctx;
        uint8_t digest[SHA1_DIGEST_SIZE];
        unsigned i;

        sha1_init(&ctx);
        sha1_update(&ctx, 4, "test");
        sha1_digest(&ctx, SHA1_DIGEST_SIZE, digest);

        printf("SHA1(test)=");

        for (i = 0; i<SHA1_DIGEST_SIZE; i++)
          printf("%02x", digest[i]);

        printf("\\n");
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lnettle", "-o", "test"
    system "./test"
  end
end
