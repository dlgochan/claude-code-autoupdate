# claude-code-autoupdate

## 프로젝트 개요

claude-code의 Homebrew 설치판을 위한 자동 업데이트 도구입니다.

**핵심 목표**: 단일 명령어로 자동 업데이트 활성화 (`claude-autoupdate enable`)

## 아키텍처

### 구조
```
cmd/claude-autoupdate.rb          # CLI 진입점 (subcommand 파싱)
lib/claude_autoupdate/
  ├── core.rb                     # 경로 관리, 설치 감지, 검증
  ├── enable.rb                   # plist/script 생성 + launchctl load
  ├── disable.rb                  # launchctl unload + 파일 제거
  ├── status.rb                   # 상태 조회 + 로그 파싱
  └── update.rb                   # 수동 업데이트 실행
```

### 동작 방식

1. **설치 시** (`install`):
   - LaunchAgent plist 생성: `~/Library/LaunchAgents/com.github.dlgochan.claude-autoupdate.plist`
   - 업데이트 스크립트 생성: `~/Library/Application Support/claude-autoupdate/update.sh`
   - `launchctl load`로 등록

2. **LaunchAgent 실행 시점**:
   - 부팅 시 (RunAtLoad: true)
   - 매 24시간마다 (StartInterval: 86400)

3. **업데이트 스크립트 내용**:
   ```bash
   brew update && brew upgrade --cask claude-code && brew cleanup claude-code
   ```

## 핵심 원칙

### 1. Zero Dependencies
- homebrew-autoupdate 등 외부 의존성 없음
- 직접 plist 생성 및 launchctl 관리
- Ruby 표준 라이브러리만 사용

### 2. Homebrew 전용
- Native 설치(built-in auto-update)는 거부
- `core.rb`의 `native_installation?`로 감지
- Homebrew 설치 여부 확인: `brew list --cask claude-code`

### 3. 단순성 우선
- 설정 파일 없음
- 고정 간격 (24시간)
- 최소한의 코드 (~250 lines)

## 코드 규칙

### 파일 구성
- `cmd/`: Homebrew external command 엔트리 포인트
- `lib/`: 실제 구현 로직 (모듈화)
- Lazy loading: subcommand 실행 시에만 해당 모듈 require

### 네이밍
- Module: `ClaudeAutoupdate::{Command}`
- 함수: `module_function` 사용 (인스턴스 불필요)
- Label: `com.github.dlgochan.claude-autoupdate`

### 에러 처리
- `core.rb`의 `validate!`로 사전 검증
- Native 설치 감지 → 명확한 안내 메시지
- launchd 실패 → 로그 경로 안내

## 테스트 체크리스트

1. **설치 검증**:
   - Native 설치 거부
   - claude-code 미설치 거부
   - 중복 설치 감지

2. **파일 생성**:
   - plist 경로 정확성
   - script 실행 권한 (0555)
   - 로그 디렉토리 생성

3. **launchd 연동**:
   - `launchctl load` 성공
   - `launchctl list | grep <label>` 확인
   - 로그 파일에 기록 시작

4. **제거**:
   - `launchctl unload` 성공
   - plist 파일 삭제
   - 로그는 보존

## Homebrew Tap 배포

별도 저장소 필요: `dlgochan/homebrew-tap`

Formula 위치: `Formula/claude-autoupdate.rb`

핵심 설정:
```ruby
url "https://github.com/dlgochan/claude-code-autoupdate.git"
head "https://github.com/dlgochan/claude-code-autoupdate.git"
```

## 향후 확장 (v1.0 이후)

- [ ] 커스텀 간격 지원
- [ ] 업데이트 알림
- [ ] Dry-run 모드
- [ ] 멀티 패키지 지원

v1.0은 최소 기능에 집중.
