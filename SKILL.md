---
name: claude-code-report-card
description: Use when the user wants to measure their own Claude Code usage level, get a self-assessment, build a "성적표 / report card", check how well they're using Claude Code, or apply the "6 Levels of Claude Code" framework to their own data. Triggers on "내 Claude Code 레벨", "성적표 만들어줘", "자가측정", "claude code 평가", "내가 얼마나 잘 쓰고 있나".
---

# Claude Code Report Card

Chase AI의 "The 6 Levels of Claude Code" 프레임워크를 사용자 본인 세션 로그에 적용해서, 객관적인 자가측정 성적표(HTML 한 페이지)를 생성하는 스킬.

## 핵심 원칙

**감(感)이 아니라 실로그로 측정**. `~/.claude/projects/*/*.jsonl`에 모든 사용 흔적이 쌓여 있으니, grep으로 직접 세는 게 가장 정확함. 사용자에게 "어떻게 쓰고 있는지" 물어보지 않음 — 로그가 답을 알고 있음.

## 워크플로우

### Step 1. 측정

`measure.sh`를 실행해서 5가지 지표를 수집한다. 기본 30일 기준.

```bash
bash ~/.claude/skills/claude-code-report-card/measure.sh 30
```

수집 항목:
- **Lv 1** 활동량 (30일 세션 수)
- **Lv 2** Plan Mode 진입률 (EnterPlanMode가 있는 세션 / 전체)
- **Lv 3** 메모리 큐레이션 (신규 추가 비율 + 총 개수)
- **Lv 4** MCP 연동 수 (settings에서 카운트)
- **Lv 5** 자작 스킬 가동률 (실제 호출된 고유 스킬 수 / 총 자작 스킬)
- **Lv 6** Subagent 다양성 (고유 타입 수 + 총 호출)

### Step 2. 등급 부여

아래 루브릭으로 각 레벨에 A~D 등급 부여. 표는 가이드라인일 뿐, 데이터 특성에 따라 ±1단계 조정 가능.

| Lv | 지표 | A | B | C | D |
|----|------|---|---|---|---|
| 1 | 일평균 세션 | ≥3 | ≥1.5 | ≥0.5 | <0.5 |
| 2 | Plan Mode % | ≥70% | ≥40% | ≥15% | <15% |
| 3 | 신규/총 메모리 % | 10~30% | 30~50% | 50~70% | <10% 또는 >70% |
| 4 | MCP 서버 수 | ≥5 | ≥3 | ≥1 | 0 |
| 5 | 스킬 가동률 | ≥60% | ≥40% | ≥20% | <20% (또는 스킬 0개) |
| 6 | Subagent 고유 타입 | ≥3 + 병렬 사용 | ≥2 | =1 (호출 ≥10) | =1 (호출 <10) 또는 0 |

종합 등급은 평점(A=4.0, B=3.0 등) 기반 평균. 6개 영역 중 D가 1개라도 있으면 **"Lv N에서 멈춰있음"** 으로 표시.

### Step 3. HTML 성적표 생성

`example-report.html`을 참고해서 사용자 본인 데이터로 채운 HTML을 만든다.

저장 경로: `~/Downloads/claude-code-report-{YYYY-MM-DD}.html`

**필수 포함 섹션**:
1. **커버 헤더** — 측정 기간 · 총 세션 수 · 자작 스킬 수
2. **종합 요약 카드** — 평점 + 한 줄 진단
3. **영상 6단계 요약** — Lv 1~6 카드 6개 + "카테고리 vs 등급" 주석
4. **레벨별 채점 카드 6개** — 각 카드에 점수·지표·게이지바·증거
5. **잘하고 있는 것 / 병목** — 정성 평가
6. **다음 30일 액션** — 가장 약한 레벨 중심 체크리스트

**디자인 토큰** (블루 베이스 + 위트 에디션):
```
/* 베이스 */
--primary: #237AF2     --primary-soft: #E8F1FE
--bg: #F5F6F8          --surface: #FFFFFF
--text-strong: #141618 --text: #2B2F34   --text-muted: #49515A
--line: #E5E7EB        --line-soft: #F1F3F6
/* 액센트 (재미 요소) */
--gold: #FFC93D        --gold-soft: #FFF4CC    /* 메달·게이지 마커 */
--mint: #38C5A8        --mint-soft: #DBF2EC    /* A 등급·good */
--coral: #FF7A59       --coral-soft: #FFE3DA   /* C 등급·warn */
--grape: #8B5CF6       --grape-soft: #ECE4FE   /* 보조 */
```

**폰트**:
- 본문: Pretendard (cdn.jsdelivr.net/gh/orioncactus/pretendard)
- 디스플레이/제목: Fredoka 500-700 (Google Fonts)
- 모노/숫자: DM Mono 500 (Google Fonts)

**필수 비주얼 요소**:
- 🏆 **트로피 메달** — 종합 점수에 conic-gradient ring + 이모지 + 큰 등급 + pts pill
- 📊 **6단계 스코어라인** — Lv 1→6 등급을 컬러 셀로 한눈에 (mint/primary/coral 컬러)
- ⭐ 게이지 바 끝에 골드 마커 도트
- 카드 호버 시 살짝 떠오르는 인터랙션

**카피 톤** (치얼업):
- 흐름: 칭찬 → 응원 → 도전. 섹션명 예: "이미 잘하고 있는 것" → "여기만 살짝 더 키우면 만점!" → "다음 30일 챌린지"
- 사용자 시점 2인칭("~했어요/~해보기"), "~함/~음" 같은 메모체 금지
- 기술 용어는 비유로 풀기: "Subagent" → "Claude한테 외주", "context rot" → "단기 기억 헷갈림", "MCP" → "외부 도구 연결"
- 이모지 절제 (섹션당 1-2개): 🎯 🚀 👏 ⚡ ✂️ 🧹 ✨ 💪 🙌
- 핵심 숫자는 `<b>` 태그로 강조, 진척감 표현 사용 ("거의 다 왔어요", "코앞이에요")

### Step 4. 열기

생성 후 자동으로 브라우저에서 열기:
```bash
open ~/Downloads/claude-code-report-{YYYY-MM-DD}.html
```

## 주의사항

- **수치 그대로 보고**: 데이터가 예상보다 좋거나 나빠도 그대로. 사용자의 추측보다 로그가 우선.
- **간접 증거 금지**: "메모리에 안 적혔으니 안 쓴다" 같은 추정 X. 항상 measure.sh 결과 기준.
- **Lv 4는 추정치**: MCP 카운트는 settings 구조에 따라 부정확할 수 있음. 결과가 0이면 사용자에게 수동 확인 요청.
- **세션 로그가 없으면 종료**: `~/.claude/projects/`가 비어있으면 "Claude Code 사용 이력이 없습니다" 안내하고 종료.
- **사용자 본인 톤 반영**: "잘하고 있는 것"은 격려조, "병목"은 직설적·구체적으로. 두루뭉술한 평가 금지.

## 참고

원본 영상: [The 6 Levels of Claude Code Explained — Chase AI](https://youtu.be/TUKYbUIXLOE)

이 스킬을 만든 동기와 1차 적용 사례는 `archives/플러그인/2026-05-24_claude-code-6-levels-self-assessment_eunji.md` (seoul-ai-club 레포) 참조.
