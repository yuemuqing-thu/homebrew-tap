class ClaudeUsageWidget < Formula
  desc "Claude / Codex 用量桌面挂件 —— 额度环、本地统计热力图、像素猫"
  homepage "https://github.com/yuemuqing-thu/claude-usage-widget"
  url "https://github.com/yuemuqing-thu/claude-usage-widget/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "4953eb92af3d4b0207e5cdc52fa5bb1321b9bd9daacf6c1552b2bf7eba0d4c62"
  license "MIT"

  # 注意：formula 不能 depends_on cask，Homebrew 直接拒绝。
  # 所以 Übersicht（挂件的宿主）由 install 子命令在运行时自己拉。
  depends_on :macos

  def install
    libexec.install "claude-usage.widget", "install.sh"
    # 不能直接 symlink：install.sh 用 dirname $0 定位挂件目录，
    # 走 symlink 会解析到 bin/ 而不是 libexec/。所以包一层。
    (bin/"claude-usage-widget").write <<~SH
      #!/bin/sh
      exec /bin/sh "#{libexec}/install.sh" "$@"
    SH
    chmod 0755, bin/"claude-usage-widget"
  end

  def caveats
    <<~EOS
      文件已就位，但还没启用 —— Homebrew 不允许在安装阶段改你的主目录。

      启用：
        claude-usage-widget install

      停用：
        claude-usage-widget uninstall

      启用会做这些事：检查 Übersicht（没有就自动 brew 装上）、装 statusLine 脚本、
      改 ~/.claude/settings.json（自动备份）、把挂件放进 Übersicht、重启 Übersicht。

      装了 Codex 的话会自动一起显示，不用额外操作。
      不想要：claude-usage-widget codex off

      出问题了：
        claude-usage-widget doctor
    EOS
  end

  test do
    assert_match "用法", shell_output("#{bin}/claude-usage-widget --help")
  end
end
