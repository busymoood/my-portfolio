import type { CollectionEntry } from 'astro:content';

/** Strip the trailing `/index` the glob loader adds for `content/projects/<slug>/index.md`. */
export function projectSlug(project: CollectionEntry<'projects'>): string {
  return project.id.replace(/\/index$/, '');
}

/** Collection ids for blog posts are already flat, file-name based slugs. */
export function postSlug(post: CollectionEntry<'blog'>): string {
  return post.id;
}
