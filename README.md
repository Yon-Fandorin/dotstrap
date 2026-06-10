# Dotstrap

크로스 플랫폼 개발 환경 자동 구성 스크립트.

### 사용법

```bash
# 원격 설치 (전체)
curl -fsSL https://raw.githubusercontent.com/Yon-Fandorin/dotstrap/main/install.sh | bash

# 원격 설치 (일부 스크립트만) — git 등 기본 도구 + Node + Claude
curl -fsSL https://raw.githubusercontent.com/Yon-Fandorin/dotstrap/main/install.sh | bash -s -- prerequisites.sh volta-node.sh claude.sh

# 로컬에서 직접 실행
./dotstrap/bootstrap.sh

# 개별 스크립트만 실행
./dotstrap/bootstrap.sh rust.sh nvim.sh
```

### 지원 OS

- [x] Ubuntu 24.04 LTS (WSL2) — 검증 완료
- [x] macOS Tahoe (Apple Silicon) — 검증 완료
- [ ] Debian
- [ ] Fedora
- [ ] Arch Linux

### 스크립트 실행 순서

`bootstrap.sh` 내부 배열로 명시적 관리 (파일명 순서 아님):

| 순서 | 스크립트 | 설명 |
|:---:|----------|------|
| 1 | prerequisites.sh | 시스템 패키지 (빌드 도구, CLI) |
| 2 | zsh.sh | Zsh 설치 + 기본 쉘 설정 |
| 3 | zsh-plugins.sh | Zsh 플러그인 6종 |
| 4 | starship.sh | Starship 프롬프트 + 설정 배포 |
| 5 | rust.sh | Rustup + stable 툴체인 |
| 6 | volta-node.sh | Volta + Node LTS |
| 7 | bun.sh | Bun 런타임 |
| 8 | claude.sh | Claude Code CLI |
| 9 | codex.sh | Codex CLI |
| 10 | nvim.sh | Neovim + LazyVim + 플러그인 설정 |
| 11 | tmux.sh | tmux 설정 배포 |
| 12 | zshrc.sh | .zshrc 생성 (마지막 실행) |

### 파일 구조

```
dotstrap/
├── install.sh                  # 원격 설치 진입점 (curl | bash용)
├── bootstrap.sh                # 메인 오케스트레이터
├── CHANGELOG.md                # 변경 이력
├── lib/
│   └── common.sh               # OS/아키텍처 감지, 패키지 매니저 추상화, 로깅
├── scripts/
│   └── *.sh                    # 개별 설치 스크립트
├── configs/
│   ├── zshrc.template          # .zshrc 템플릿
│   ├── starship.toml           # Starship 설정 (Catppuccin Mocha)
│   ├── claude/statusline.sh    # Claude Code statusline
│   ├── tmux/tmux.conf          # tmux 설정
│   └── nvim/plugins/           # Neovim 플러그인 설정
└── docs/
    └── reference.md            # 상세 레퍼런스
```

### 설계 원칙

- **멱등성** — 재실행해도 안전. 이미 설치된 항목은 스킵.
- **sudo 미보유 대응** — `HAVE_SUDO` 플래그로 판단. 없으면 `~/.local/bin` 등 사용자 디렉토리에 설치.
- **실패 격리** — 개별 스크립트 실패 시 로그 남기고 다음 스크립트 계속 진행.
- **로깅** — 컬러 터미널 출력 + `~/.dotstrap.log` 파일 기록.

상세 내용은 [docs/reference.md](docs/reference.md), 변경 이력은 [CHANGELOG.md](CHANGELOG.md) 참조.
