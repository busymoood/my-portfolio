import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { glob } from 'astro/loaders';

const projects = defineCollection({
  loader: glob({ pattern: '**/index.md', base: './content/projects' }),
  schema: ({ image }) =>
    z.object({
      title: z.string().min(1, 'title is required'),
      summary: z
        .string()
        .min(1, 'summary is required')
        .max(160, 'summary must fit on one line (160 chars max)'),
      // Content identifiers are language-neutral; labels are translated in the UI.
      status: z.enum(['actif', 'archive']),
      period: z.string().min(1, 'period is required (e.g. "2025" or "2024 — present")'),
      languages: z.array(z.string().min(1)).min(1, 'languages must list at least one language'),
      repo: z.httpUrl('repo must be a full https:// URL'),
      demo: z.httpUrl('demo must be a full https:// URL or null').nullable(),
      // Image existence+resolution is enforced by `image()`; the 16:9 ratio is
      // enforced by scripts/check-covers.mjs (npm run lint), because in the
      // content-layer pipeline `image()` metadata (width/height) is only
      // resolved later, at build/render time — a zod refine on it would
      // silently never run and make `astro check` fail.
      cover: image(),
    }),
});

const about = defineCollection({
  loader: glob({ pattern: '**/index.md', base: './content/about' }),
  schema: z.object({
    title: z.string().min(1, 'title is required'),
    summary: z
      .string()
      .min(1, 'summary is required')
      .max(160, 'summary must fit on one line (160 chars max)'),
  }),
});

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './content/blog' }),
  schema: z.object({
    title: z.string().min(1, 'title is required'),
    // A post lives in exactly one language and is built under exactly one URL
    // (`/blog/...` for EN, `/fr/blog/...` for FR). No duplicated content.
    lang: z.enum(['en', 'fr']),
    date: z.coerce.date(),
    tags: z.array(z.string().min(1)),
    summary: z.string().min(1, 'summary is required'),
    draft: z.boolean(),
  }),
});

export const collections = { projects, about, blog };
