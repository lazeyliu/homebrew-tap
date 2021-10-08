class Mcaselector < Formula
  desc "A tool to select chunks from Minecraft worlds for deletion or export."
  homepage "https://github.com/toolbox4minecraft/amidst"
  version "1.16.3"
  url "https://github.com/Querz/mcaselector/releases/download/#{version}/mcaselector-#{version}.jar"
  license "GPL-3.0"

  bottle :unneeded

  def install
    pkg_name="mcaselector"
    bin_name="mcaselector"

    mkdir_p "./#{pkg_name}"
    mv Dir["#{bin_name}-*.jar"][0], "./#{pkg_name}/#{bin_name}.jar"
    share.install "#{pkg_name}"

    (buildpath/"#{bin_name.downcase}").write <<~EOS
      #!/bin/sh
      # Pre-compiled with newer (JDK 16)
      # https://stackoverflow.com/a/7334780/5101148
      version=`java -version 2>&1 | head -1 | cut -d '"' -f 2`
      version="${version%%.*}"
      if [ "$version" -lt 16 ]; then
        export JAVA_HOME="#{HOMEBREW_PREFIX}/opt/java"
        /usr/bin/java -jar "#{opt_prefix}/share/#{pkg_name}/#{bin_name}.jar" "$@"
      else
        java -jar "#{opt_prefix}/share/#{pkg_name}/#{bin_name}.jar" "$@"
      fi
    EOS
    bin.install "#{bin_name.downcase}"

    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      mcaselector depends on Java 16 with JavaFX support. Make sure you have them installed.
      https://github.com/Querz/mcaselector
    EOS
  end
end