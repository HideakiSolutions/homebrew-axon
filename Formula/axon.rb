class Axon < Formula
  desc "Context engine for AI coding agents — token-efficient code indexing and retrieval"
  homepage "https://github.com/HideakiSolutions/axon"
  license "MIT"
  version "0.5.6"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/HideakiSolutions/axon-releases/releases/download/v0.5.6/axon-0.5.6-macos-arm64.tar.gz"
      sha256 "e50d90272bb2eec7b642960cbd047b5f3093632591b1f00104308f3293d9a7ea"
    else
      odie "axon does not ship a macOS x86_64 binary yet. Build from source: https://github.com/HideakiSolutions/axon"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/HideakiSolutions/axon-releases/releases/download/v0.5.6/axon-0.5.6-linux-x64.tar.gz"
      sha256 "7568326a314c22ba7d8155752ef092daa82d77a9807c55f600d2621850c59a85"
    else
      odie "axon does not ship a Linux arm64 binary yet. Build from source: https://github.com/HideakiSolutions/axon"
    end
  end

  def install
    # Install binary + library into libexec to keep libduckdb private
    libexec.install "bin", "lib", "README.md", "LICENSE", "CHANGELOG.md"

    # macOS: fix @rpath so axon finds @rpath/libduckdb.dylib at runtime
    if OS.mac?
      system "install_name_tool", "-add_rpath", "#{libexec}/lib", "#{libexec}/bin/axon"
    end

    # Wrapper script — sets LD_LIBRARY_PATH for Linux (macOS uses rpath above)
    (bin/"axon").write <<~BASH
      #!/bin/bash
      export LD_LIBRARY_PATH="#{libexec}/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      exec "#{libexec}/bin/axon" "$@"
    BASH
    chmod 0755, bin/"axon"

    # axon-setup: wrapper for the project-setup script (wires Claude Code hooks)
    libexec.install "install.sh"
    (bin/"axon-setup").write <<~BASH
      #!/bin/bash
      export AXON_BIN="#{libexec}/bin/axon"
      export AXON_LIB="#{libexec}/lib"
      exec bash "#{libexec}/install.sh" "$@"
    BASH
    chmod 0755, bin/"axon-setup"
  end

  test do
    system "#{bin}/axon", "help"
  end
end
