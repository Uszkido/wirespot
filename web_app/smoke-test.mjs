const dashboardUrl = process.env.WIRESPOT_DASHBOARD_URL || 'https://wirespot.web.app/';
const apiUrl = process.env.WIRESPOT_API_URL || 'https://wirespot-api.onrender.com';

async function fetchChecked(url) {
  const response = await fetch(url, { redirect: 'follow' });
  if (!response.ok) {
    throw new Error(`${url} returned HTTP ${response.status}`);
  }
  return response;
}

const dashboard = await fetchChecked(dashboardUrl);
const html = await dashboard.text();
for (const marker of ['WireSpot Cloud', 'app.js', 'auth-email-login']) {
  if (!html.includes(marker)) {
    throw new Error(`Dashboard is missing expected marker: ${marker}`);
  }
}
const appScript = await fetchChecked(new URL('app.js', dashboard.url));
const appSource = await appScript.text();
for (const marker of ['webCan', 'guardWebPermission', 'session.role']) {
  if (!appSource.includes(marker)) {
    throw new Error(`Dashboard app script is missing RBAC marker: ${marker}`);
  }
}

const health = await fetchChecked(`${apiUrl.replace(/\/$/, '')}/health`);
const healthBody = await health.json();
if (healthBody.status !== 'ok') {
  throw new Error(`API health did not report status=ok: ${JSON.stringify(healthBody)}`);
}

if (process.env.WIRESPOT_REQUIRE_PRODUCTION === 'true' &&
    healthBody.productionReady !== true) {
  const gaps = Array.isArray(healthBody.productionConfigurationGaps)
    ? healthBody.productionConfigurationGaps.join(', ')
    : 'unknown configuration gaps';
  throw new Error(
    `API is not production-ready. Configure: ${gaps}. ` +
    `Reported mode: ${healthBody.authenticationMode ?? 'unknown'}.`,
  );
}

const corsProbe = await fetch(`${apiUrl.replace(/\/$/, '')}/health`, {
  headers: { Origin: new URL(dashboardUrl).origin },
});
const allowedOrigin = corsProbe.headers.get('access-control-allow-origin');
if (allowedOrigin !== '*' && allowedOrigin !== new URL(dashboardUrl).origin) {
  throw new Error(
    `API CORS does not allow the dashboard origin (${allowedOrigin ?? 'missing'}).`,
  );
}

console.log(`WireSpot dashboard reachable: ${dashboard.url}`);
console.log(`WireSpot API reachable: ${apiUrl}`);
console.log(
  `API mode: ${healthBody.authenticationMode}; productionReady=${healthBody.productionReady}`,
);
