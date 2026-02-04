FROM haskell:9.6 as builder

WORKDIR /app

COPY dead-poet.cabal /app/
RUN cabal update
RUN cabal build --only-dependencies

COPY app /app/app
RUN cabal build dead-poet-server

RUN mkdir -p /out/bin \
  && cp $(cabal list-bin dead-poet-server) /out/bin/dead-poet-server

FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates libgmp10 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /out/bin/dead-poet-server /app/dead-poet-server

EXPOSE 8080
CMD ["/app/dead-poet-server"]
