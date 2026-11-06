import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://ficaud.xyz',
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'fr'],
    routing: {
      prefixDefaultLocale: false,
    },
  },
});
