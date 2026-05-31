# 📊 Claude Code Report Card

> Chase AI의 ["The 6 Levels of Claude Code"](https://youtu.be/TUKYbUIXLOE) 프레임워크를 본인 세션 로그에 적용해서, 객관적인 자가측정 성적표(HTML 한 페이지)를 생성하는 Claude Code 스킬.

**감(感)이 아니라 실로그로 측정**. `~/.claude/projects/*/*.jsonl`에 쌓인 30일치 사용 기록을 grep으로 직접 세서, 6단계 능력별 등급(A·B·C·D)을 매기고, 한 페이지 HTML 성적표를 자동으로 띄워줍니다.

---

## ✨ 미리보기

성적표에 들어가는 것:
- 🏆 **종합 등급 메달** (A−, 평점 3.67/4.0 같은 형태)
- 📊 **6단계 스코어라인** (Lv 1~6 등급 한눈에)
- 📺 **영상 6단계 요약** (원본 영상의 프레임워크 설명)
- 📝 **레벨별 채점 카드 6개** (게이지 + 근거)
- 💬 **잘하고 있는 것 / 병목 / 다음 30일 챌린지**

---

## 🚀 한 줄 설치

```bash
curl -fsSL https://raw.githubusercontent.com/wangdi6018/claude-code-report-card/main/install.sh | bash
```

설치 후 Claude Code에서:
```
/claude-code-report-card
```

또는 자연어로:
> "내 Claude Code 성적표 만들어줘"
> "내가 얼마나 잘 쓰고 있나 측정해줘"

---

## 📐 측정 지표

| Lv | 지표 | 측정 방법 |
|----|------|----------|
| 1 | 활동량 | 30일 세션 파일 수 |
| 2 | Plan Mode 진입률 | `EnterPlanMode` 호출 세션 / 전체 |
| 3 | 메모리 큐레이션 | 신규 추가 vs 삭제 비율 |
| 4 | MCP 연동 수 | settings에서 카운트 |
| 5 | 자작 스킬 가동률 | 실제 호출된 고유 스킬 / 총 자작 스킬 |
| 6 | Subagent 다양성 | `subagent_type` 종류와 호출 횟수 |

---

## 🛠 수동 설치 (git clone)

```bash
git clone https://github.com/wangdi6018/claude-code-report-card.git \
  ~/.claude/skills/claude-code-report-card
chmod +x ~/.claude/skills/claude-code-report-card/measure.sh
```

---

## 📝 측정 스크립트만 돌려보기

성적표 없이 그냥 본인 30일치 지표만 확인하고 싶다면:

```bash
bash ~/.claude/skills/claude-code-report-card/measure.sh 30
```

기간 변경: `bash measure.sh 7` (지난 7일)

---

## 🎨 디자인

삼쩜삼 디자인시스템(주 컬러 `#237AF2`) + 약간의 위트:
- 폰트: Pretendard + Fredoka + DM Mono
- 트로피 메달, 6단계 스코어라인, 골드 게이지 마커
- 회사 슬랙에 공유해도 자연스럽고, 트위터에 캡쳐해도 시선 끌리는 톤

다른 디자인 토큰으로 바꾸고 싶다면 `SKILL.md`의 디자인 토큰 섹션을 수정하면 됩니다.

---

## 📺 원본 영상

[**The 6 Levels of Claude Code Explained** — Chase AI](https://youtu.be/TUKYbUIXLOE)

영상은 6단계 정의만 알려주고 "너는 몇 레벨이냐"는 알려주지 않습니다. 이 스킬은 그 빈 공간을 메우려고 만들었어요.

---

## English

**Claude Code Report Card** — Apply Chase AI's "6 Levels of Claude Code" framework to your own session logs. Grep-based metrics from `~/.claude/projects/*/*.jsonl`, A–D grades per level, auto-generated HTML report card in your browser.

Install:
```bash
curl -fsSL https://raw.githubusercontent.com/wangdi6018/claude-code-report-card/main/install.sh | bash
```

Then in Claude Code: `/claude-code-report-card`

---

## License

MIT
