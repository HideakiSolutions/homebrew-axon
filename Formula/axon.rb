class Axon < Formula
  desc "Local-first context engine and agentic memory for AI coding agents"
  homepage "https://github.com/HideakiSolutions/axon"
  license "MIT"
  version "1.2.11"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/HideakiSolutions/axon-releases/releases/download/v1.2.11/axon-1.2.11-macos-arm64.tar.gz"
      sha256 "7fe40406f3b8d917b45d43c013b97c5b8d3925cc3fc659df1d72528781239fcc"
    else
      odie "axon does not ship a macOS x86_64 binary yet. Build from source: https://github.com/HideakiSolutions/axon"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/HideakiSolutions/axon-releases/releases/download/v1.2.11/axon-1.2.11-linux-x64.tar.gz"
      sha256 "c9df31362862c2746971214ddc33a202270eedb46797609069d24ab7ebd863ee"
    else
      odie "axon does not ship a Linux arm64 binary yet. Build from source: https://github.com/HideakiSolutions/axon"
    end
  end

  def install
    # Install the package into libexec to keep libduckdb/llama private.
    # hooks/ and templates/ are consumed by install.sh (axon-setup below).
    libexec.install "bin", "lib", "hooks", "templates", "README.md", "LICENSE", "CHANGELOG.md"

    # macOS: releases since v1.2.1 ship @rpath dylibs; add the brew layout's
    # lib dir explicitly so the relocated binary always resolves them.
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

    # axon-setup: project setup (downloads the embedding model, registers the
    # MCP server with Claude Code, wires the hooks)
    libexec.install "install.sh"
    (bin/"axon-setup").write <<~BASH
      #!/bin/bash
      export AXON_BIN="#{libexec}/bin/axon"
      export AXON_LIB="#{libexec}/lib"
      exec bash "#{libexec}/install.sh" "$@"
    BASH
    chmod 0755, bin/"axon-setup"
  end

  def caveats
    <<~EOS
      The semantic-search embedding model (~80 MB) is not bundled. Run
        axon-setup
      once to download it, register the MCP server with Claude Code, and wire
      the project hooks — or place the model under ~/.axon/models/ manually.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/axon --version")
    system "#{bin}/axon", "help"
  end
end
