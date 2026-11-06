/** Localised date formatting for the blog (posts are single-language, the UI is bilingual). */
export function formatDate(date: Date, lang: 'en' | 'fr'): string {
  return new Intl.DateTimeFormat(lang === 'fr' ? 'fr-FR' : 'en-GB', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
  }).format(date);
}
