#!/bin/bash

flutter clean
rm -rf \
    lib/data/models.freezed.dart \
    lib/data/models.g.dart \
    lib/core/config.g.dart \
    lib/core/config.freezed.dart
cd android
./gradlew clean
cd ..
flutter pub get
dart run build_runner build --delete-conflicting-outputs
