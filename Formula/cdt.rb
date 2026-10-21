class Cdt < Formula
  desc "Directory tags and native zsh navigation"
  homepage "https://github.com/JieteXue/cdt"
  license "MIT"

  depends_on :macos

  on_arm do
    url "https://github.com/JieteXue/cdt/releases/download/v0.3.1/cdt_0.3.1_darwin_arm64.tar.gz"
    sha256 "4ec65a6722de9b59cbc33865ce02abcbe726c66b607fe30c01c00f4e26ad532c"
  end

  on_intel do
    url "https://github.com/JieteXue/cdt/releases/download/v0.3.1/cdt_0.3.1_darwin_amd64.tar.gz"
    sha256 "4f6c57c84c5700300dbbc9445a2e0f77a4052d9bcaac09dcc794345d1194890c"
  end

  def install
    bin.install "cdt"
  end

  def caveats
    <<~EOS
      Enable cdt in zsh after your existing completion setup:
        eval "$(command cdt init zsh)"

      Add the line to ~/.zshrc to enable it in future sessions.
      Installation does not modify your shell configuration.
    EOS
  end

  test do
    assert_match Hardware::CPU.arch.to_s, shell_output("/usr/bin/file #{bin}/cdt")
    assert_match "cdt #{version}", shell_output("#{bin}/cdt --version")
    project = testpath/"project with spaces"
    project.mkpath
    ENV["XDG_CONFIG_HOME"] = (testpath/"config").to_s
    ENV["CDT_TEST_PATH"] = project.realpath.to_s
    ENV.prepend_path "PATH", bin

    system bin/"cdt", "-ap", project, "work"
    repeated = shell_output("#{bin}/cdt -ap #{project.to_s.shellescape} work work")
    assert_match "unchanged", repeated
    assert_match "Already present (skipped): [work]", repeated
    assert_match "Repeated input (ignored): [work]", repeated
    assert_match project.realpath.to_s, shell_output("#{bin}/cdt -l work")
    child = project/"api"
    child.mkpath
    system bin/"cdt", "-ap", child, "api"
    assert_match "\u2514\u2500\u2500 api  [api]", shell_output("#{bin}/cdt -l")
    assert_match "#{child.realpath}  [api]", shell_output("#{bin}/cdt -l work api")
    system bin/"cdt", "-dp", child
    system "/bin/zsh", "-fc",
           'eval "$(command cdt init zsh)"; cdt work; [[ "$PWD" == "$CDT_TEST_PATH" ]]'
    editor = testpath/"editor.rb"
    editor.write <<~RUBY
      require "json"
      path = ARGV.fetch(0)
      data = JSON.parse(File.read(path))
      data.fetch("entries").first["tags"] = ["edited"]
      File.write(path, JSON.generate(data))
    RUBY
    ENV["VISUAL"] = "#{RbConfig.ruby} #{editor}"
    system bin/"cdt", "--edit"
    assert_match "[edited]", shell_output("#{bin}/cdt -l edited")
    system "/bin/zsh", "-fc",
           'eval "$(command cdt init zsh)"; cdt edited; [[ "$PWD" == "$CDT_TEST_PATH" ]]'
    system bin/"cdt", "-dp", project
    assert_empty shell_output("#{bin}/cdt -l")
  end
end
