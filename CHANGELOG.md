## Changelog

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
