class Cdt < Formula
  desc "Directory tags and native zsh navigation"
  homepage "https://github.com/JieteXue/cdt"
  url "https://github.com/JieteXue/cdt/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "fff99c0f1ceac3d5774d3592f1051ef3735156339d0ae445b8ed69aa5d361b85"
  license "MIT"

  depends_on "go" => :build
  depends_on :macos

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}")
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
