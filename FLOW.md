# Capture flow

The screenshots and the demo GIF in the README are real captures from an Android emulator, made by the GitHub Actions workflow `.github/workflows/capture.yml`.

## Regenerate

```sh
gh workflow run capture.yml -R tranthienhau/pagewell-flutter --ref main
gh run watch <run-id> -R tranthienhau/pagewell-flutter
gh run download <run-id> -R tranthienhau/pagewell-flutter -n capture -D screenshots
```

## How it works

1. The workflow builds two debug APKs before the emulator boots: one for `integration_test/screenshot_test.dart`, one for `integration_test/demo_test.dart`.
2. `reactivecircus/android-emulator-runner` boots a Pixel 6 emulator (API 34, x86_64, KVM) and runs `.github/scripts/capture-emulator.sh flutter`.
3. `flutter drive` runs the screenshot test. It walks the app and calls `binding.takeScreenshot('NN-name')`; `test_driver/integration_test.dart` writes each PNG to `screenshots/`.
4. The demo test runs while `adb shell screenrecord` records the screen. The test prints `POC_DEMO_START` and `POC_DEMO_END`; the script cuts the video to that window with logcat timestamps and converts it to a 12 fps, 300 px GIF with an ffmpeg palette pass.
5. The workflow uploads `screenshots/*.png` and `screenshots/demo.gif` as the `capture` artifact.

## Local emulator

With an emulator running:

```sh
flutter drive --driver test_driver/integration_test.dart --target integration_test/screenshot_test.dart -d emulator-5554
flutter drive --driver test_driver/integration_test.dart --target integration_test/demo_test.dart -d emulator-5554
```
