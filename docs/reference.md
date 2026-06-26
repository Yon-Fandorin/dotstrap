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

tmux 설정은 두 스크립트로 나뉜다. `scripts/tmux.sh`는 tmux를 설치하고
`configs/tmux/tmux.conf`를 `~/.tmux.conf`로 배포하며, `scripts/tmux-plugins.sh`는
플러그인과 `sesh` 세션 매니저를 설치한다(`bootstrap.sh`에서 `tmux.sh` 다음에 실행).

- tmux가 없으면 `pkg_install tmux`로 설치 시도
- prefix는 `Ctrl-a`
- 마우스, vi copy mode, 현재 경로 기준 pane/window 생성 활성화
- 스크롤백 `history-limit 100000`, `allow-passthrough on`(이미지 프로토콜·OSC 52),
  `aggressive-resize`, 활동 모니터링(`monitor-activity`)
- 상태줄은 Catppuccin Mocha 파워라인(상단). 세션 블록(초록) · 윈도우 탭 · 날짜·시간
  블록으로 구성되고, 윈도우 탭은 실행 중인 프로그램(nvim/git/ssh/python/node 등)
  아이콘 → 이름 → 번호 순으로 표시한다

**배포 시 치환**: `tmux.sh`가 `~/.tmux.conf`로 복사할 때 `default-shell`의
`__ZSH_PATH__` 플레이스홀더를 해석된 zsh 경로로 치환한다(zsh가 없으면 해당 줄 제거).

**플러그인** (TPM 없이 `tmux-plugins.sh`가 `~/.config/tmux/plugins/`로 직접 클론하고
`tmux.conf`가 `run-shell`로 소싱):

| 플러그인 | 설명 |
|---------|------|
| tmux-resurrect | 세션/윈도우/pane 레이아웃·내용 저장·복원 (`prefix + Ctrl-s` / `prefix + Ctrl-r`) |
| tmux-continuum | 10분마다 자동 저장, tmux 서버 시작 시 자동 복원 → **재부팅 후 유지** |
| tmux-yank | macOS/Wayland/X11/WSL 크로스플랫폼 시스템 클립보드 (`y`, 마우스 드래그) |
| vim-tmux-navigator | nvim↔tmux pane 무봉제 이동 (`Ctrl-h/j/k/l`, vim/fzf 안이면 키 전달) |

**세션 매니저(sesh)**: `prefix + t`로 기존 세션을 퍼지 검색하거나 디렉터리에서 새 세션을
생성한다. macOS는 Homebrew, 그 외는 `go install`로 설치하고 `~/.local/bin`에 심볼릭한다.

**추가 키맵**: `prefix + g`(현재 경로 스크래치 팝업), `prefix + S`(pane 입력 동기화 토글),
`prefix + Tab`(직전 윈도우), `prefix + <`/`>`(윈도우 이동),
`prefix + Ctrl-l`(화면 지우기 — vim-tmux-navigator가 무프리픽스 `Ctrl-l`을 가져가므로 복원).

nvim 쪽 연동은 `configs/nvim/plugins/tmux-navigator.lua`(LazyVim 스펙)로 배포된다.

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
