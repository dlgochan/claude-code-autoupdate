# claude-code-autoupdate

## 프로젝트 개요

claude-code의 Homebrew 설치판을 위한 자동 업데이트 도구.

**핵심 목표**: `claude-autoupdate enable` 한 번으로 자동 업데이트 활성화

## 아키텍처

### 구조
```
cmd/claude-autoupdate.rb            # CLI 진입점 (subcommand 파싱 → 모듈 위임)
lib/claude_autoupdate/
  ├── core.rb                       # 경로 관리, 설치 감지, 검증
  ├── config.rb                     # 설정 관리 (interval 등)
  ├── enable.rb                     # plist/script 생성 + launchctl load
  ├── disable.rb                    # launchctl unload + 파일 제거
  ├── status.rb                     # 상태 조회 + 로그 파싱
  ├── update.rb                     # 수동 업데이트 실행
  └── show_config.rb                # 설정 표시
```

### 동작 방식

1. `enable` 실행 시:
   - config.json 생성 (interval 설정)
   - update.sh 스크립트 생성 (`brew upgrade --cask claude-code`)
   - LaunchAgent plist 생성 (interval 기반)
   - `launchctl load`로 등록

2. LaunchAgent가 주기적으로 update.sh 실행

3. `disable` 실행 시:
   - `launchctl unload` → plist/scripts/config 삭제 (로그 보존)

### 파일 위치
```
~/Library/LaunchAgents/com.github.dlgochan.claude-autoupdate.plist
~/Library/Application Support/claude-autoupdate/update.sh
~/Library/Application Support/claude-autoupdate/config.json
~/Library/Logs/claude-autoupdate/claude-autoupdate.log
```

## 핵심 원칙

1. **Zero Dependencies**: 외부 의존성 없음. Ruby 표준 라이브러리만 사용
2. **Homebrew 전용**: Native 설치는 거부 (built-in auto-update 있음)
3. **단순성**: 모듈별 단일 책임. Lazy loading

## 코드 규칙

- Module: `ClaudeAutoupdate::{Command}`, `module_function` 사용
- 모듈 내부에서는 같은 네임스페이스 참조 시 접두사 생략 (`Core.running?`)
- `cmd/` 에서 외부 모듈 참조 시 `::` 접두사 사용 (`::ClaudeAutoupdate::Core`)
- Label 상수: `Core::LABEL`

## Homebrew Tap 배포

별도 저장소: `dlgochan/homebrew-tap` → `Formula/claude-autoupdate.rb`
