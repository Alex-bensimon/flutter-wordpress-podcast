# Flutter Wordpress Podcast

Podcast white label app based on Wordpress API using Flutter framework.

## Preview

![screenshot1](https://github.com/PierreBresson/flutter-wordpress-podcast/blob/main/preview/thinkerview-1.jpg)
![screenshot2](https://github.com/PierreBresson/flutter-wordpress-podcast/blob/main/preview/thinkerview-2.jpg)
![screenshot3](https://github.com/PierreBresson/flutter-wordpress-podcast/blob/main/preview/thinkerview-3.jpg)

## Live demo

Thinkerview - [Android](https://play.google.com/store/apps/details?id=com.thinkerview&hl=fr)

Cause Commune - [Android](https://play.google.com/store/apps/details?id=com.cause.commune)

## Roadmap

Already existing and planned features.

- [x] Dark mode support
- [x] Refactor into smaller widgets
- [x] Test widgets and cubits
- [x] Recommended books for Thinkerview - markdown screen
- [x] Play audio in the background and respond to controls on the lockscreen, media notification, headset
- [ ] Stream live radio
- [ ] Audio playback when leaving app
- [ ] Log crash/bugs to Sentry
- [ ] Improved design
- [ ] Image caching
- [ ] Env config / scripts for white label apps
- [ ] Search
- [ ] localization - i18
- [ ] share episode with friend / deep-linking to open a specific episode
- [ ] Categories screen
- [ ] Chromecast / Airplay
- [ ] Details when clicking on a podcast item
- [ ] AndroidAuto / CarPlay
- [ ] Download podcast / offline mode

App tested and working on :

- [x] iOS
- [x] Android
- [ ] Web
- [ ] MacOS - in progress
- [ ] Linux

### Getting started

Running the app:

`flutter run`
`flutter run -d macos`

`flutter clean`
`flutter clean && flutter run --flavor thinkerview`
`flutter clean && flutter run --flavor causecommune`

Build for Android:

`flutter build appbundle --flavor thinkerview`
`flutter build appbundle --flavor causecommune`

WIP :
`flutter build macos`
