cask 'oracle-jdk11' do
  version "11.0.9"
  sha256 "d1723d62776b228552f3176946db52a8d8288fa5c4e2714bb361432e6cb2b4dd"

  url "http://download.macromedia.com/pub/coldfusion/java/java#{version.major}/#{version.major}#{version.minor}#{version.patch}/jdk-#{version}_osx-x64_bin.dmg"
  name 'Java Standard Edition Development Kit'
  homepage "https://www.adobe.com/support/coldfusion/downloads.html#additionalThirdPartyInstallers"

  # auto_updates true: JDK does not auto-update
  depends_on macos: '>= :yosemite'

  pkg "JDK #{version}.pkg"

  postflight do
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/Home", '/Library/Java/Home'],
                   sudo: true
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/MacOS", '/Library/Java/MacOS'],
                   sudo: true
    system_command '/bin/mkdir',
                   args: ['-p', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/Home/bundle/Libraries"],
                   sudo: true
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/Home/lib/server/libjvm.dylib", "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents/Home/bundle/Libraries/libserver.dylib"],
                   sudo: true
  end

  uninstall pkgutil: "com.oracle.jdk-#{version}",
            delete:  [
                       "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk/Contents",
                       '/Library/Java/Home',
                       '/Library/Java/MacOS',
                     ],
            rmdir:   "/Library/Java/JavaVirtualMachines/jdk-#{version}.jdk"

  caveats do
    license 'https://www.oracle.com/technetwork/java/javase/terms/license/javase-license.html'
  end
end