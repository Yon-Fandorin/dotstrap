## Changelog

### 2026-06-26

#### 추가
- tmux 플러그인 확장 — `scripts/tmux-plugins.sh`에 `tmux-yank`(크로스플랫폼 클립보드)와
  `vim-tmux-navigator`(nvim↔tmux 무봉제 이동)를 직접 클론으로 추가(TPM 미사용 유지)
  - `configs/nvim/plugins/tmux-navigator.lua`(LazyVim 스펙) 동반 배포로 `Ctrl-h/j/k/l` 양방향 이동
- tmux 키맵 추가 — `prefix + g`(스크래치 팝업), `prefix + S`(pane 동기화 토글),
  `prefix + Tab`(직전 윈도우), `prefix + <`/`>`(윈도우 이동), `prefix + Ctrl-l`(화면 지우기)

#### 변경
- `configs/tmux/tmux.conf` — `history-limit` 50000→100000, `allow-passthrough on`,
  `aggressive-resize`, 활동 모니터링, ghostty RGB terminal-feature 추가
- 상태줄 윈도우 탭 요소 순서를 아이콘 → 이름 → 번호로 조정(파워라인 디자인은 기존 유지)
- 클립보드는 `tmux-yank`가 담당하도록 변경(기존 copy mode `y` 수동 분기 제거)
- 비활성 pane 경계선을 더 잘 보이는 dim 색(`#585b70`)으로 조정

#### 수정
- `README.md` 스크립트 표에 누락됐던 `tmux-plugins.sh` 추가 및 순서 번호 정정
- `docs/reference.md` tmux 섹션을 현재 구성(플러그인·sesh·키맵)에 맞게 갱신

### 2026-06-10

#### 변경
- 기본 터미널 멀티플렉서를 Zellij에서 tmux로 전환
  - `bootstrap.sh` 기본 실행 순서에서 `zellij.sh` 대신 `tmux.sh` 실행
  - `configs/tmux/tmux.conf` 추가 및 `~/.tmux.conf` 배포
  - `.zshrc` 별칭을 Zellij 계열에서 tmux 계열로 변경
  - README와 상세 레퍼런스의 실행 순서 및 검증 명령 갱신
- `codex.sh` — 공식 standalone installer 기반 Codex CLI 설치/갱신 스크립트 추가
- `claude.sh` — Volta로 설치된 Claude Code는 `volta install @anthropic-ai/claude-code@latest`로 갱신하도록 수정

### 2026-03-04

#### 수정
- `zsh-plugins.sh` — macOS bash 3.2 호환성 수정 (`declare -A` → indexed array)
  - macOS 기본 `/bin/bash`는 3.2로 associative array 미지원하여 스크립트 실패
  - Ubuntu(bash 5.x)에서는 정상 동작하여 기존 검증에서 발견되지 않음

### 2026-03-03 — 초기 구현

#### 추가
- `bootstrap.sh` 메인 오케스트레이터 (명시적 실행 순서 배열, 선택 실행 지원)
- `install.sh` 원격 부트스트랩 (`curl | bash`)
- `lib/common.sh` 공통 라이브러리
  - OS/아키텍처 자동 감지 (macos, ubuntu, debian, fedora, arch)
  - `pkg_install` 패키지 매니저 추상화 + OS별 패키지명 매핑
  - `HAVE_SUDO` 플래그로 sudo 미보유 환경 대응
  - 컬러 로깅 + `~/.dotstrap.log` 파일 기록
- 설치 스크립트 10종
  - `prerequisites.sh` — 시스템 패키지 (빌드 도구, CLI)
  - `zsh.sh` — Zsh 설치 + 기본 쉘 설정 (`usermod` 우선 사용)
  - `zsh-plugins.sh` — 플러그인 6종 (autosuggestions, syntax-highlighting, completions, history-substring-search, fzf-tab, you-should-use)
  - `starship.sh` — Starship 프롬프트 + Catppuccin Mocha 설정 배포
  - `rust.sh` — Rustup + stable 툴체인
  - `volta-node.sh` — Volta + Node LTS
  - `bun.sh` — Bun 런타임
  - `claude.sh` — Claude Code CLI
  - `nvim.sh` — Neovim 바이너리 + LazyVim starter + 플러그인 설정 배포
  - `zshrc.sh` — 템플릿 기반 `.zshrc` 생성
- 설정 파일
  - `configs/zshrc.template` — 히스토리, PATH, 플러그인, EDITOR/VISUAL, 별칭, `.zshrc.local` 소싱
  - `configs/starship.toml` — Catppuccin Mocha 테마
  - `configs/nvim/plugins/markdown.lua` — render-markdown.nvim

#### 수정
- `zsh-you-should-use` 레포 URL 오타 수정
- sudo 불가 시 starship `--bin-dir ~/.local/bin` 폴백
- sudo 불가 시 neovim `~/.local/` 설치 폴백
- compinit 깨진 심볼릭 링크(Docker Desktop WSL) 필터링

#### 검증
- Ubuntu 24.04 LTS (WSL2, x86_64) 에서 전체 실행, 멱등성, 선택 실행 통과
