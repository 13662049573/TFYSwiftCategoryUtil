# Changelog

All notable changes to this project will be documented in this file.

## [2.5.0] - 2026-10-21

### Changed

- Raised minimum deployment target from iOS 15.0 to **iOS 16.0** across CocoaPods, Swift Package Manager, and Xcode project settings.
- Removed redundant `@available(iOS 15.0, *)` annotations and legacy pre–iOS 15 code paths now that iOS 16 is required.
- Updated documentation and module comments to reflect iOS 16.0+ support.
