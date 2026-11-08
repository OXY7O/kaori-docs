# syntax=docker/dockerfile:1.7
FROM node:22.23.2-alpine AS build
WORKDIR /build
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --no-audit --no-fund
COPY docusaurus.config.ts sidebars.ts tsconfig.json .prettierrc.json ./
COPY src ./src
COPY static ./static
COPY content ./content
# Only the reviewed publication map enters this build stage from internal docs/.
# Native snapshot directories are empty until accepted application release.
COPY versions.json ./
COPY versioned_docs ./versioned_docs
COPY versioned_sidebars ./versioned_sidebars
COPY docs/PUBLISHED_VERSIONS.json ./docs/PUBLISHED_VERSIONS.json
RUN npm run check && npm run build && test -s build/index.html

FROM ghcr.io/nginx/nginx-unprivileged:1.30.6-alpine3.24-slim@sha256:016193c18ef1ce19dc2229d3305f69af1b05e0bc0e8fe6ee724a58bd305f3855 AS production
ARG APP_BUILD_SHA
ARG APP_VERSION
ARG APP_BUILD_DATE
ARG APP_LICENSE=NOASSERTION
LABEL org.opencontainers.image.source="https://github.com/OXY7O/kaori-docs" \
      org.opencontainers.image.title="KAORI Docs" \
      org.opencontainers.image.description="Static read-only KAORI product documentation" \
      org.opencontainers.image.documentation="https://docs.kaori.cloud" \
      org.opencontainers.image.licenses="${APP_LICENSE}" \
      org.opencontainers.image.revision="${APP_BUILD_SHA}" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.created="${APP_BUILD_DATE}"
COPY --from=build /build/build/ /usr/share/nginx/html/
COPY deploy/server/nginx.conf /etc/nginx/conf.d/default.conf
USER 101:101
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1
