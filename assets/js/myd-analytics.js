/* MYD analytics_instrumentation; independent of GEO content intervention. */
(function () {
  'use strict';
  var here = new URL(window.location.href);
  if (here.protocol !== 'https:' ||
      ['re2omyd.com', 'www.re2omyd.com'].indexOf(here.hostname) === -1) return;
  if (window.__mydAnalyticsStarted) return;
  var qa = here.searchParams.get('myd_qa') === '1';
  try {
    if (qa) window.sessionStorage.setItem('myd_analytics_qa', '1');
    qa = qa || window.sessionStorage.getItem('myd_analytics_qa') === '1';
  } catch (_) {}
  if (qa || navigator.webdriver) return;
  window.__mydAnalyticsStarted = true;
  window.dataLayer = window.dataLayer || [];
  window.gtag = window.gtag || function () { window.dataLayer.push(arguments); };
  var config = {
    page_location: here.origin + here.pathname,
    page_referrer: '',
    allow_google_signals: false,
    allow_ad_personalization_signals: false,
    send_page_view: true
  };
  // Preserve the observed referring origin, without private paths or query strings.
  try {
    var ref = new URL(document.referrer);
    if (ref.protocol === 'https:' || ref.protocol === 'http:') config.page_referrer = ref.origin + '/';
  } catch (_) {}
  ['source', 'medium'].forEach(function (name) {
    var value = here.searchParams.get('utm_' + name);
    if (value && /^[a-zA-Z0-9._-]{1,80}$/.test(value)) config['campaign_' + name] = value;
  });
  window.gtag('js', new Date());
  window.gtag('config', 'G-9K07PY6M5C', config);
  var script = document.createElement('script');
  script.async = true;
  script.src = 'https://www.googletagmanager.com/gtag/js?id=G-9K07PY6M5C';
  document.head.appendChild(script);
}());
