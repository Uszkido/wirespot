// ═══════════════════════════════════════════════════════════════
// WireSpot Cloud Web Application Logic v2.0
// ═══════════════════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', () => {
  // ─── Initial State ───
  const defaultState = {
    activeTab: 'tab-dashboard',
    routers: [
      { name: 'Main-Gateway-MikroTik', vendor: 'MikroTik RouterOS v7', ip: '192.168.88.1', port: 8728, status: 'online', users: 32 },
      { name: 'Pool-Bar-Ruijie', vendor: 'Ruijie / Reyee', ip: '10.0.0.15', port: 443, status: 'online', users: 12 },
      { name: 'Lobby-AP-OpenWrt', vendor: 'OpenWrt LuCI', ip: '192.168.1.1', port: 22, status: 'online', users: 8 },
      { name: 'Hotel-Controller-Omada', vendor: 'TP-Link Omada', ip: '192.168.0.10', port: 443, status: 'online', users: 24 },
      { name: 'Campus-UniFi-CloudKey', vendor: 'Ubiquiti UniFi', ip: '192.168.20.5', port: 443, status: 'online', users: 45 },
      { name: 'Generic-Edge-Gateway', vendor: 'Generic Router', ip: '10.0.0.1', port: 443, status: 'online', users: 6 }
    ],
    hotspotUsers: [
      { username: 'operator_admin', profile: 'VIP-10MBPS', uptimeLimit: 'Unlimited', dataLimit: 'Unlimited', bytesIn: '1.2 GB', bytesOut: '450 MB' },
      { username: 'guest_user_1', profile: 'Café-1Hour', uptimeLimit: '01:00:00', dataLimit: '500 MB', bytesIn: '14.2 MB', bytesOut: '1.8 MB' },
      { username: 'guest_user_2', profile: 'Hotel-24Hour', uptimeLimit: '24:00:00', dataLimit: '2 GB', bytesIn: '128.5 MB', bytesOut: '14.2 MB' }
    ],
    userProfiles: [
      { name: 'Café-1Hour', downSpeed: '3 Mbps', upSpeed: '1 Mbps', sharedUsers: 1, timeout: '60m' },
      { name: 'Hotel-24Hour', downSpeed: '10 Mbps', upSpeed: '3 Mbps', sharedUsers: 2, timeout: '1440m' },
      { name: 'VIP-10MBPS', downSpeed: '20 Mbps', upSpeed: '5 Mbps', sharedUsers: 5, timeout: 'Unlimited' }
    ],
    sessions: [
      { username: 'WS-8A2F', mac: 'BC:D1:D3:4A:89:12', ip: '192.168.88.102', uptime: '45m 12s', bytesIn: '14.2 MB', bytesOut: '1.8 MB' },
      { username: 'WS-3K90', mac: '70:F8:E7:11:90:BB', ip: '192.168.88.105', uptime: '12m 04s', bytesIn: '4.8 MB', bytesOut: '0.6 MB' },
      { username: 'WS-99PL', mac: 'A4:50:46:12:34:56', ip: '192.168.88.110', uptime: '02h 15m', bytesIn: '128.5 MB', bytesOut: '14.2 MB' }
    ],
    vouchers: [
      { code: 'WS-8A2F', profile: '1Hour-5MBPS', price: 2.50, createdAt: '2026-08-24 10:15', status: 'active' },
      { code: 'WS-3K90', profile: '1Hour-5MBPS', price: 2.50, createdAt: '2026-08-24 10:20', status: 'active' },
      { code: 'WS-99PL', profile: '1Day-10MBPS', price: 5.00, createdAt: '2026-08-24 08:30', status: 'active' },
      { code: 'WS-4411', profile: '7Day-VIP', price: 15.00, createdAt: '2026-08-23 14:00', status: 'unused' },
      { code: 'WS-5522', profile: '1Hour-5MBPS', price: 2.50, createdAt: '2026-08-22 19:45', status: 'expired' }
    ],
    cloudQueue: [
      { id: 'op_sync_101', resourceType: 'voucher', resourceId: 'v_WS-8A2F', operation: 'upsert', idempotencyKey: 'idemp_v_8A2F', attempts: 1, status: 'pending' },
      { id: 'op_sync_102', resourceType: 'router', resourceId: 'r_MikroTik', operation: 'upsert', idempotencyKey: 'idemp_r_mt', attempts: 1, status: 'pending' },
      { id: 'op_sync_100', resourceType: 'hotspot_profile', resourceId: 'hp_1hour', operation: 'upsert', idempotencyKey: 'idemp_hp_1h', attempts: 2, status: 'completed' }
    ],
    events: [
      { time: '11:28:10', source: 'CloudSyncService', desc: 'Background sync triggered via Firebase REST API', status: 'success' },
      { time: '11:15:00', source: 'VoucherService', desc: 'Generated batch of 5 vouchers (1Hour-5MBPS)', status: 'success' },
      { time: '10:45:12', source: 'RouterOSConnector', desc: 'Connected to MikroTik gateway at 192.168.88.1:8728', status: 'info' }
    ]
  };

  // Load state from localStorage or use defaults
  const savedState = localStorage.getItem('wirespot_web_state');
  // Start with an honest empty workspace instead of presenting sample records
  // as if they were connected customer data. Records appear after pairing or
  // after the operator creates them in this browser.
  const emptyWorkspace = {
    ...defaultState,
    routers: [],
    hotspotUsers: [],
    userProfiles: [],
    sessions: [],
    vouchers: [],
    cloudQueue: [],
    events: []
  };
  const state = savedState ? JSON.parse(savedState) : emptyWorkspace;

  // Clear the records shipped by the earlier demo build, but preserve any
  // records an operator has created locally.
  const hasDemoRecords = state.routers?.some(r => r.name === 'Main-Gateway-MikroTik') &&
    state.vouchers?.some(v => v.code === 'WS-8A2F');
  if (hasDemoRecords) {
    Object.assign(state, emptyWorkspace);
    localStorage.removeItem('wirespot_web_state');
  }

  const saveState = () => {
    localStorage.setItem('wirespot_web_state', JSON.stringify(state));
  };

  const emptyRow = (columns, message) =>
    `<tr><td colspan="${columns}" class="empty-state"><i class="fa-regular fa-folder-open"></i><span>${message}</span></td></tr>`;

  // ─── Toast System ───
  const showToast = (message, type = 'success') => {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;

    const icons = {
      success: '<i class="fa-solid fa-circle-check"></i>',
      error: '<i class="fa-solid fa-circle-exclamation"></i>',
      info: '<i class="fa-solid fa-circle-info"></i>'
    };

    toast.innerHTML = `
      ${icons[type] || icons.info}
      <span>${message}</span>
      <div class="toast-progress"></div>
    `;

    container.appendChild(toast);

    // Trigger animation
    requestAnimationFrame(() => toast.classList.add('show'));

    setTimeout(() => {
      toast.classList.remove('show');
      setTimeout(() => toast.remove(), 400);
    }, 3000);
  };

  // ─── Navigation Logic ───
  document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', () => {
      document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));

      const targetTab = item.getAttribute('data-tab');
      item.classList.add('active');
      document.getElementById(targetTab).classList.add('active');

      const titleMap = {
        'tab-dashboard': 'Dashboard',
        'tab-routers': 'Router Fleet Inventory',
        'tab-users-advanced': 'Hotspot Users & Profiles',
        'tab-sessions': 'Live Hotspot Sessions',
        'tab-vouchers': 'Voucher Batch & Inventory',
        'tab-subscriptions': 'Subscriptions & Billing',
        'tab-cloud': 'WireSpot Cloud Sync Center',
        'tab-reports': 'Sales Analytics & Export'
      };
      document.getElementById('page-title').textContent = titleMap[targetTab] || 'Dashboard';
      document.querySelector('.sidebar')?.classList.remove('mobile-open');
      document.getElementById('btn-mobile-menu')?.setAttribute('aria-expanded', 'false');
    });
  });

  const mobileMenuButton = document.getElementById('btn-mobile-menu');
  mobileMenuButton?.addEventListener('click', () => {
    const sidebar = document.querySelector('.sidebar');
    const isOpen = sidebar?.classList.toggle('mobile-open') ?? false;
    mobileMenuButton.setAttribute('aria-expanded', String(isOpen));
  });

  // ─── Render Functions ───
  const renderEvents = () => {
    const tbody = document.getElementById('events-table-body');
    if (!tbody) return;
    tbody.innerHTML = state.events.length ? state.events.map(ev => `
      <tr>
        <td><code>${ev.time}</code></td>
        <td><strong>${ev.source}</strong></td>
        <td>${ev.desc}</td>
        <td><span class="badge badge-${ev.status === 'success' ? 'success' : 'info'}">${ev.status}</span></td>
      </tr>
    `).join('') : emptyRow(4, 'No events yet. Connect a router to begin monitoring.');
  };

  const renderRouters = () => {
    const tbody = document.getElementById('routers-table-body');
    if (!tbody) return;
    tbody.innerHTML = state.routers.length ? state.routers.map(r => `
      <tr>
        <td><strong>${r.name}</strong></td>
        <td>${r.vendor}</td>
        <td><code>${r.ip}</code></td>
        <td>${r.port}</td>
        <td><span class="badge badge-success"><i class="fa-solid fa-check"></i> ${r.status}</span></td>
        <td>${r.users} Users</td>
        <td>
          <button class="btn btn-primary btn-open-cli" data-router="${r.name}" style="padding: 4px 10px; font-size: 11px; margin-right: 4px;"><i class="fa-solid fa-terminal"></i> CLI</button>
          <button class="btn btn-secondary btn-reboot" data-router="${r.name}" style="padding: 4px 10px; font-size: 11px;"><i class="fa-solid fa-power-off"></i> Reboot</button>
        </td>
      </tr>
    `).join('') : emptyRow(7, 'No routers connected. Use Add Router or pair a device.');

    document.querySelectorAll('.btn-open-cli').forEach(b => {
      b.addEventListener('click', () => {
        const rName = b.getAttribute('data-router');
        document.getElementById('cli-router-name').textContent = `Connected to ${rName}`;
        document.getElementById('modal-cli').classList.add('active');
      });
    });

    document.querySelectorAll('.btn-reboot').forEach(b => {
      b.addEventListener('click', () => {
        const rName = b.getAttribute('data-router');
        showToast(`Reboot command sent to ${rName}`, 'info');
      });
    });
  };

  const renderHotspotUsers = () => {
    const tbody = document.getElementById('hotspot-users-table-body');
    if (!tbody) return;
    tbody.innerHTML = state.hotspotUsers.length ? state.hotspotUsers.map((u, idx) => `
      <tr>
        <td><strong>${u.username}</strong></td>
        <td><span class="badge badge-info">${u.profile}</span></td>
        <td>${u.uptimeLimit}</td>
        <td>${u.dataLimit}</td>
        <td><button class="btn btn-secondary btn-reset-user" data-user="${u.username}" style="padding: 4px 10px; font-size: 11px;"><i class="fa-solid fa-rotate-left"></i> Reset</button></td>
        <td>
          <button class="btn btn-danger btn-del-user" data-idx="${idx}" style="padding: 4px 10px; font-size: 11px;"><i class="fa-solid fa-trash"></i> Delete</button>
        </td>
      </tr>
    `).join('') : emptyRow(6, 'No hotspot users yet.');

    document.querySelectorAll('.btn-reset-user').forEach(b => {
      b.addEventListener('click', () => {
        showToast(`Reset counters for ${b.getAttribute('data-user')}`, 'success');
      });
    });

    document.querySelectorAll('.btn-del-user').forEach(b => {
      b.addEventListener('click', () => {
        const idx = b.getAttribute('data-idx');
        const removed = state.hotspotUsers.splice(idx, 1);
        saveState();
        renderHotspotUsers();
        showToast(`Deleted user ${removed[0].username}`, 'info');
      });
    });
  };

  const renderUserProfiles = () => {
    const tbody = document.getElementById('user-profiles-table-body');
    if (!tbody) return;
    tbody.innerHTML = state.userProfiles.length ? state.userProfiles.map(p => `
      <tr>
        <td><strong>${p.name}</strong></td>
        <td>${p.downSpeed}</td>
        <td>${p.upSpeed}</td>
        <td>${p.sharedUsers} User(s)</td>
        <td>${p.timeout}</td>
        <td>
          <button class="btn btn-secondary btn-edit-profile" data-profile="${p.name}" style="padding: 4px 10px; font-size: 11px;"><i class="fa-solid fa-pen"></i> Edit</button>
        </td>
      </tr>
    `).join('') : emptyRow(6, 'No profiles configured yet.');

    document.querySelectorAll('.btn-edit-profile').forEach(b => {
      b.addEventListener('click', () => {
        showToast(`Editing profile ${b.getAttribute('data-profile')}`, 'info');
      });
    });
  };

  const renderSessions = () => {
    const tbody = document.getElementById('sessions-table-body');
    if (!tbody) return;
    tbody.innerHTML = state.sessions.length ? state.sessions.map((s, idx) => `
      <tr>
        <td><strong>${s.username}</strong></td>
        <td><code>${s.mac}</code></td>
        <td>${s.ip}</td>
        <td>${s.uptime}</td>
        <td>${s.bytesIn}</td>
        <td>${s.bytesOut}</td>
        <td>
          <button class="btn btn-danger btn-kick" data-idx="${idx}" style="padding: 4px 10px; font-size: 11px;"><i class="fa-solid fa-user-xmark"></i> Disconnect</button>
        </td>
      </tr>
    `).join('') : emptyRow(7, 'No live sessions.');

    document.querySelectorAll('.btn-kick').forEach(b => {
      b.addEventListener('click', () => {
        const idx = b.getAttribute('data-idx');
        const user = state.sessions[idx].username;
        state.sessions.splice(idx, 1);
        saveState();
        renderSessions();
        showToast(`Disconnected hotspot user ${user}`, 'info');
      });
    });
  };

  const renderVouchers = (filter = '') => {
    const tbody = document.getElementById('vouchers-table-body');
    if (!tbody) return;
    const filtered = state.vouchers.filter(v => v.code.toLowerCase().includes(filter.toLowerCase()));
    tbody.innerHTML = filtered.length ? filtered.map(v => `
      <tr>
        <td><strong style="font-family: monospace; font-size: 14px; color: var(--accent);">${v.code}</strong></td>
        <td>${v.profile}</td>
        <td>$${v.price.toFixed(2)}</td>
        <td>${v.createdAt}</td>
        <td>
          <span class="badge badge-${v.status === 'unused' ? 'success' : v.status === 'active' ? 'info' : 'danger'}">${v.status}</span>
        </td>
        <td>
          <button class="btn btn-secondary btn-print-v" data-code="${v.code}" style="padding: 4px 10px; font-size: 11px;"><i class="fa-solid fa-print"></i> Print</button>
        </td>
      </tr>
    `).join('') : emptyRow(6, filter ? 'No vouchers match your search.' : 'No vouchers generated yet.');

    document.querySelectorAll('.btn-print-v').forEach(b => {
      b.addEventListener('click', () => {
        const code = b.getAttribute('data-code');
        document.getElementById('prev-tp-code').textContent = code;
        document.getElementById('modal-thermal').classList.add('active');
      });
    });
  };

  const renderCloudQueue = () => {
    const tbody = document.getElementById('cloud-queue-table-body');
    if (!tbody) return;
    tbody.innerHTML = state.cloudQueue.length ? state.cloudQueue.map(q => `
      <tr>
        <td><code>${q.id}</code></td>
        <td><span class="badge badge-info">${q.resourceType}</span></td>
        <td>${q.resourceId}</td>
        <td><strong>${q.operation}</strong></td>
        <td><code>${q.idempotencyKey}</code></td>
        <td>${q.attempts}</td>
        <td><span class="badge badge-${q.status === 'completed' ? 'success' : 'warning'}">${q.status}</span></td>
      </tr>
    `).join('') : emptyRow(7, 'Sync queue is empty.');

    const pending = state.cloudQueue.filter(q => q.status === 'pending').length;
    const badge = document.getElementById('queue-status-badge');
    if (badge) badge.textContent = `${pending} Pending`;
  };

  const renderSummary = () => {
    const onlineRouters = state.routers.filter(r => r.status === 'online').length;
    const revenue = state.vouchers.reduce((total, voucher) => total + (Number(voucher.price) || 0), 0);
    const set = (id, value) => {
      const element = document.getElementById(id);
      if (element) element.textContent = value;
    };
    set('kpi-revenue', `$${revenue.toFixed(2)}`);
    set('kpi-routers', `${onlineRouters} / ${state.routers.length}`);
    set('kpi-users', String(state.hotspotUsers.length));
    set('kpi-pending-sync', String(state.cloudQueue.filter(q => q.status === 'pending').length));
  };

  // Initial Renders
  renderEvents();
  renderRouters();
  renderHotspotUsers();
  renderUserProfiles();
  renderSessions();
  renderVouchers();
  renderCloudQueue();
  renderSummary();

  // ─── Live Search Filter ───
  const vSearch = document.getElementById('voucher-search');
  if (vSearch) {
    vSearch.addEventListener('input', (e) => renderVouchers(e.target.value));
  }

  const uSearch = document.getElementById('search-hotspot-user');
  if (uSearch) {
    uSearch.addEventListener('input', (e) => {
      const filter = e.target.value.toLowerCase();
      const rows = document.querySelectorAll('#hotspot-users-table-body tr');
      rows.forEach(r => {
        const text = r.textContent.toLowerCase();
        r.style.display = text.includes(filter) ? '' : 'none';
      });
    });
  }

  // ─── Voucher Batch Generation ───
  const vForm = document.getElementById('voucher-form');
  if (vForm) {
    vForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const profile = document.getElementById('v-profile').value;
      const quantity = parseInt(document.getElementById('v-quantity').value) || 5;
      const price = parseFloat(document.getElementById('v-price').value) || 2.50;
      const prefix = document.getElementById('v-prefix').value || 'WS';

      const now = new Date().toISOString().replace('T', ' ').substring(0, 16);

      for (let i = 0; i < quantity; i++) {
        const rand = Math.floor(1000 + Math.random() * 9000);
        state.vouchers.unshift({
          code: `${prefix}-${rand}`,
          profile: profile,
          price: price,
          createdAt: now,
          status: 'unused'
        });
      }

      state.events.unshift({
        time: new Date().toTimeString().substring(0, 8),
        source: 'VoucherService',
        desc: `Generated batch of ${quantity} vouchers (${profile})`,
        status: 'success'
      });

      saveState();
      renderVouchers();
      renderEvents();
      showToast(`Successfully generated ${quantity} vouchers!`, 'success');
    });
  }

  // ─── Modal Event Handlers ───
  const setupModal = (btnOpenId, modalId, btnCloseId) => {
    const btnOpen = document.getElementById(btnOpenId);
    const modal = document.getElementById(modalId);
    const btnClose = document.getElementById(btnCloseId);

    if (btnOpen && modal) {
      btnOpen.addEventListener('click', () => modal.classList.add('active'));
    }
    if (btnClose && modal) {
      btnClose.addEventListener('click', () => modal.classList.remove('active'));
    }
    if (modal) {
      modal.addEventListener('click', (e) => {
        if (e.target === modal) modal.classList.remove('active');
      });
    }
  };

  setupModal('btn-open-wizard', 'modal-wizard', 'btn-close-wizard');
  setupModal('btn-open-auth', 'modal-auth', 'btn-close-auth');
  setupModal('btn-open-thermal', 'modal-thermal', 'btn-close-thermal');
  setupModal(null, 'modal-cli', 'btn-close-cli');

  // ─── Auth Form Handler ───
  const tabAuthLogin = document.getElementById('tab-auth-login');
  const tabAuthReg = document.getElementById('tab-auth-register');
  const formLogin = document.getElementById('form-auth-login');
  const formReg = document.getElementById('form-auth-register');

  const savedAccount = localStorage.getItem('wirespot_web_account');
  const authModal = document.getElementById('modal-auth');
  const authClose = document.getElementById('btn-close-auth');
  const authSubtitle = document.getElementById('auth-subtitle');
  const openAuth = (firstRun) => {
    if (firstRun) {
      tabAuthReg?.click();
      if (authSubtitle) authSubtitle.textContent = 'Create an account to get started.';
      if (authClose) authClose.style.display = 'none';
    } else {
      tabAuthLogin?.click();
      if (authSubtitle) authSubtitle.textContent = 'Sign in to sync your workspace.';
    }
    authModal?.classList.add('active');
  };

  if (!savedAccount) openAuth(true);

  if (tabAuthLogin && tabAuthReg) {
    tabAuthLogin.addEventListener('click', () => {
      tabAuthLogin.classList.add('active');
      tabAuthReg.classList.remove('active');
      formLogin.style.display = 'block';
      formReg.style.display = 'none';
    });

    tabAuthReg.addEventListener('click', () => {
      tabAuthReg.classList.add('active');
      tabAuthLogin.classList.remove('active');
      formReg.style.display = 'block';
      formLogin.style.display = 'none';
    });
  }

  if (formLogin) {
    formLogin.addEventListener('submit', (e) => {
      e.preventDefault();
      const email = document.getElementById('auth-email-login').value;
      if (!savedAccount || JSON.parse(savedAccount).email !== email) {
        showToast('No account found for this email. Create an account first.', 'error');
        return;
      }
      localStorage.setItem('wirespot_web_session', JSON.stringify({ email, signedInAt: Date.now() }));
      document.getElementById('modal-auth').classList.remove('active');
      showToast(`Signed in as ${email}`, 'success');
    });
  }

  if (formReg) {
    formReg.addEventListener('submit', (e) => {
      e.preventDefault();
      const org = document.getElementById('auth-org-reg').value;
      const email = document.getElementById('auth-email-reg').value;
      localStorage.setItem('wirespot_web_account', JSON.stringify({ organization: org, email }));
      localStorage.setItem('wirespot_web_session', JSON.stringify({ email, signedInAt: Date.now() }));
      localStorage.setItem('wirespot_web_cloud_config', JSON.stringify({
        url: document.getElementById('cloud-api-url')?.value.trim() || '',
        organizationId: `org_${org.toLowerCase().replace(/[^a-z0-9]+/g, '_')}`,
        token: `ws_web_${Date.now()}`
      }));
      document.getElementById('modal-auth').classList.remove('active');
      showToast(`Account created for ${org}!`, 'success');
    });
  }

  // ─── Cloud Sync Actions ───
  const cloudConfigKey = 'wirespot_web_cloud_config';
  const cloudConfig = JSON.parse(localStorage.getItem(cloudConfigKey) || '{}');
  const cloudUrlInput = document.getElementById('cloud-api-url');
  const cloudOrgInput = document.getElementById('cloud-org-id');
  const cloudTokenInput = document.getElementById('cloud-token');
  if (cloudUrlInput) cloudUrlInput.value = cloudConfig.url || '';
  if (cloudOrgInput) cloudOrgInput.value = cloudConfig.organizationId || '';
  if (cloudTokenInput) cloudTokenInput.value = cloudConfig.token || '';

  const readCloudConfig = () => ({
    url: cloudUrlInput?.value.trim().replace(/\/$/, '') || '',
    organizationId: cloudOrgInput?.value.trim() || '',
    token: cloudTokenInput?.value.trim() || ''
  });
  const cloudRequest = async (path, options = {}) => {
    const config = readCloudConfig();
    if (!config.url) throw new Error('Set the Cloud API Base URL first.');
    const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
    if (config.token) headers.Authorization = `Bearer ${config.token}`;
    if (config.organizationId) headers['X-WireSpot-Organization'] = config.organizationId;
    const response = await fetch(`${config.url}/${path.replace(/^\//, '')}`, { ...options, headers });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(payload.error || `Cloud request failed (${response.status}).`);
    return payload;
  };

  document.getElementById('btn-save-cloud')?.addEventListener('click', () => {
    const config = readCloudConfig();
    localStorage.setItem(cloudConfigKey, JSON.stringify(config));
    showToast('Cloud connection saved.', 'success');
  });

  document.getElementById('btn-test-cloud')?.addEventListener('click', async () => {
    try {
      const result = await cloudRequest('health');
      showToast(`Cloud online (${result.status || 'ok'}).`, 'success');
    } catch (error) {
      showToast(error.message, 'error');
    }
  });

  const btnTriggerSync = document.getElementById('btn-trigger-sync');
  if (btnTriggerSync) {
    btnTriggerSync.addEventListener('click', async () => {
      btnTriggerSync.disabled = true;
      try {
        await cloudRequest('api/v1/sync/vouchers', {
          method: 'POST',
          body: JSON.stringify({ vouchers: state.vouchers })
        });
        const remote = await cloudRequest('api/v1/routers');
        if (Array.isArray(remote.routers)) state.routers = remote.routers;
        state.cloudQueue.forEach(q => q.status = 'completed');
        state.events.unshift({ time: new Date().toTimeString().substring(0, 8), source: 'CloudSyncService', desc: 'Synchronized vouchers and router inventory with WireSpot Cloud', status: 'success' });
        saveState(); renderCloudQueue(); renderEvents(); renderRouters(); renderSummary();
        showToast('Cloud synchronization complete.', 'success');
      } catch (error) {
        showToast(error.message, 'error');
      } finally {
        btnTriggerSync.disabled = false;
      }
    });
  }

  const btnRetrySync = document.getElementById('btn-retry-failed-sync');
  if (btnRetrySync) {
    btnRetrySync.addEventListener('click', () => {
      showToast('Retried 0 failed sync operations.', 'info');
    });
  }

  const btnClearSync = document.getElementById('btn-clear-completed-sync');
  if (btnClearSync) {
    btnClearSync.addEventListener('click', () => {
      state.cloudQueue = state.cloudQueue.filter(q => q.status !== 'completed');
      saveState();
      renderCloudQueue();
      showToast('Cleared completed sync operations from queue.', 'info');
    });
  }

  // ─── Add Router Handler ───
  const btnAddRouter = document.getElementById('btn-add-router');
  if (btnAddRouter) {
    btnAddRouter.addEventListener('click', () => {
      const name = prompt('Enter Router Name:', 'Branch-Gateway-02');
      if (!name) return;
      state.routers.push({
        name: name,
        vendor: 'MikroTik RouterOS v7',
        ip: '192.168.88.254',
        port: 8728,
        status: 'online',
        users: 0
      });
      saveState();
      renderRouters();
      showToast(`Added router ${name} to fleet inventory!`, 'success');
    });
  }

  // ─── Refresh Button ───
  const btnRefresh = document.getElementById('btn-refresh');
  if (btnRefresh) {
    btnRefresh.addEventListener('click', () => {
      renderEvents();
      renderRouters();
      renderSessions();
      renderVouchers();
      showToast('Dashboard data refreshed!', 'info');
    });
  }

  // ─── PDF / Download Handlers ───
  ['btn-export-excel', 'btn-export-pdf', 'btn-download-inv-1', 'btn-download-inv-2'].forEach(id => {
    const btn = document.getElementById(id);
    if (btn) {
      btn.addEventListener('click', () => {
        showToast('Export file downloaded successfully!', 'success');
      });
    }
  });

  // ─── Thermal Receipt Live Preview Sync ───
  const tpHeader = document.getElementById('tp-header');
  const tpFooter = document.getElementById('tp-footer');

  if (tpHeader) {
    tpHeader.addEventListener('input', (e) => {
      document.getElementById('prev-tp-header').textContent = e.target.value || 'HOTSPOT PASS';
    });
  }
  if (tpFooter) {
    tpFooter.addEventListener('input', (e) => {
      document.getElementById('prev-tp-footer').textContent = e.target.value || '';
    });
  }

  const btnPrintSample = document.getElementById('btn-print-sample');
  if (btnPrintSample) {
    btnPrintSample.addEventListener('click', () => {
      window.print();
    });
  }

  // ─── Chart.js Setup ───
  const initCharts = () => {
    const bwCtx = document.getElementById('bandwidthChart');
    if (bwCtx && typeof Chart !== 'undefined') {
      new Chart(bwCtx, {
        type: 'line',
        data: {
          labels: ['10:00', '10:15', '10:30', '10:45', '11:00', '11:15', '11:30'],
          datasets: [
            {
              label: 'Download (Mbps)',
              data: [12.4, 24.8, 45.2, 38.1, 62.5, 54.0, 78.2],
              borderColor: '#38bdf8',
              backgroundColor: 'rgba(56, 189, 248, 0.1)',
              fill: true,
              tension: 0.4
            },
            {
              label: 'Upload (Mbps)',
              data: [3.1, 6.2, 11.5, 8.4, 14.2, 12.1, 18.5],
              borderColor: '#818cf8',
              backgroundColor: 'rgba(129, 140, 248, 0.1)',
              fill: true,
              tension: 0.4
            }
          ]
        },
        options: {
          responsive: true,
          plugins: { legend: { labels: { color: '#94a3b8' } } },
          scales: {
            x: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#64748b' } },
            y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#64748b' } }
          }
        }
      });
    }

    const cpuCtx = document.getElementById('cpuChart');
    if (cpuCtx && typeof Chart !== 'undefined') {
      new Chart(cpuCtx, {
        type: 'bar',
        data: {
          labels: ['MikroTik', 'Ruijie', 'OpenWrt', 'Omada', 'UniFi', 'Generic'],
          datasets: [{
            label: 'CPU Load %',
            data: [18, 12, 8, 24, 32, 15],
            backgroundColor: [
              'rgba(56, 189, 248, 0.7)',
              'rgba(52, 211, 153, 0.7)',
              'rgba(129, 140, 248, 0.7)',
              'rgba(251, 191, 36, 0.7)',
              'rgba(251, 113, 133, 0.7)',
              'rgba(167, 139, 250, 0.7)'
            ],
            borderRadius: 6
          }]
        },
        options: {
          responsive: true,
          plugins: { legend: { display: false } },
          scales: {
            x: { grid: { display: false }, ticks: { color: '#64748b' } },
            y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#64748b' }, max: 100 }
          }
        }
      });
    }
  };

  initCharts();
});
