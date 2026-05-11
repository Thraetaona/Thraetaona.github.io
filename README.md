# Innervate Sample Analysis Site

Minimal Jekyll site for the MATH-4025 job-application sample analysis.

Pages:

- `index.md`: home page with contact information and a link to the analysis.
- `analysis.md`: reproducible sample project analysis for `Innervate`.

Regenerate analysis artifacts:

```bash
pip install -r requirements.txt
python scripts/evaluate_innervate.py
```

Serve locally with Jekyll, if available:

```bash
bundle exec jekyll serve
```
