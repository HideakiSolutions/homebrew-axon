class Axon < Formula
  desc "Context engine for AI coding agents — token-efficient code indexing and retrieval"
  homepage "https://github.com/HideakiSolutions/axon"
  license "MIT"
  version "0.5.8"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/HideakiSolutions/axon-releases/releases/download/v0.5.8/axon-0.5.8-macos-arm64.tar.gz"
      sha256 "b8f4f4f0aebd9df6ead292ec031baf809bfe673e41d1d84e991a4927a11cd61a"
    else
      odie "axon does not ship a macOS x86_64 binary yet. Build from source: https://github.com/HideakiSolutions/axon"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/HideakiSolutions/axon-releases/releases/download/v0.5.8/axon-0.5.8-linux-x64.tar.gz"
      sha256 "1e81a9d8c458dc35d9b23f16f408ef3f78ff42863552ab3475ed75dad26b253b"
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
