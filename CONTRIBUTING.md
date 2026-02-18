# Contributing

claude-code-autoupdate에 기여해주셔서 감사합니다!

## Development Setup

```bash
git clone https://github.com/dlgochan/claude-code-autoupdate.git
cd claude-code-autoupdate
```

실행:
```bash
ruby cmd/claude-autoupdate.rb status
```

## Project Structure

```
cmd/claude-autoupdate.rb        # CLI entry point
lib/claude_autoupdate/
  ├── core.rb                   # Paths, validation, installation detection
  ├── config.rb                 # Config management, interval parsing
  ├── enable.rb                 # LaunchAgent setup
  ├── disable.rb                # LaunchAgent teardown
  ├── status.rb                 # Status reporting
  ├── update.rb                 # Manual update
  └── show_config.rb            # Config display
```

## Guidelines

- **Zero dependencies** — Ruby 표준 라이브러리만 사용 (Ruby 2.6+ 호환)
- **macOS 전용** — launchd 기반이므로 macOS만 지원
- **단순하게** — 각 모듈은 한 가지 역할만 담당

## Pull Requests

1. Fork → branch → commit → PR
2. 변경 사항을 간결하게 설명
3. 기존 코드 스타일을 따를 것

## Bug Reports

[Issue 템플릿](https://github.com/dlgochan/claude-code-autoupdate/issues/new/choose)을 사용해주세요.
