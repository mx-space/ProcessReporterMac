# Process Reporter

Process Reporter is a macOS application built with Swift UI. It is designed to report in real time the name of the foreground application being used by the current user on macOS, as well as any media information being played.

## Other Platform

If you looking for other platform...

- [Linux](https://github.com/ttimochan/processforlinux)
- [Windows(ProcessReporterWin)](https://github.com/ChingCdesu/ProcessReporterWin)
- [Windows(ProcessReporterWinpy)](https://github.com/TNXG/ProcessReporterWinpy)

## Main Features

- Real-time reporting of the foreground application being used by the current user
- Real-time reporting of any media information being played by the current user

![](https://github.com/mx-space/ProcessReporterMac/assets/41265413/8987d41e-2f62-41d7-8bd5-f9aee2d9393f)

## Integration

- [Shiro](https://github.com/Innei/Shiro)

  This data is reported to our server, which then notifies users browsing the Shiro-built website in real time via WebSocket. This allows users to see their real-time activity on the website.

- Slack

  Automatically update your profile to show the currently playing music or other content. Supports customizing profile text and emojis.

## How to Use

1. Clone this repository to your local machine.
2. Open the project in Xcode and compile it.
3. Open the compiled app and go to settings. Fill in your apiKey and api endpoint url.
4. Start using your macOS device, and Process Reporter for Shiro will automatically report your activity.

## Dependencies

This project uses the following open-source libraries:

- [SwiftJotai](https://github.com/unixzii/SwiftJotai)
- [LaunchAtLogin-Modern](https://github.com/sindresorhus/LaunchAtLogin-Modern)
- [nowplaying-cli](https://github.com/kirtan-shah/nowplaying-cli)

## Open Source and Contribution

Process Reporter for Shiro is an open-source project, and we welcome contributions from anyone. If you have any issues or suggestions, feel free to submit an issue or pull request.

## License

Process Reporter for Shiro is licensed under the MIT License. For details, please see the LICENSE file.
