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

  const currentCurrency = () => localStorage.getItem('wirespot_currency') || 'NGN';
  const formatMoney = amount => {
    const currency = currentCurrency();
    return new Intl.NumberFormat(undefined, { style: 'currency', currency, maximumFractionDigits: 2 }).format(Number(amount) || 0);
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

  let routerSearch = '';
  let routerVendor = 'all';

  const renderRouters = () => {
    const tbody = document.getElementById('routers-table-body');
    if (!tbody) return;
    const filtered = state.routers.filter(router => {
      const matchesText = `${router.name} ${router.vendor} ${router.ip}`.toLowerCase().includes(routerSearch);
      const matchesVendor = routerVendor === 'all' || router.vendor.toLowerCase().includes(routerVendor.toLowerCase());
      return matchesText && matchesVendor;
    });
    tbody.innerHTML = filtered.length ? filtered.map(r => `
      <tr>
        <td><strong>${r.name}</strong></td>
        <td>${r.vendor}</td>
        <td><code>${r.ip}</code></td>
        <td>${r.port}</td>
        <td><span class="badge badge-${r.status === 'online' ? 'success' : r.status === 'restarting' ? 'warning' : 'info'}"><i class="fa-solid fa-${r.status === 'online' ? 'check' : r.status === 'restarting' ? 'rotate' : 'circle-info'}"></i> ${r.status}</span></td>
        <td>${r.users} Users</td>
        <td>
          <button class="btn btn-primary btn-open-cli" data-router="${r.name}" style="padding: 4px 10px; font-size: 11px; margin-right: 4px;"><i class="fa-solid fa-terminal"></i> CLI</button>
          <button class="btn btn-secondary btn-edit-router" data-router="${r.name}" style="padding: 4px 10px; font-size: 11px; margin-right: 4px;"><i class="fa-solid fa-pen"></i> Edit</button>
          <button class="btn btn-secondary btn-reboot" data-router="${r.name}" style="padding: 4px 10px; font-size: 11px; margin-right: 4px;"><i class="fa-solid fa-power-off"></i> Reboot</button>
          <button class="btn btn-danger btn-delete-router" data-router="${r.name}" style="padding: 4px 10px; font-size: 11px;"><i class="fa-solid fa-trash"></i> Remove</button>
        </td>
      </tr>
    `).join('') : emptyRow(7, state.routers.length ? 'No routers match these filters.' : 'No routers connected. Use Add Router or pair a device.');

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
        const router = state.routers.find(item => item.name === rName);
        if (!router) return;
        router.status = 'restarting';
        saveState(); renderRouters();
        showToast(`Restarting ${rName}...`, 'info');
        setTimeout(() => {
          router.status = 'online';
          saveState(); renderRouters();
          showToast(`${rName} is online again.`, 'success');
        }, 1500);
      });
    });

    document.querySelectorAll('.btn-edit-router').forEach(b => {
      b.addEventListener('click', () => {
        const router = state.routers.find(item => item.name === b.getAttribute('data-router'));
        if (!router) return;
        const name = prompt('Router name:', router.name)?.trim();
        if (!name) return;
        const ip = prompt('Management address:', router.ip)?.trim();
        if (!ip) return;
        const port = Number(prompt('Management port:', router.port));
        if (!Number.isInteger(port) || port < 1 || port > 65535) {
          showToast('Enter a valid port between 1 and 65535.', 'error');
          return;
        }
        const duplicate = state.routers.some(item => item !== router && item.name.toLowerCase() === name.toLowerCase());
        if (duplicate) {
          showToast('A router with that name already exists.', 'error');
          return;
        }
        router.name = name;
        router.ip = ip;
        router.port = port;
        saveState();
        renderRouters();
        renderSummary();
        showToast(`${name} updated.`, 'success');
      });
    });

    document.querySelectorAll('.btn-delete-router').forEach(b => {
      b.addEventListener('click', () => {
        const name = b.getAttribute('data-router');
        const index = state.routers.findIndex(item => item.name === name);
        if (index < 0 || !confirm(`Remove ${name} from this workspace?`)) return;
        state.routers.splice(index, 1);
        saveState();
        renderRouters();
        renderSummary();
        renderSetupGuide();
        showToast(`${name} removed.`, 'info');
      });
    });
  };

  let hotspotUserSearch = '';
  const renderHotspotUsers = () => {
    const tbody = document.getElementById('hotspot-users-table-body');
    if (!tbody) return;
    const users = state.hotspotUsers.filter(user => `${user.username} ${user.profile}`.toLowerCase().includes(hotspotUserSearch));
    tbody.innerHTML = users.length ? users.map((u) => {
      const idx = state.hotspotUsers.indexOf(u);
      return `
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
    `;
    }).join('') : emptyRow(6, state.hotspotUsers.length ? 'No users match your search.' : 'No hotspot users yet.');

    document.querySelectorAll('.btn-reset-user').forEach(b => {
      b.addEventListener('click', () => {
        const username = b.getAttribute('data-user');
        const user = state.hotspotUsers.find(item => item.username === username);
        if (!user) return;
        user.bytesIn = '0 B'; user.bytesOut = '0 B';
        saveState(); renderHotspotUsers();
        showToast(`Counters reset for ${username}.`, 'success');
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
          <button class="btn btn-secondary btn-edit-profile" data-profile="${p.name}" style="padding: 4px 10px; font-size: 11px; margin-right: 4px;"><i class="fa-solid fa-pen"></i> Edit</button>
          <button class="btn btn-danger btn-delete-profile" data-profile="${p.name}" style="padding: 4px 10px; font-size: 11px;"><i class="fa-solid fa-trash"></i> Delete</button>
        </td>
      </tr>
    `).join('') : emptyRow(6, 'No profiles configured yet.');

    document.querySelectorAll('.btn-edit-profile').forEach(b => {
      b.addEventListener('click', () => {
        const profile = state.userProfiles.find(item => item.name === b.getAttribute('data-profile'));
        if (!profile) return;
        const speed = prompt('Download speed:', profile.downSpeed);
        if (!speed) return;
        const timeout = prompt('Session timeout:', profile.timeout);
        if (!timeout) return;
        profile.downSpeed = speed.trim(); profile.timeout = timeout.trim();
        saveState(); renderUserProfiles();
        showToast(`Profile ${profile.name} updated.`, 'success');
      });
    });

    document.querySelectorAll('.btn-delete-profile').forEach(b => {
      b.addEventListener('click', () => {
        const name = b.getAttribute('data-profile');
        const inUse = state.hotspotUsers.some(user => user.profile === name);
        if (inUse) {
          showToast(`Cannot delete ${name} while hotspot users still use it.`, 'error');
          return;
        }
        if (!confirm(`Delete profile ${name}?`)) return;
        state.userProfiles = state.userProfiles.filter(profile => profile.name !== name);
        saveState();
        renderUserProfiles();
        showToast(`Profile ${name} deleted.`, 'info');
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
        <td>${formatMoney(v.price)}</td>
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
        const voucher = state.vouchers.find(item => item.code === code);
        document.getElementById('prev-tp-code').textContent = code;
        document.getElementById('prev-tp-profile').textContent = `Profile: ${voucher?.profile || '—'}`;
        document.getElementById('prev-tp-price').textContent = `Price: ${formatMoney(voucher?.price || 0)}`;
        document.getElementById('prev-tp-date').textContent = `Date: ${voucher?.createdAt || new Date().toLocaleString()}`;
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
        <td><span class="badge badge-${q.status === 'completed' ? 'success' : q.status === 'failed' ? 'danger' : 'warning'}">${q.status}</span></td>
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
    set('kpi-revenue', formatMoney(revenue));
    const revenueStatus = document.getElementById('kpi-revenue-change');
    if (revenueStatus) revenueStatus.innerHTML = `<i class="fa-solid fa-coins"></i> ${state.vouchers.length ? `${state.vouchers.length} voucher${state.vouchers.length === 1 ? '' : 's'} issued` : 'No vouchers issued'}`;
    set('kpi-routers', `${onlineRouters} / ${state.routers.length}`);
    set('kpi-users', String(state.hotspotUsers.length));
    const pendingSync = state.cloudQueue.filter(q => q.status === 'pending').length;
    set('kpi-pending-sync', String(pendingSync));
    const setStatus = (id, icon, value) => {
      const element = document.getElementById(id);
      if (element) element.innerHTML = `<i class="fa-solid ${icon}"></i> ${value}`;
    };
    setStatus('kpi-router-health', 'fa-circle-check', state.routers.length === 0
      ? 'No routers connected'
      : `${onlineRouters} online`);
    setStatus('kpi-user-change', 'fa-users', state.hotspotUsers.length === 0
      ? 'No users yet'
      : `${state.hotspotUsers.length} provisioned`);
    setStatus('kpi-sync-health', 'fa-clock', pendingSync === 0
      ? 'Queue is clear'
      : `${pendingSync} pending`);
    const priceLabel = document.getElementById('voucher-price-label');
    if (priceLabel) priceLabel.textContent = `Price (${currentCurrency()})`;
  };

  const setupGuideCard = document.getElementById('getting-started-card');
  const renderSetupGuide = () => {
    if (!setupGuideCard) return;
    const dismissed = localStorage.getItem('wirespot_setup_guide_dismissed') === 'true';
    const complete = state.routers.length > 0 && state.vouchers.length > 0 &&
      Boolean(JSON.parse(localStorage.getItem('wirespot_web_cloud_config') || '{}').url);
    setupGuideCard.style.display = dismissed || complete ? 'none' : 'block';
  };
  setupGuideCard?.querySelectorAll('[data-setup-tab]').forEach(button => {
    button.addEventListener('click', () => {
      document.querySelector(`[data-tab="${button.dataset.setupTab}"]`)?.click();
    });
  });
  document.getElementById('btn-dismiss-getting-started')?.addEventListener('click', () => {
    localStorage.setItem('wirespot_setup_guide_dismissed', 'true');
    renderSetupGuide();
  });

  // Initial Renders
  renderEvents();
  renderRouters();
  renderHotspotUsers();
  renderUserProfiles();
  renderSessions();
  renderVouchers();
  renderCloudQueue();
  renderSummary();
  renderSetupGuide();

  document.getElementById('router-search')?.addEventListener('input', event => {
    routerSearch = event.target.value.trim().toLowerCase();
    renderRouters();
  });
  document.getElementById('router-vendor-filter')?.addEventListener('change', event => {
    routerVendor = event.target.value;
    renderRouters();
  });
  document.getElementById('search-hotspot-user')?.addEventListener('input', event => {
    hotspotUserSearch = event.target.value.trim().toLowerCase();
    renderHotspotUsers();
  });

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
        if (modal.id === 'modal-auth' && !localStorage.getItem('wirespot_web_session')) return;
        if (e.target === modal) modal.classList.remove('active');
      });
    }
  };

  setupModal('btn-open-wizard', 'modal-wizard', 'btn-close-wizard');
  setupModal('btn-open-auth', 'modal-auth', 'btn-close-auth');
  setupModal('btn-open-thermal', 'modal-thermal', 'btn-close-thermal');
  setupModal(null, 'modal-cli', 'btn-close-cli');

  // ─── Functional router setup wizard ───
  let wizardStep = 1;
  let wizardPreset = 'cafe';
  const wizardPresetValues = {
    cafe: { ssid: 'WireSpot_Guest_WiFi', packageName: 'Café 1Hour Pass', speed: 3, duration: 60 },
    hotel: { ssid: 'WireSpot_Hotel_WiFi', packageName: 'Hotel 24Hour Pass', speed: 10, duration: 1440 },
    school: { ssid: 'WireSpot_Campus_WiFi', packageName: 'Student Daily Pass', speed: 5, duration: 1440 },
    retail: { ssid: 'WireSpot_Free_WiFi', packageName: 'Retail 30Minute Pass', speed: 5, duration: 30 }
  };
  const showWizardStep = step => {
    wizardStep = step;
    document.querySelectorAll('.wizard-pane').forEach((pane, index) => pane.style.display = index + 1 === step ? 'block' : 'none');
    document.querySelectorAll('.wizard-step').forEach((item, index) => item.classList.toggle('active', index + 1 === step));
  };
  document.querySelectorAll('.preset-card').forEach(card => card.addEventListener('click', () => {
    document.querySelectorAll('.preset-card').forEach(item => item.classList.remove('selected'));
    card.classList.add('selected'); wizardPreset = card.dataset.preset;
    const values = wizardPresetValues[wizardPreset];
    document.getElementById('wiz-ssid').value = values.ssid;
    document.getElementById('wiz-package-name').value = values.packageName;
    document.getElementById('wiz-speed-limit').value = values.speed;
    document.getElementById('wiz-duration').value = values.duration;
  }));
  document.getElementById('btn-wiz-next-1')?.addEventListener('click', () => showWizardStep(2));
  document.getElementById('btn-wiz-back-2')?.addEventListener('click', () => showWizardStep(1));
  document.getElementById('btn-wiz-next-2')?.addEventListener('click', () => {
    const host = document.getElementById('wiz-router-host').value.trim();
    if (!host) { showToast('Enter the router IP address or hostname.', 'error'); return; }
    showWizardStep(3);
  });
  document.getElementById('btn-wiz-back-3')?.addEventListener('click', () => showWizardStep(2));
  document.getElementById('btn-wiz-next-3')?.addEventListener('click', () => {
    const vendorKey = document.getElementById('wiz-router-vendor').value;
    const vendor = document.getElementById('wiz-router-vendor').selectedOptions[0].text;
    const host = document.getElementById('wiz-router-host').value.trim();
    const port = document.getElementById('wiz-router-port').value || '8728';
    const ssid = document.getElementById('wiz-ssid').value.trim() || 'WireSpot_Guest_WiFi';
    const profile = document.getElementById('wiz-package-name').value.trim() || 'WireSpot Guest Pass';
    const speed = document.getElementById('wiz-speed-limit').value || '3';
    const duration = document.getElementById('wiz-duration').value || '60';
    const script = vendorKey === 'mikrotik'
      ? `# WireSpot MikroTik RouterOS hotspot setup\n# Target: ${host}:${port}\n# Review commands and apply them in a trusted RouterOS terminal.\n/interface wireless set [ find default-name=wlan1 ] ssid="${ssid}"\n/ip hotspot user profile add name="${profile}" rate-limit="${speed}M/${speed}M" session-timeout=${duration}m\n/ip service set api disabled=no port=${port}`
      : `# WireSpot ${vendor} connection profile\n# Target: ${host}:${port}\n# This vendor is managed through its controller/API connector.\n# Save this router, then configure credentials in the secure mobile app or cloud backend.\n# Hotspot profile: ${profile}\n# Speed: ${speed} Mbps · Duration: ${duration} minutes`;
    document.getElementById('wiz-script-preview').value = script;
    showWizardStep(4);
  });
  document.getElementById('btn-wiz-back-4')?.addEventListener('click', () => showWizardStep(3));
  document.getElementById('btn-wiz-deploy')?.addEventListener('click', async () => {
    const vendor = document.getElementById('wiz-router-vendor').selectedOptions[0].text;
    const host = document.getElementById('wiz-router-host').value.trim();
    const router = { name: `${vendor.split(' / ')[0]}-${host}`, vendor, ip: host, port: Number(document.getElementById('wiz-router-port').value) || 8728, status: 'configured', users: 0, hotspotProfile: document.getElementById('wiz-package-name').value.trim() };
    const existing = state.routers.findIndex(item => item.ip === host);
    if (existing >= 0) state.routers[existing] = { ...state.routers[existing], ...router };
    else state.routers.push(router);
    state.events.unshift({ time: new Date().toTimeString().substring(0, 8), source: 'SetupWizard', desc: `Saved ${vendor} router configuration for ${host}`, status: 'success' });
    saveState(); renderRouters(); renderEvents(); renderSummary(); renderSetupGuide();
    const cloudConfig = readCloudConfig?.();
    if (cloudConfig?.url && cloudConfig.token) {
      try {
        await cloudRequest('api/v1/routers', {
          method: 'POST',
          body: JSON.stringify({ routers: state.routers })
        });
        showToast(`Router saved locally and synced to WireSpot Cloud.`, 'success');
      } catch (error) {
        showToast(`Router saved locally; cloud sync failed: ${error.message}`, 'error');
      }
    }
    document.getElementById('modal-wizard').classList.remove('active');
    showWizardStep(1);
    if (!cloudConfig?.url || !cloudConfig.token) showToast(`Router configuration saved for ${host}.`, 'success');
  });

  // ─── Auth Form Handler ───
  const tabAuthLogin = document.getElementById('tab-auth-login');
  const tabAuthReg = document.getElementById('tab-auth-register');
  const formLogin = document.getElementById('form-auth-login');
  const formReg = document.getElementById('form-auth-register');

  const savedAccount = localStorage.getItem('wirespot_web_account');
  const account = savedAccount ? JSON.parse(savedAccount) : null;
  const userName = document.getElementById('current-user-name');
  const userEmail = document.getElementById('current-user-email');
  if (account) {
    if (userName) userName.textContent = account.organization || 'WireSpot Operator';
    if (userEmail) userEmail.textContent = account.email || '';
  }
  const authModal = document.getElementById('modal-auth');
  const authClose = document.getElementById('btn-close-auth');
  const authSubtitle = document.getElementById('auth-subtitle');
  const signOutButton = document.getElementById('btn-signout');
  const openAuth = (firstRun) => {
    if (firstRun) {
      tabAuthReg?.click();
      if (authSubtitle) authSubtitle.textContent = 'Create an account to get started.';
      if (authClose) authClose.style.display = 'none';
    } else {
      tabAuthLogin?.click();
      if (authSubtitle) authSubtitle.textContent = 'Sign in to sync your workspace.';
      if (authClose && !localStorage.getItem('wirespot_web_session')) authClose.style.display = 'none';
    }
    if (signOutButton) signOutButton.style.display = localStorage.getItem('wirespot_web_session') ? 'block' : 'none';
    authModal?.classList.add('active');
  };

  if (!localStorage.getItem('wirespot_web_session')) openAuth(!savedAccount);

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
      const generatedConfig = JSON.parse(localStorage.getItem('wirespot_web_cloud_config'));
      if (cloudOrgInput) cloudOrgInput.value = generatedConfig.organizationId;
      if (cloudTokenInput) cloudTokenInput.value = generatedConfig.token;
      renderCloudCredentials?.();
      document.getElementById('modal-auth').classList.remove('active');
      document.querySelector('[data-tab="tab-cloud"]')?.click();
      showToast(`Account created for ${org}!`, 'success');
    });
  }

  // ─── Cloud Sync Actions ───
  const cloudConfigKey = 'wirespot_web_cloud_config';
  const cloudConfig = JSON.parse(localStorage.getItem(cloudConfigKey) || '{}');
  const cloudUrlInput = document.getElementById('cloud-api-url');
  const cloudOrgInput = document.getElementById('cloud-org-id');
  const cloudTokenInput = document.getElementById('cloud-token');
  const cloudOrgDisplay = document.getElementById('cloud-org-display');
  const cloudTokenDisplay = document.getElementById('cloud-token-display');
  if (cloudUrlInput) cloudUrlInput.value = cloudConfig.url || '';
  if (cloudOrgInput) cloudOrgInput.value = cloudConfig.organizationId || '';
  if (cloudTokenInput) cloudTokenInput.value = cloudConfig.token || '';
  const renderCloudCredentials = () => {
    if (cloudOrgDisplay) cloudOrgDisplay.textContent = cloudOrgInput?.value || 'Sign in to generate';
    if (cloudTokenDisplay) cloudTokenDisplay.textContent = cloudTokenInput?.value || 'Sign in to generate';
  };
  renderCloudCredentials();
  document.querySelectorAll('.btn-copy-credential').forEach(button => button.addEventListener('click', async () => {
    const value = document.getElementById(button.dataset.copyTarget)?.textContent || '';
    if (!value || value.startsWith('Sign in')) return;
    await navigator.clipboard?.writeText(value);
    showToast('Credential copied to clipboard.', 'success');
  }));

  const readCloudConfig = () => ({
    url: cloudUrlInput?.value.trim().replace(/\/$/, '') || '',
    organizationId: cloudOrgInput?.value.trim() || '',
    token: cloudTokenInput?.value.trim() || ''
  });
  const updateSyncIndicator = (connected) => {
    const label = document.getElementById('sync-status-label');
    if (label) label.textContent = connected ? 'Cloud connected' : 'Cloud not connected';
  };
  updateSyncIndicator(Boolean(cloudConfig.url && cloudConfig.token));
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
    renderCloudCredentials();
    updateSyncIndicator(Boolean(config.url && config.token));
    showToast('Cloud connection saved.', 'success');
  });

  document.getElementById('btn-test-cloud')?.addEventListener('click', async () => {
    try {
      const result = await cloudRequest('health');
      updateSyncIndicator(true);
      showToast(`Cloud online (${result.status || 'ok'}).`, 'success');
    } catch (error) {
      updateSyncIndicator(false);
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
        await cloudRequest('api/v1/backup/upload', {
          method: 'POST',
          body: JSON.stringify({
            version: 1,
            exportedAt: new Date().toISOString(),
            routers: state.routers,
            hotspotUsers: state.hotspotUsers,
            userProfiles: state.userProfiles,
            sessions: state.sessions,
            vouchers: state.vouchers
          })
        });
        const remote = await cloudRequest('api/v1/routers');
        if (Array.isArray(remote.routers)) state.routers = remote.routers;
        state.cloudQueue.forEach(q => q.status = 'completed');
        state.events.unshift({ time: new Date().toTimeString().substring(0, 8), source: 'CloudSyncService', desc: 'Synchronized vouchers and router inventory with WireSpot Cloud', status: 'success' });
        saveState(); renderCloudQueue(); renderEvents(); renderRouters(); renderSummary();
        showToast('Cloud synchronization complete.', 'success');
      } catch (error) {
        updateSyncIndicator(false);
        state.cloudQueue.filter(q => q.status === 'pending').forEach(q => {
          q.status = 'failed';
          q.attempts = (Number(q.attempts) || 0) + 1;
        });
        saveState();
        renderCloudQueue();
        renderSummary();
        showToast(error.message, 'error');
      } finally {
        btnTriggerSync.disabled = false;
      }
    });
  }

  document.getElementById('btn-restore-backup')?.addEventListener('click', async () => {
    const confirmed = window.confirm('Restore the latest cloud backup? Current local records will be replaced.');
    if (!confirmed) return;
    try {
      const result = await cloudRequest('api/v1/backup/latest');
      const backup = result.backup;
      if (!backup || typeof backup !== 'object') throw new Error('No cloud backup is available yet.');
      for (const key of ['routers', 'hotspotUsers', 'userProfiles', 'sessions', 'vouchers']) {
        if (Array.isArray(backup[key])) state[key] = backup[key];
      }
      saveState();
      renderRouters(); renderHotspotUsers(); renderUserProfiles(); renderSessions(); renderVouchers(); renderSummary();
      showToast('Latest cloud backup restored.', 'success');
    } catch (error) {
      updateSyncIndicator(false);
      showToast(error.message, 'error');
    }
  });

  signOutButton?.addEventListener('click', () => {
    localStorage.removeItem('wirespot_web_session');
    authModal?.classList.remove('active');
    openAuth(false);
    showToast('You have been signed out.', 'info');
  });

  const btnRetrySync = document.getElementById('btn-retry-failed-sync');
  if (btnRetrySync) {
    btnRetrySync.addEventListener('click', () => {
      const failed = state.cloudQueue.filter(q => q.status === 'failed');
      if (!failed.length) {
        showToast('There are no failed sync operations to retry.', 'info');
        return;
      }
      failed.forEach(q => { q.status = 'pending'; });
      saveState();
      renderCloudQueue();
      renderSummary();
      showToast(`Queued ${failed.length} failed operation${failed.length === 1 ? '' : 's'} for retry.`, 'success');
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
      document.getElementById('modal-wizard')?.classList.add('active');
      showWizardStep(2);
    });
  }

  document.getElementById('btn-refresh-sessions')?.addEventListener('click', () => {
    renderSessions();
    showToast('Live session list refreshed.', 'info');
  });

  document.getElementById('btn-add-hotspot-user')?.addEventListener('click', () => {
    const username = prompt('Username:', `guest_${Date.now().toString().slice(-4)}`)?.trim();
    if (!username) return;
    const profile = prompt('Profile:', state.userProfiles[0]?.name || 'Guest')?.trim() || 'Guest';
    state.hotspotUsers.push({ username, profile, uptimeLimit: 'Unlimited', dataLimit: 'Unlimited', bytesIn: '0 B', bytesOut: '0 B' });
    saveState(); renderHotspotUsers(); renderSummary();
    showToast(`Hotspot user ${username} added.`, 'success');
  });

  document.getElementById('btn-add-user-profile')?.addEventListener('click', () => {
    const name = prompt('Profile name:', `Guest-${state.userProfiles.length + 1}`)?.trim();
    if (!name) return;
    state.userProfiles.push({ name, downSpeed: '5 Mbps', upSpeed: '2 Mbps', sharedUsers: 1, timeout: '60m' });
    saveState(); renderUserProfiles();
    showToast(`Profile ${name} added.`, 'success');
  });

  document.getElementById('btn-send-cli')?.addEventListener('click', () => {
    const input = document.getElementById('cli-command-input');
    const output = document.getElementById('cli-output-text');
    const command = input?.value.trim();
    if (!command || !output) return;
    output.textContent += `\n[operator] > ${command}\nCommand queued for the selected router. Connect Cloud Sync to execute remote commands.`;
    input.value = '';
    output.parentElement?.scrollTo(0, output.parentElement.scrollHeight);
  });

  document.getElementById('btn-current-plan')?.addEventListener('click', () => {
    showToast('Enterprise Cloud is the active workspace plan.', 'info');
  });
  document.getElementById('btn-manage-subscription')?.addEventListener('click', () => {
    document.querySelector('[data-tab="tab-cloud"]')?.click();
    showToast('Manage billing and cloud sync from the Cloud Sync tab.', 'info');
  });
  document.getElementById('btn-switch-pro')?.addEventListener('click', () => {
    showToast('Plan changes will be available when billing is connected.', 'info');
  });

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

  // ─── Reports and real file exports ───
  const downloadFile = (filename, content, mimeType) => {
    const blob = new Blob([content], { type: mimeType });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    link.remove();
    setTimeout(() => URL.revokeObjectURL(link.href), 0);
  };

  const csvCell = value => `"${String(value ?? '').replace(/"/g, '""')}"`;
  const toCsv = rows => rows.map(row => row.map(csvCell).join(',')).join('\r\n');
  const reportPeriod = () => {
    const range = document.getElementById('report-range')?.value || '30d';
    if (range === 'today') return { label: 'Today', from: new Date(new Date().setHours(0, 0, 0, 0)) };
    if (range === '7d') return { label: 'Last 7 days', from: new Date(Date.now() - 7 * 86400000) };
    if (range === 'ytd') return { label: 'Year to date', from: new Date(new Date().getFullYear(), 0, 1) };
    return { label: 'Last 30 days', from: new Date(Date.now() - 30 * 86400000) };
  };

  const reportRows = () => {
    const period = reportPeriod();
    return state.vouchers.filter(v => {
      const created = new Date(String(v.createdAt || '').replace(' ', 'T'));
      return Number.isNaN(created.getTime()) || created >= period.from;
    });
  };

  const reportCurrency = document.getElementById('report-currency');
  const savedCurrency = localStorage.getItem('wirespot_currency') || 'NGN';
  const renderInvoiceAmounts = () => document.querySelectorAll('.invoice-amount').forEach(cell => {
    cell.textContent = formatMoney(cell.dataset.amount);
  });
  renderInvoiceAmounts();
  if (reportCurrency) reportCurrency.value = ['NGN', 'KES', 'GHS', 'USD'].includes(savedCurrency) ? savedCurrency : 'NGN';
  reportCurrency?.addEventListener('change', event => {
    localStorage.setItem('wirespot_currency', event.target.value);
    renderReport(); renderSummary(); renderVouchers(); renderInvoiceAmounts();
  });

  const renderReport = () => {
    const rows = reportRows();
    const period = reportPeriod();
    const revenue = rows.reduce((sum, voucher) => sum + (Number(voucher.price) || 0), 0);
    const used = rows.filter(v => v.status === 'active' || v.status === 'used').length;
    const available = rows.filter(v => v.status === 'unused').length;
    const summary = document.getElementById('report-summary');
    if (summary) summary.innerHTML = `
      <div class="report-metric"><span class="metric-label">Revenue</span><strong>${formatMoney(revenue)}</strong><small>${period.label}</small></div>
      <div class="report-metric"><span class="metric-label">Vouchers issued</span><strong>${rows.length}</strong><small>Generated in period</small></div>
      <div class="report-metric"><span class="metric-label">Redeemed</span><strong>${used}</strong><small>Active or used passes</small></div>
      <div class="report-metric"><span class="metric-label">Available</span><strong>${available}</strong><small>Ready for customers</small></div>`;
    const label = document.getElementById('report-period-label');
    if (label) label.textContent = `${period.label} · ${rows.length} voucher${rows.length === 1 ? '' : 's'}`;
    const count = document.getElementById('report-row-count');
    if (count) count.textContent = `${rows.length} record${rows.length === 1 ? '' : 's'}`;
    const tbody = document.getElementById('report-table-body');
    if (tbody) tbody.innerHTML = rows.length ? rows.map(v => `
      <tr><td><code>${v.code || '—'}</code></td><td>${v.profile || '—'}</td><td>${v.createdAt || '—'}</td>
      <td><span class="badge badge-${v.status === 'active' ? 'success' : v.status === 'expired' ? 'danger' : 'info'}">${v.status || 'unknown'}</span></td>
      <td>${formatMoney(v.price)}</td></tr>`).join('') : emptyRow(5, 'No voucher sales in this period. Create a voucher or sync your cloud workspace.');
    return { rows, period, revenue };
  };

  document.getElementById('report-range')?.addEventListener('change', renderReport);
  document.getElementById('btn-export-excel')?.addEventListener('click', () => {
    const { rows, period } = renderReport();
    const csv = toCsv([['Voucher code', 'Profile', 'Created at', 'Status', `Amount (${reportCurrency?.value || 'NGN'})`], ...rows.map(v => [v.code, v.profile, v.createdAt, v.status, (Number(v.price) || 0).toFixed(2)])]);
    downloadFile(`wirespot-report-${period.label.toLowerCase().replaceAll(' ', '-')}.csv`, csv, 'text/csv;charset=utf-8');
    showToast('CSV report downloaded. It opens directly in Excel.', 'success');
  });
  document.getElementById('btn-export-json')?.addEventListener('click', () => {
    const snapshot = { version: 1, exportedAt: new Date().toISOString(), ...state };
    downloadFile(`wirespot-workspace-${new Date().toISOString().slice(0, 10)}.json`, JSON.stringify(snapshot, null, 2), 'application/json');
    showToast('Workspace JSON backup downloaded.', 'success');
  });
  const printReport = (title, rows) => {
    const popup = window.open('', '_blank', 'width=960,height=720');
    if (!popup) { showToast('Allow pop-ups to print this report.', 'error'); return; }
    const period = reportPeriod();
    const body = rows.map(v => `<tr><td>${v.code || '—'}</td><td>${v.profile || '—'}</td><td>${v.createdAt || '—'}</td><td>${v.status || '—'}</td><td>${formatMoney(v.price)}</td></tr>`).join('');
    popup.document.write(`<!doctype html><html><head><title>${title}</title><style>body{font:14px Arial;color:#172033;padding:36px}header{display:flex;align-items:center;gap:14px;border-bottom:2px solid #0b8fff;padding-bottom:16px}header img{width:48px;height:48px;border-radius:12px}h1{margin:0;font-size:24px}small{color:#64748b}table{width:100%;border-collapse:collapse;margin-top:28px}th,td{padding:10px;border-bottom:1px solid #dbe3ef;text-align:left}th{background:#eef6ff}.total{margin-top:24px;text-align:right;font-size:18px;font-weight:bold}@media print{button{display:none}}</style></head><body><header><img src="${location.origin}/wirespot_mark.jpg"><div><h1>${title}</h1><small>${period.label} · Generated ${new Date().toLocaleString()}</small></div></header><table><thead><tr><th>Voucher</th><th>Profile</th><th>Created</th><th>Status</th><th>Amount</th></tr></thead><tbody>${body || '<tr><td colspan="5">No records in this period.</td></tr>'}</tbody></table><div class="total">Total revenue: ${formatMoney(rows.reduce((sum, v) => sum + (Number(v.price) || 0), 0))}</div><script>window.onload=()=>{window.print();}</script></body></html>`);
    popup.document.close();
  };
  document.getElementById('btn-export-pdf')?.addEventListener('click', () => { const { rows } = renderReport(); printReport('WireSpot Sales Report', rows); });
  ['btn-download-inv-1', 'btn-download-inv-2'].forEach(id => document.getElementById(id)?.addEventListener('click', event => {
    const button = event.currentTarget;
    printReport(`WireSpot Invoice ${button.dataset.invoice}`, [{
      code: button.dataset.invoice,
      profile: 'Enterprise Cloud',
      createdAt: button.dataset.invoiceDate,
      status: 'paid',
      price: 49
    }]);
  }));
  renderReport();

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
    const salesCtx = document.getElementById('salesChart');
    if (salesCtx && typeof Chart !== 'undefined') {
      const report = renderReport();
      const days = Array.from({ length: 7 }, (_, index) => {
        const date = new Date(Date.now() - (6 - index) * 86400000);
        return { date, label: date.toLocaleDateString(undefined, { weekday: 'short' }), total: 0 };
      });
      report.rows.forEach(voucher => {
        const created = new Date(String(voucher.createdAt || '').replace(' ', 'T'));
        const day = days.find(item => created.toDateString() === item.date.toDateString());
        if (day) day.total += Number(voucher.price) || 0;
      });
      new Chart(salesCtx, {
        type: 'line',
        data: { labels: days.map(day => day.label), datasets: [{ label: `Revenue (${currentCurrency()})`, data: days.map(day => day.total), borderColor: '#18bfff', backgroundColor: 'rgba(24,191,255,.12)', fill: true, tension: .35 }] },
        options: { responsive: true, plugins: { legend: { labels: { color: '#94a3b8' } } }, scales: { x: { grid: { color: 'rgba(255,255,255,.05)' }, ticks: { color: '#64748b' } }, y: { beginAtZero: true, grid: { color: 'rgba(255,255,255,.05)' }, ticks: { color: '#64748b' } } } }
      });
    }
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
