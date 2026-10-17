# Official Dart SDK image for building
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
# Dart Frog generates the production server from the routes directory.
# Keep the generator aligned with the dart_frog runtime locked in
# pubspec.lock. The latest CLI may generate code for a newer API.
RUN dart pub global deactivate dart_frog_cli || true
RUN dart pub global activate dart_frog_cli 1.2.6 --overwrite
ENV PATH="/root/.pub-cache/bin:${PATH}"
RUN dart_frog --version && dart_frog build
# The generated build contains a machine-specific package config. Runtime
# resolves dependencies from the copied lockfile instead.
RUN rm -rf build/.dart_tool

# Ultra-lightweight runtime image (< 50MB RAM footprint)
FROM dart:stable AS runtime
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get --offline
COPY --from=build /app/build /app/build

EXPOSE 8080
CMD ["dart", "run", "build/bin/server.dart"]
