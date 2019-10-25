class ChinadnsC < Formula
  desc "Port of ChinaDNS to C: fix irregularities with DNS in China"
  homepage "https://github.com/aa65535/ChinaDNS"
  url "https://github.com/aa65535/ChinaDNS/archive/v1.3.3.tar.gz"
  sha256 "74e53af32f8aa2ca7e63697385f12d89a06c486641556cfd8bc3f085d87e55ad"

  head do
    url "https://github.com/aa65535/ChinaDNS.git"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  def install
    system "./autogen.sh" # if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"

    # Move config files from prefix/"share" into etc
    mkdir_p etc/"chinadns"
    cp_r Dir[prefix/"share/*"], etc/"chinadns"
    rm_rf prefix/"share"
  end

  test do
    system "#{bin}/chinadns", "-h"
  end

  def caveats; <<~EOS
    It's not recommended to run ChinaDNS alone. A forwarding DNS server
    with cache support, like dnsmasq or unbound, should put before it.

    Caveat: port 5353 is taken by mDNSResponder. ChinaDNS runs on
    localhost (127.0.0.1), port 5300, balancing traffic across a set of resolvers.
    If you would like to change these settings, edit the plist service file.

    Homebrew services are run as LaunchAgents by current user.
    To make chinadns service work on privileged port, like port 53,
    you need to run it as a "global" daemon in /Library/LaunchAgents.

      sudo cp -f #{plist_path} /Library/LaunchAgents/

    Dont' use `sudo brew services`. This very command will ruin the file perms.
  EOS
  end

  plist_options :manual => "chinadns -c /usr/local/etc/chinadns/chnroute.txt -b 127.0.0.1 -p 5300 -s 114.114.114.114,208.67.222.222#443 -m"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>KeepAlive</key>
        <dict>
            <key>SuccessfulExit</key>
            <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/chinadns</string>
            <string>-c</string>
            <string>#{etc}/chinadns/chnroute.txt</string>
            <string>-b</string>
            <string>127.0.0.1</string>
            <string>-p</string>
            <string>5300</string>
            <string>-s</string>
            <string>114.114.114.114,208.67.222.222#443</string>
            <string>-m</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
    </plist>
  EOS
  end
end
