#!/usr/bin/env bash
# claude-code-report-card 한 줄 설치 스크립트
# 사용법: curl -fsSL https://raw.githubusercontent.com/wangdi6018/claude-code-report-card/main/install.sh | bash

set -euo pipefail

INSTALL_DIR="$HOME/.claude/skills/claude-code-report-card"
REPO_RAW="https://raw.githubusercontent.com/wangdi6018/claude-code-report-card/main"

echo "📊 claude-code-report-card 설치 시작..."

mkdir -p "$INSTALL_DIR"

for f in SKILL.md measure.sh example-report.html; do
  echo "  ↓ $f"
  curl -fsSL "$REPO_RAW/$f" -o "$INSTALL_DIR/$f"
done

chmod +x "$INSTALL_DIR/measure.sh"

echo ""
echo "✓ 설치 완료!"
echo ""
echo "  위치: $INSTALL_DIR"
echo "  사용: Claude Code에서 다음 중 하나 입력"
echo "    • /claude-code-report-card"
echo "    • 또는 '내 Claude Code 성적표 만들어줘'"
echo ""
echo "  바로 측정만 해보고 싶다면:"
echo "    bash $INSTALL_DIR/measure.sh 30"
echo ""
