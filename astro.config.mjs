import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://ficaud.xyz',
  // `npm run dev` dans le conteneur : écouter 0.0.0.0 pour que le port 4321
  // soit joignable depuis l'hôte (docker-compose) et le forwarding VS Code.
  server: { host: true },
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'fr'],
    routing: {
      prefixDefaultLocale: false,
    },
  },
});
