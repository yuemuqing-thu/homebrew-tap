class ClaudeUsageWidget < Formula
  desc "Claude / Codex 用量桌面挂件 —— 额度环、本地统计热力图、像素猫"
  homepage "https://github.com/yuemuqing-thu/claude-usage-widget"
  url "https://github.com/yuemuqing-thu/claude-usage-widget/archive/refs/tags/v0.3.5.tar.gz"
  sha256 "1406060b59f06b04a25fec83cb5dbbebafd2032e64dcc419996bb9f753adf44f"
  license "MIT"

  # 注意：formula 不能 depends_on cask，Homebrew 直接拒绝。
  # 所以 Übersicht（挂件的宿主）由 install 子命令在运行时自己拉。
  depends_on :macos
  # Codex 从 2026-06 起把 7 天以上的会话压成 rollout-*.jsonl.zst，
  # 不解压就只剩最近一周的历史。macOS 不自带 zstd。
  # 没有它也能跑（自动跳过压缩文件），只是热力图会短。
  depends_on "zstd"

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
