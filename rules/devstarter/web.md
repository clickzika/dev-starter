# Web (HTML/CSS/JS) Coding Rules

## HTML
- Use semantic elements: `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<header>`, `<footer>`
- Every image needs `alt` text; decorative images use `alt=""`
- Forms: every input has a `<label>` linked via `for`/`id`; never label-by-placeholder only
- Use `<button>` for actions, `<a>` for navigation — never `<div onClick>`

## CSS
- Use CSS custom properties (variables) for design tokens (colors, spacing, type scales)
- Mobile-first: write base styles for small screens, add `min-width` breakpoints for larger
- Avoid `!important` — fix specificity instead
- Use logical properties (`margin-inline`, `padding-block`) for i18n-safe layouts
- Prefer CSS Grid for 2D layout, Flexbox for 1D

## JavaScript (vanilla)
- Use `const` by default, `let` when reassignment is needed; never `var`
- Prefer `async/await` over `.then()` chains; always handle rejections
- Use `addEventListener` not inline `onclick` attributes
- Sanitize user-generated content before inserting into DOM — use `textContent`, not `innerHTML`

## Accessibility (a11y)
- WCAG 2.1 AA minimum: 4.5:1 contrast for text, 3:1 for UI components
- All interactive elements keyboard-accessible: `tabindex`, focus styles visible
- Use ARIA roles/attributes only when native semantics are insufficient
- Test with screen reader (NVDA/VoiceOver) for new interactive components

## Performance
- Lazy-load images with `loading="lazy"`; defer non-critical scripts
- Avoid layout thrashing: batch DOM reads before writes
- Target Core Web Vitals: LCP < 2.5s, CLS < 0.1, FID/INP < 200ms
