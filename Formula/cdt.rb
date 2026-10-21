class Cdt < Formula
  desc "Directory tags and native zsh navigation"
  homepage "https://github.com/JieteXue/cdt"
  url "https://github.com/JieteXue/cdt/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "935aabe9984478e7f91cba11f79b7c61743ca727ae3ea6ddee800a9ec36808ba"
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
    assert_match project.realpath.to_s, shell_output("#{bin}/cdt -l work")
    system "/bin/zsh", "-fc",
           'eval "$(command cdt init zsh)"; cdt work; [[ "$PWD" == "$CDT_TEST_PATH" ]]'
    system bin/"cdt", "-dp", project
    assert_empty shell_output("#{bin}/cdt -l")
  end
end
