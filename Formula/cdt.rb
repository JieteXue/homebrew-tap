class Cdt < Formula
  desc "Directory tags and native zsh navigation"
  homepage "https://github.com/JieteXue/cdt"
  license "MIT"

  depends_on :macos

  if Hardware::CPU.arm?
    url "https://github.com/JieteXue/cdt/releases/download/v0.5.0/cdt_0.5.0_darwin_arm64.tar.gz"
    sha256 "207cb185fddd25557b6c2950d040406e1d04a15d5a9a13c61a3ed9841b4be3f1"
  else
    url "https://github.com/JieteXue/cdt/releases/download/v0.5.0/cdt_0.5.0_darwin_amd64.tar.gz"
    sha256 "fbc138a2049b9476e18afdaa1dabbc041498eb5852c6d06abc4004411927138f"
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
    assert_match "DIRECTORIES", shell_output("#{bin}/cdt --tags")
    assert_match "Inherited: work <- ", shell_output("#{bin}/cdt --explain work api")
    registry = testpath/"config/cdt/registry.json"
    snapshot = registry.read
    assert_match "registry unchanged", shell_output("#{bin}/cdt --rename-tag api service --dry-run")
    assert_equal snapshot, registry.read
    system bin/"cdt", "--rename-tag", "api", "service"
    assert_match "#{child.realpath}  [service]", shell_output("#{bin}/cdt -l work service")
    moved = project/"service"
    child.rename(moved)
    snapshot = registry.read
    preview = shell_output("#{bin}/cdt --move #{child.to_s.shellescape} #{moved.to_s.shellescape} --dry-run")
    assert_match "registry unchanged", preview
    assert_equal snapshot, registry.read
    system bin/"cdt", "--move", child, moved
    assert_match "#{moved.realpath}  [service]", shell_output("#{bin}/cdt -l work service")
    system bin/"cdt", "-dp", moved
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
