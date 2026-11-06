# myPortfolio — image de production du site statique
# Build : node (devdeps + astro build), runtime : nginx:alpine (fichiers statiques)
# Le PDF du CV (compilé par le workflow deploy-pdf.yml depuis latex/my_cv.tex)
# est téléchargé par la CI du site (dernière GitHub Release) dans public/pdf/
# avant `astro build` — jamais commité dans le repo.

FROM node:22-slim AS build
WORKDIR /app

# Dépendances d'abord (meilleur cache)
COPY package.json package-lock.json* ./
RUN npm ci --no-audit --no-fund

# Sources
COPY . .
RUN npm run build

FROM nginx:stable-alpine AS runtime
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
