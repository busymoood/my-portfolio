// Enforces the content rule "every project `cover` is a 16:9 image".
// Runs outside Astro because, in the content-layer pipeline, `image()`
// metadata (width/height) is resolved late — a zod refine on it never
// receives real dimensions and would make `astro check` fail.
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';
import sharp from 'sharp';

const projectsDir = path.resolve('content/projects');
const errors = [];
const unchecked = [];

const slugs = (await readdir(projectsDir, { withFileTypes: true }))
  .filter((d) => d.isDirectory())
  .map((d) => d.name);

for (const slug of slugs) {
  const entryPath = path.join(projectsDir, slug, 'index.md');
  let source;
  try {
    source = await readFile(entryPath, 'utf8');
  } catch {
    errors.push(`${slug}: missing content/projects/${slug}/index.md`);
    continue;
  }

  const coverMatch = source.match(/^cover:\s*['"]?(\.\/[^'"\n]+)['"]?\s*$/m);
  if (!coverMatch) {
    errors.push(`${slug}: no \`cover: "./…"\` in frontmatter`);
    continue;
  }

  const coverPath = path.join(projectsDir, slug, coverMatch[1]);
  try {
    const { width, height, format } = await sharp(coverPath).metadata();
    if (!width || !height) {
      unchecked.push(`${slug}: ${coverMatch[1]} — unreadable dimensions`);
      continue;
    }
    const ratio = Math.abs(width / height - 16 / 9);
    if (ratio >= 0.02) {
      errors.push(
        `${slug}: ${coverMatch[1]} is ${width}×${height} (${format}) — expected 16:9 (` +
          `1280×720 works). Astro content conventions in AGENTS.md.`,
      );
    }
  } catch (err) {
    errors.push(`${slug}: ${coverMatch[1]} — unreadable image (${err.message})`);
  }
}

if (unchecked.length > 0) {
  console.warn('Cover dimensions could not be checked (check manually):');
  for (const line of unchecked) console.warn('  ' + line);
}

if (errors.length > 0) {
  console.error('Cover image validation failed — 16:9 required per AGENTS.md:');
  for (const line of errors) console.error('  ✗ ' + line);
  process.exit(1);
}

console.log(`covers/${slugs.length} projects checked — all covers are 16:9.`);
