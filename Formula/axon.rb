class Axon < Formula
  desc "Context engine for AI coding agents — token-efficient code indexing and retrieval"
  homepage "https://github.com/HideakiSolutions/axon"
  license "MIT"
  version "0.5.7"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/HideakiSolutions/axon-releases/releases/download/v0.5.7/axon-0.5.7-macos-arm64.tar.gz"
      sha256 "e17747f5e04884ff555bd83bde1db6e5c6f7d29c06a26284929525854e0e86aa"
    else
      odie "axon does not ship a macOS x86_64 binary yet. Build from source: https://github.com/HideakiSolutions/axon"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/HideakiSolutions/axon-releases/releases/download/v0.5.7/axon-0.5.7-linux-x64.tar.gz"
      sha256 "78f8def76fbaa42c9420cf01b005ae88f22a38d89718378d618f861d68cd8d67"
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
