## 상세 레퍼런스

### 시스템 패키지 (prerequisites.sh)

| 카테고리 | 논리 이름 | macOS (brew) | Ubuntu/Debian (apt) | Fedora (dnf) | Arch (pacman) |
|---------|----------|-------------|-------------------|-------------|--------------|
| 빌드 도구 | build-essential | Xcode CLT | build-essential | gcc gcc-c++ make | base-devel |
| 빌드 도구 | cmake | cmake | cmake | cmake | cmake |
| 빌드 도구 | pkg-config | pkg-config | pkg-config | pkgconf | pkgconf |
| 빌드 도구 | openssl-dev | openssl | libssl-dev | openssl-devel | openssl |
| 필수 CLI | curl, wget, git, jq, unzip, zip | 동일 | 동일 | 동일 | 동일 |
| 모던 CLI | ripgrep, bat, fzf, tree, htop, zoxide, eza | 동일 | 동일 | 동일 | 동일 |
| 모던 CLI | fd | fd | fd-find | fd-find | fd |
| 기타 | xclip | 불필요 (pbcopy) | xclip | xclip | xclip |
| 기타 | python3 | python3 | python3 python3-pip python3-venv | python3 | python3 |
| 기타 | luarocks, tmux, stow | 동일 | 동일 | 동일 | 동일 |

### Zsh 플러그인 (zsh-plugins.sh)

플러그인 매니저 없이 `~/.zsh/`에 직접 git clone.

| 플러그인 | 설명 |
|---------|------|
| zsh-autosuggestions | Fish 스타일 명령어 자동 제안 |
| zsh-syntax-highlighting | 실시간 구문 강조 |
| zsh-completions | 추가 자동완성 정의 |
| zsh-history-substring-search | 부분 입력 후 ↑↓로 히스토리 검색 |
| fzf-tab | 자동완성 메뉴를 fzf로 대체 |
| zsh-you-should-use | 별칭 존재 시 알림 |

### OS별 특수 처리

| OS | 처리 |
|----|------|
| macOS | Homebrew 자동 설치, Xcode CLT 확인, xclip 대신 pbcopy 사용 |
| Ubuntu/Debian | `fdfind`→`fd`, `batcat`→`bat` 심볼릭 링크 (`~/.local/bin/`) |
| Fedora | `pkgconf` (pkg-config 대체), `openssl-devel` |
| Arch | `pacman --needed` 플래그로 중복 설치 방지 |

### .zshrc 관리

`configs/zshrc.template`에서 전체 `.zshrc`를 생성 (append 방식 아님).

- 기존 `.zshrc`가 다르면 `.zshrc.bak.{timestamp}`로 백업
- `~/.zshrc.local`을 마지막에 소싱 — 추적하지 않는 개인 설정용
- nvim 존재 시 `EDITOR`/`VISUAL` 설정 → git 등 모든 CLI 도구에서 nvim 사용
- `vi`/`vim` → `nvim`, `cat` → `bat`, `find` → `fd`, `ls` → `eza` 별칭
- Claude Code `cc` 별칭
- tmux 존재 시 `tm`, `tma`, `tml`, `tmn` 별칭

### Claude Code 관리

`scripts/claude.sh`는 Claude Code CLI를 설치/갱신하고 statusline 설정을 배포한다.

- Volta가 있으면 `volta install @anthropic-ai/claude-code@latest` 사용
- Volta가 없고 npm이 있으면 `npm install -g @anthropic-ai/claude-code` 사용
- `configs/claude/statusline.sh`를 `~/.claude/statusline.sh`로 배포
- `jq`가 있으면 `~/.claude/settings.json`에 statusLine 명령 자동 설정

### tmux 관리

`scripts/tmux.sh`는 `configs/tmux/tmux.conf`를 `~/.tmux.conf`로 배포한다.

- tmux가 없으면 `pkg_install tmux`로 설치 시도
- prefix는 `Ctrl-a`
- 마우스, vi copy mode, 현재 경로 기준 pane/window 생성 활성화
- 상태줄은 Catppuccin Mocha 계열 색상 사용
- copy mode의 `y`는 macOS `pbcopy`, Wayland `wl-copy`, X11 `xclip` 순서로 클립보드 연동

### Codex CLI 관리

`scripts/codex.sh`는 공식 Codex standalone installer를 비대화형으로 실행해 `~/.local/bin/codex`를 설치/갱신한다.

- 설치 URL: `https://chatgpt.com/codex/install.sh`
- `CODEX_NON_INTERACTIVE=true`로 실행해 설치 후 Codex를 자동 실행하지 않음
- `CODEX_INSTALL_DIR=~/.local/bin`으로 설치 위치 고정

### 검증 방법

```bash
# 전체 실행 후 에러 확인
./dotstrap/bootstrap.sh

# 도구 버전 확인
rustc --version && node --version && bun --version && claude --version && codex --version && nvim --version && tmux -V

# 멱등성 확인 (재실행)
./dotstrap/bootstrap.sh

# 선택 실행 확인
./dotstrap/bootstrap.sh rust.sh

# 로그 확인
cat ~/.dotstrap.log
```

### 검증 결과

#### Ubuntu 24.04 LTS / WSL2 (2026-03-03)

| 항목 | 값 |
|------|-----|
| OS | Ubuntu 24.04.1 LTS (Noble Numbat) |
| Kernel | 6.6.87.2-microsoft-standard-WSL2 |
| Arch | x86_64 |
| Shell | zsh 5.9 |
| Runtime | WSL2 (Windows Subsystem for Linux) |
| sudo | 사용 불가 (패스워드 보호) |

| 도구 | 버전 |
|------|------|
| rustc | 1.93.1 |
| node | v24.14.0 |
| bun | 1.3.10 |
| nvim | v0.11.6 |
| claude | 2.1.63 |
| starship | 1.24.2 |
| zsh | 5.9 |

- 전체 실행: 성공 (sudo 필요한 apt 패키지는 경고 후 스킵)
- 멱등성 재실행: 성공 (이미 설치된 항목 모두 스킵)
- 선택 실행 (`./dotstrap/bootstrap.sh rust.sh`): 성공

#### macOS Tahoe / Apple Silicon (2026-03-04)

| 항목 | 값 |
|------|-----|
| OS | macOS 26.2 (Tahoe) |
| Chip | Apple M2 Pro |
| Arch | arm64 |
| Shell | zsh 5.9 |
| Runtime | 네이티브 |

| 도구 | 버전 |
|------|------|
| rustc | 1.93.1 |
| node | v22.17.1 |
| bun | 1.3.10 |
| nvim | v0.11.5 |
| claude | 2.1.66 |
| starship | 1.24.2 |
| zsh | 5.9 |

- 전체 실행: 성공
- 멱등성 재실행: 성공 (이미 설치된 항목 모두 스킵)
- Homebrew 기반 패키지 설치: 정상 (sudo 불필요)
