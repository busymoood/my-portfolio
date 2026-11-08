#!/usr/bin/env python3
"""Generate the 16:9 dark cover banner of a project or post.

Reads `content/<section>/<slug>/cover.json`, renders it through
`scripts/cover/template.html` (site tokens + self-hosted IBM Plex fonts)
and saves the banner next to the JSON. A per-project `cover-focal.html`
(optional) provides the focal-zone markup; a small 400px-wide preview is
written to /tmp so the mobile rendering can be checked by eye.

Usage:
    python3 scripts/cover/make_cover.py relic-core ovalbot
    python3 scripts/cover/make_cover.py --all
    python3 scripts/cover/make_cover.py ovalbot --no-preview --preview-dir <dir>
"""

from __future__ import annotations

import argparse
import json
import os
import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
PROJECTS_DIR = REPO / "content" / "projects"
BLOG_DIR = REPO / "content" / "blog"
TEMPLATE = REPO / "scripts" / "cover" / "template.html"
TOKENS = REPO / "src" / "styles" / "tokens.css"
FONTS_DIR = REPO / "public" / "fonts"

VIEWPORT = {"width": 1280, "height": 720}
FONT_RE = re.compile(r"(--color-[a-z-]+):\s*([^;]+);")


def load_tokens() -> str:
    """Pull the `--color-*` values of the dark `:root` block in tokens.css."""
    source = TOKENS.read_text(encoding="utf-8")
    root_block = re.search(r":root\s*\{(.*?)\}", source, re.S).group(1)
    vars_ = FONT_RE.findall(root_block)
    if not vars_:
        raise SystemExit(f"no --color-* variables found in {TOKENS}")
    return "\n".join(f"  {name}: {value};" for name, value in vars_)


def find_chromium() -> str | None:
    """Locate a chromium binary from the Playwright browsers cache.

    The dev container sets PLAYWRIGHT_BROWSERS_PATH (persisted in the
    `devbox-home` volume); fall back to the legacy /opt/ms-playwright path.
    """
    root = Path(os.environ.get("PLAYWRIGHT_BROWSERS_PATH", "/opt/ms-playwright"))
    if not root.is_dir():
        return None
    candidates = sorted(root.glob("chromium-*/chrome-linux*/chrome"))
    return str(candidates[-1]) if candidates else None


def resolve_config(project_dir: Path) -> dict:
    config = json.loads((project_dir / "cover.json").read_text(encoding="utf-8"))
    focal_file = config.pop("focalHtmlFile", None)
    if focal_file and not config.get("focalHtml"):
        config["focalHtml"] = (project_dir / focal_file).read_text(encoding="utf-8")
    return config


def render(project_dir: Path, out_path: Path, preview: bool, preview_dir: Path, quality: int) -> None:
    from playwright.sync_api import sync_playwright

    template = TEMPLATE.read_text(encoding="utf-8")
    config = resolve_config(project_dir)

    font_base = FONTS_DIR.resolve().as_uri()
    html = (
        template
        .replace("__FONTS__", font_base)
        .replace("__BASE__", project_dir.resolve().as_uri() + "/")
        .replace("__TOKENS__", load_tokens())
        .replace("__CONFIG__", json.dumps(config).replace("</", "<\\/"))
    )

    work_html = preview_dir / f"{project_dir.name}.render.html"
    work_html.write_text(html, encoding="utf-8")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    is_jpeg = out_path.suffix.lower() in {".jpg", ".jpeg"}

    executable = find_chromium()
    with sync_playwright() as p:
        launch = {"args": ["--no-sandbox", "--force-color-profile=srgb", "--font-render-hinting=none"]}
        if executable:
            launch["executable_path"] = executable
        browser = p.chromium.launch(**launch)
        try:
            context = browser.new_context(viewport=VIEWPORT, device_scale_factor=2)
            page = context.new_page()
            page.goto(work_html.resolve().as_uri())
            page.wait_for_function("document.fonts.status === 'loaded'")
            page.wait_for_timeout(80)
            page.screenshot(
                path=str(out_path),
                type="jpeg" if is_jpeg else "png",
                **({"quality": quality} if is_jpeg else {}),
            )
            if preview:
                mobile = preview_dir / f"{project_dir.name}-mobile.png"
                prev_ctx = browser.new_context(viewport={"width": 400, "height": 225}, device_scale_factor=3)
                prev_page = prev_ctx.new_page()
                prev_page.goto(work_html.resolve().as_uri())
                prev_page.wait_for_function("document.fonts.status === 'loaded'")
                # Scale the whole 1280x720 canvas down to the card width used
                # on mobile, like `object-fit` would in the real card.
                prev_page.add_style_tag(content="html { zoom: 0.3125; }")
                prev_page.wait_for_timeout(60)
                prev_page.screenshot(path=str(mobile))
                prev_ctx.close()

            # Guard: the focal asset and the left column must stay inside their
            # box, otherwise they overlap the header or the stats.
            overflow = page.evaluate(
                """() => {
                  const zone = document.querySelector('.cover-focal');
                  const area = zone.getBoundingClientRect();
                  const bad = [...zone.children].some((el) => {
                    const box = el.getBoundingClientRect();
                    if (box.width === 0 || box.height === 0) return false;
                    return box.top < area.top - 1 || box.bottom > area.bottom + 1 ||
                           box.left < area.left - 1 || box.right > area.right + 1;
                  });
                  const left = document.querySelector('.cover-left');
                  return { focal: bad, left: left.scrollHeight > left.clientHeight + 1 };
                }"""
            )
            if overflow.get("focal"):
                print(f"  warning: focal content overflows its zone ({project_dir.name})")
            if overflow.get("left"):
                print(f"  warning: left column overflows its zone ({project_dir.name})")
        finally:
            browser.close()


def covers() -> list[tuple[Path, Path]]:
    """Every folder holding a cover.json (projects first, then blog)."""
    results = []
    for base in (PROJECTS_DIR, BLOG_DIR):
        if not base.is_dir():
            continue
        for entry in sorted(base.iterdir()):
            config_path = entry / "cover.json"
            if not entry.is_dir() or not config_path.exists():
                continue
            results.append((entry, resolve_config_json_out(config_path)))
    return results


def resolve_config_json_out(config_path: Path) -> Path:
    data = json.loads(config_path.read_text(encoding="utf-8"))
    out_name = data.get("out", "cover.png")
    return config_path.parent / out_name


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("slugs", nargs="*", help="slug(s) under content/projects (or a blog folder)")
    parser.add_argument("--all", action="store_true", help="regenerate every cover.json found")
    parser.add_argument("--no-preview", action="store_true", help="skip the 400px mobile preview")
    parser.add_argument("--quality", type=int, default=92, help="jpeg quality if the output is .jpg")
    parser.add_argument(
        "--preview-dir",
        default="/tmp/opencode/cover-preview",
        help="where the mobile previews go",
    )
    args = parser.parse_args()

    preview_dir = Path(args.preview_dir)
    preview_dir.mkdir(parents=True, exist_ok=True)

    targets = []
    if args.all:
        for project_dir, out_path in covers():
            targets.append((project_dir, out_path))
    else:
        if not args.slugs:
            parser.error("give one or more slugs, or --all")
        for slug in args.slugs:
            project_dir = PROJECTS_DIR / slug
            if not project_dir.is_dir():
                project_dir = BLOG_DIR / slug
            if not project_dir.is_dir():
                parser.error(f"no content folder for slug '{slug}'")
            config_path = project_dir / "cover.json"
            if not config_path.exists():
                parser.error(f"{config_path} does not exist")
            targets.append((project_dir, resolve_config_json_out(config_path)))

    for project_dir, out_path in targets:
        render(project_dir, out_path, preview=not args.no_preview, preview_dir=preview_dir, quality=args.quality)
        print(f"cover written: {out_path.relative_to(REPO) if out_path.is_relative_to(REPO) else out_path}")


if __name__ == "__main__":
    main()
