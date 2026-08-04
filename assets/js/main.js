
(() => {
  const header = document.querySelector('[data-header]');
  const toggle = document.querySelector('[data-menu-toggle]');
  const menu = document.querySelector('[data-menu]');
  const onScroll = () => header?.classList.toggle('is-scrolled', window.scrollY > 18);
  onScroll();
  window.addEventListener('scroll', onScroll, { passive: true });
  if (toggle && menu) {
    toggle.addEventListener('click', () => {
      const open = toggle.getAttribute('aria-expanded') === 'true';
      toggle.setAttribute('aria-expanded', String(!open));
      menu.classList.toggle('is-open', !open);
    });
    menu.querySelectorAll('a').forEach(link => link.addEventListener('click', () => {
      toggle.setAttribute('aria-expanded', 'false');
      menu.classList.remove('is-open');
    }));
    document.addEventListener('keydown', e => {
      if (e.key === 'Escape') {
        toggle.setAttribute('aria-expanded', 'false');
        menu.classList.remove('is-open');
      }
    });
  }
  document.querySelectorAll('[data-year]').forEach(el => el.textContent = new Date().getFullYear());
})();
