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

FROM nginxinc/nginx-unprivileged:1.30.6-alpine3.24-slim@sha256:4ac59c85c8c46d9e91eaabd2122cda4923ba380cf11f4138e389f069bcdc77a3 AS production
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
