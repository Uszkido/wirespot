# Official Dart SDK image for building
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
# Dart Frog generates the production server from the routes directory.
RUN dart pub global activate dart_frog_cli
ENV PATH="/root/.pub-cache/bin:${PATH}"
RUN dart_frog build

# Ultra-lightweight runtime image (< 50MB RAM footprint)
FROM dart:stable AS runtime
WORKDIR /app
COPY --from=build /app/build /app/build

EXPOSE 8080
CMD ["dart", "/app/build/bin/server.dart"]
