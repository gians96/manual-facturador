# syntax=docker/dockerfile:1

##############################################
# Etapa 1 — Build del sitio estático (Docusaurus)
##############################################
FROM oven/bun:1.2.19 AS build

WORKDIR /app

# git es necesario para las opciones showLastUpdateTime/showLastUpdateAuthor
# de Docusaurus (leen el historial). Sin git solo emite warnings, pero así
# el sitio queda idéntico al de desarrollo.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# 1) Solo manifiesto + lockfile primero → mejor cache de dependencias
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# 2) Resto del proyecto y build de producción
#    (onBrokenLinks: "throw" hará fallar el build si hay enlaces rotos)
COPY . .
RUN bun run build

##############################################
# Etapa 2 — Servir con nginx (imagen final liviana)
##############################################
FROM nginx:1.27-alpine AS serve

# Config a medida para el estático de Docusaurus (URLs limpias, gzip, cache)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar solo el sitio compilado desde la etapa de build
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

# Healthcheck simple (busybox wget viene en la imagen alpine)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO /dev/null http://127.0.0.1/ || exit 1

# La imagen base de nginx ya arranca con: nginx -g 'daemon off;'
