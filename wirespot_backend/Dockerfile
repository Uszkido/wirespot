# Official Dart SDK image for building
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Ultra-lightweight runtime image (< 50MB RAM footprint)
FROM subosito/dart:latest AS runtime
WORKDIR /app
COPY --from=build /app/bin/server /app/bin/server

EXPOSE 8080
CMD ["/app/bin/server"]
