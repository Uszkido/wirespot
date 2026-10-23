const dashboardUrl = process.env.WIRESPOT_DASHBOARD_URL || 'https://wirespot.web.app/';
const apiUrl = process.env.WIRESPOT_API_URL || 'https://wirespot-api.onrender.com';

async function fetchChecked(url) {
  const response = await fetch(url, { redirect: 'follow' });
  if (!response.ok) {
    throw new Error(`${url} returned HTTP ${response.status}`);
  }
  return response;
}

async function jsonRequest(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      'content-type': 'application/json',
      ...(options.headers ?? {}),
    },
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(`${url} returned HTTP ${response.status}: ${JSON.stringify(body)}`);
  }
  return body;
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

// Optional authenticated round-trip. Keep credentials out of the repository;
// CI or an operator can provide a dedicated smoke account through environment
// variables when validating a hosted deployment. The default smoke test stays
// read-only and therefore remains safe for public Firebase deploys.
const smokeEmail = process.env.WIRESPOT_SMOKE_EMAIL;
const smokePassword = process.env.WIRESPOT_SMOKE_PASSWORD;
if (smokeEmail || smokePassword) {
  if (!smokeEmail || !smokePassword) {
    throw new Error('Set both WIRESPOT_SMOKE_EMAIL and WIRESPOT_SMOKE_PASSWORD.');
  }
  const login = await jsonRequest(`${apiUrl.replace(/\/$/, '')}/api/v1/auth/login`, {
    method: 'POST',
    body: JSON.stringify({ email: smokeEmail, password: smokePassword }),
  });
  const token = login.accessToken;
  if (typeof token !== 'string' || token.length === 0) {
    throw new Error('Hosted login did not return an access token.');
  }
  const authorization = { authorization: `Bearer ${token}` };
  const routers = await jsonRequest(`${apiUrl.replace(/\/$/, '')}/api/v1/routers`, {
    headers: authorization,
  });
  if (!Array.isArray(routers.routers)) {
    throw new Error('Hosted router sync response did not contain a routers list.');
  }

  // Optional write/read verification for a dedicated smoke workspace.
  if (process.env.WIRESPOT_SMOKE_ROUTER_JSON) {
    let router;
    try {
      router = JSON.parse(process.env.WIRESPOT_SMOKE_ROUTER_JSON);
    } catch (error) {
      throw new Error(`WIRESPOT_SMOKE_ROUTER_JSON is not valid JSON: ${error}`);
    }
    const sync = await jsonRequest(`${apiUrl.replace(/\/$/, '')}/api/v1/routers`, {
      method: 'POST',
      headers: authorization,
      body: JSON.stringify({ routers: [router] }),
    });
    if (sync.status !== 'success' || sync.syncedCount !== 1) {
      throw new Error(`Hosted router write did not sync exactly one record: ${JSON.stringify(sync)}`);
    }
    const refreshed = await jsonRequest(`${apiUrl.replace(/\/$/, '')}/api/v1/routers`, {
      headers: authorization,
    });
    if (!refreshed.routers.some((item) => item.id === router.id)) {
      throw new Error('Hosted router write/read round-trip did not return the record.');
    }
  }

  if (process.env.WIRESPOT_SMOKE_TELEMETRY_JSON) {
    let telemetry;
    try {
      telemetry = JSON.parse(process.env.WIRESPOT_SMOKE_TELEMETRY_JSON);
    } catch (error) {
      throw new Error(`WIRESPOT_SMOKE_TELEMETRY_JSON is not valid JSON: ${error}`);
    }
    const accepted = await jsonRequest(`${apiUrl.replace(/\/$/, '')}/api/v1/telemetry`, {
      method: 'POST',
      headers: authorization,
      body: JSON.stringify(telemetry),
    });
    if (accepted.status !== 'accepted' || accepted.received < 1) {
      throw new Error(`Hosted telemetry write was not accepted: ${JSON.stringify(accepted)}`);
    }
    const telemetryRead = await jsonRequest(
      `${apiUrl.replace(/\/$/, '')}/api/v1/telemetry?limit=1`,
      { headers: authorization },
    );
    if (!Array.isArray(telemetryRead.telemetry) || telemetryRead.telemetry.length < 1) {
      throw new Error('Hosted telemetry write/read round-trip returned no frame.');
    }
  }
}

console.log(`WireSpot dashboard reachable: ${dashboard.url}`);
console.log(`WireSpot API reachable: ${apiUrl}`);
console.log(
  `API mode: ${healthBody.authenticationMode}; productionReady=${healthBody.productionReady}`,
);
if (smokeEmail && smokePassword) {
  console.log('Authenticated cloud sync round-trip: passed');
}
if (smokeEmail && smokePassword && process.env.WIRESPOT_SMOKE_TELEMETRY_JSON) {
  console.log('Authenticated telemetry round-trip: passed');
}
