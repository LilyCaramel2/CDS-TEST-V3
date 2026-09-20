# CDS-TEST-V3

Test repository for the Caramel Digital Studio website prototype.

## Live test site

https://lilycaramel2.github.io/CDS-TEST-V3/

## Automatic deployment

Every push to `main` runs `.github/workflows/deploy-pages.yml` and publishes the repository to GitHub Pages. The workflow can also be started manually from the GitHub Actions tab.

## Pages

- Home
- About
- Services
- Winter Special
- Blog
- Contact

## Local preview

```bash
python3 -m http.server 4173 --bind 127.0.0.1
```

The site is a static prototype at this stage. The contact form currently uses `mailto:` and is intended to be replaced by the full-stack enquiry workflow in a later test iteration.
