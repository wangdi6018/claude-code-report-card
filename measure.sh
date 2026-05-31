#!/usr/bin/env bash
# Claude Code 사용 지표 측정 스크립트
# 사용법: ./measure.sh [DAYS]   기본 30일

set -euo pipefail

DAYS="${1:-30}"
PROJECTS_DIR="$HOME/.claude/projects"
SKILLS_DIR="$HOME/.claude/skills"

if [ ! -d "$PROJECTS_DIR" ]; then
  echo "ERROR: $PROJECTS_DIR not found. Have you used Claude Code before?" >&2
  exit 1
fi

# ── Lv 1: 활동량 ───────────────────────────────────────
SESSIONS=$(find "$PROJECTS_DIR" -name "*.jsonl" -mtime -"$DAYS" -type f 2>/dev/null | wc -l | tr -d ' ')

# ── Lv 2: Plan Mode 진입 ──────────────────────────────
PLAN_MODE=$(find "$PROJECTS_DIR" -name "*.jsonl" -mtime -"$DAYS" -type f \
  -exec grep -lE '"(EnterPlanMode|ExitPlanMode)"' {} \; 2>/dev/null | wc -l | tr -d ' ')

# ── Lv 3: 메모리 큐레이션 ─────────────────────────────
TOTAL_MEMORY=0
NEW_MEMORY=0
for d in "$PROJECTS_DIR"/*/memory; do
  if [ -d "$d" ]; then
    cnt=$(find "$d" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    TOTAL_MEMORY=$((TOTAL_MEMORY + cnt))
    nnew=$(find "$d" -maxdepth 1 -name "*.md" -type f -mtime -"$DAYS" 2>/dev/null | wc -l | tr -d ' ')
    NEW_MEMORY=$((NEW_MEMORY + nnew))
  fi
done

# ── Lv 4: MCP 연동 폭 (수동 — settings에서 카운트) ────
MCP_COUNT=0
if [ -f "$HOME/.claude.json" ]; then
  MCP_COUNT=$(grep -oE '"mcpServers"' "$HOME/.claude.json" 2>/dev/null | wc -l | tr -d ' ')
fi
# settings.json에서 mcpServers 키 안의 서버 수를 더 정확히 추정
MCP_COUNT_DETAILED=$(python3 -c "
import json, os, sys
total = set()
for p in [os.path.expanduser('~/.claude.json'), os.path.expanduser('~/.claude/settings.json')]:
    if os.path.exists(p):
        try:
            with open(p) as f:
                data = json.load(f)
            for k in data.get('mcpServers', {}).keys():
                total.add(k)
            for proj in data.get('projects', {}).values():
                for k in proj.get('mcpServers', {}).keys():
                    total.add(k)
        except: pass
print(len(total))
" 2>/dev/null || echo 0)

# ── Lv 5: 스킬 가동률 ─────────────────────────────────
TOTAL_SKILLS=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

SKILL_USES=$(find "$PROJECTS_DIR" -name "*.jsonl" -mtime -"$DAYS" -type f \
  -exec grep -hoE '"skill":"[^"]+"' {} \; 2>/dev/null)
SLASH_USES=$(find "$PROJECTS_DIR" -name "*.jsonl" -mtime -"$DAYS" -type f \
  -exec grep -hoE '<command-name>/[^<]+</command-name>' {} \; 2>/dev/null)

UNIQUE_SKILLS_USED=$(echo -e "${SKILL_USES}\n${SLASH_USES}" | grep -v '^$' | sort -u | wc -l | tr -d ' ')

# ── Lv 6: Subagent 다양성 ─────────────────────────────
SUBAGENT_RAW=$(find "$PROJECTS_DIR" -name "*.jsonl" -mtime -"$DAYS" -type f \
  -exec grep -hoE '"subagent_type":"[^"]+"' {} \; 2>/dev/null | sort | uniq -c | sort -rn)

SUBAGENT_TOTAL=$(echo "$SUBAGENT_RAW" | awk '{sum+=$1} END {print sum+0}')
SUBAGENT_UNIQUE=$(echo "$SUBAGENT_RAW" | grep -c . 2>/dev/null || echo 0)
[ -z "$SUBAGENT_RAW" ] && SUBAGENT_UNIQUE=0

# ── 출력 ───────────────────────────────────────────────
cat <<EOF
=== Claude Code Usage Metrics (last ${DAYS} days) ===

Lv 1  활동량
  세션 수: ${SESSIONS}
  일평균: $(echo "scale=1; ${SESSIONS}/${DAYS}" | bc 2>/dev/null || echo "?")

Lv 2  Plan Mode 진입률
  Plan Mode 세션: ${PLAN_MODE}/${SESSIONS}
  진입률: $([ "$SESSIONS" -gt 0 ] && echo "scale=1; ${PLAN_MODE}*100/${SESSIONS}" | bc 2>/dev/null || echo "?")%

Lv 3  메모리 큐레이션
  총 메모리: ${TOTAL_MEMORY}개
  신규 ${DAYS}일: ${NEW_MEMORY}개
  비율: $([ "$TOTAL_MEMORY" -gt 0 ] && echo "scale=1; ${NEW_MEMORY}*100/${TOTAL_MEMORY}" | bc 2>/dev/null || echo "?")%

Lv 4  MCP 연동 수
  설정된 MCP 서버: ${MCP_COUNT_DETAILED}개 (정확치 아니면 수동 카운트)

Lv 5  스킬 가동률
  총 자작 스킬: ${TOTAL_SKILLS}개
  ${DAYS}일 내 가동된 고유 스킬: ${UNIQUE_SKILLS_USED}개
  가동률: $([ "$TOTAL_SKILLS" -gt 0 ] && echo "scale=1; ${UNIQUE_SKILLS_USED}*100/${TOTAL_SKILLS}" | bc 2>/dev/null || echo "?")%

Lv 6  Subagent 다양성
  총 호출: ${SUBAGENT_TOTAL}회
  고유 타입: ${SUBAGENT_UNIQUE}종

--- Subagent 타입별 호출 ---
${SUBAGENT_RAW:-(없음)}

--- 상위 스킬 호출 ---
$(echo "$SKILL_USES" | grep -v '^$' | sort | uniq -c | sort -rn | head -10)

--- 상위 슬래시 커맨드 ---
$(echo "$SLASH_USES" | grep -v '^$' | sort | uniq -c | sort -rn | head -10)
EOF
