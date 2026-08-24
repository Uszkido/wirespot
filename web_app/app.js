// WireSpot Cloud Web Application Logic
document.addEventListener('DOMContentLoaded', () => {
  // State Store
  const state = {
    activeTab: 'tab-dashboard',
    routers: [
      { name: 'Main-Gateway-MikroTik', vendor: 'MikroTik RouterOS', ip: '192.168.88.1', port: 8728, status: 'online', users: 32 },
      { name: 'Pool-Bar-Ruijie', vendor: 'Ruijie / Reyee', ip: '10.0.0.15', port: 443, status: 'online', users: 12 },
      { name: 'Lobby-AP-OpenWrt', vendor: 'OpenWrt', ip: '192.168.1.1', port: 22, status: 'online', users: 8 },
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
      { time: '11:28:10', source: 'CloudSyncService', desc: 'Background sync triggered via automated scheduler', status: 'success' },
      { time: '11:15:00', source: 'VoucherService', desc: 'Generated batch of 5 vouchers (Profile: 1Hour-5MBPS)', status: 'success' },
      { time: '10:45:12', source: 'RouterOSConnector', desc: 'Connected to MikroTik gateway at 192.168.88.1:8728', status: 'info' }
    ]
  };

  // Toast Helper
  const showToast = (message, type = 'success') => {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.style.background = type === 'success' ? 'rgba(16, 185, 129, 0.9)' : 'rgba(239, 68, 68, 0.9)';
    toast.style.transform = 'translateY(0)';
    toast.style.opacity = '1';
    setTimeout(() => {
      toast.style.transform = 'translateY(100px)';
      toast.style.opacity = '0';
    }, 3000);
  };

  // Navigation Logic
  document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', (e) => {
      document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));

      const targetTab = item.getAttribute('data-tab');
      item.classList.add('active');
      document.getElementById(targetTab).classList.add('active');

      const titleMap = {
        'tab-dashboard': 'Dashboard Overview',
        'tab-routers': 'Router Fleet Inventory',
        'tab-users-advanced': 'Advanced Hotspot Users & Profiles',
        'tab-sessions': 'Hotspot Active Sessions',
        'tab-vouchers': 'Voucher Batch & Inventory',
        'tab-subscriptions': 'Subscriptions & Operator Billing',
        'tab-cloud': 'WireSpot Cloud Sync Center',
        'tab-reports': 'Sales Analytics & Export'
      };
      document.getElementById('page-title').textContent = titleMap[targetTab] || 'Dashboard';
    });
  });

  // Render Tables
  const renderEvents = () => {
    const tbody = document.getElementById('events-table-body');
    tbody.innerHTML = state.events.map(ev => `
      <tr>
        <td>${ev.time}</td>
        <td><strong>${ev.source}</strong></td>
        <td>${ev.desc}</td>
        <td><span class="badge badge-${ev.status === 'success' ? 'success' : 'info'}">${ev.status}</span></td>
      </tr>
    `).join('');
  };

  const renderRouters = () => {
    const tbody = document.getElementById('routers-table-body');
    tbody.innerHTML = state.routers.map(r => `
      <tr>
        <td><strong>${r.name}</strong></td>
        <td>${r.vendor}</td>
        <td><code>${r.ip}</code></td>
        <td>${r.port}</td>
        <td><span class="badge badge-success"><i class="fa-solid fa-check"></i> ${r.status}</span></td>
        <td>${r.users} Users</td>
        <td>
          <button class="btn btn-primary btn-open-cli" data-router="${r.name}" style="padding: 4px 10px; font-size: 12px; margin-right: 6px;"><i class="fa-solid fa-terminal"></i> CLI</button>
          <button class="btn btn-secondary" onclick="alert('Reboot command sent to ${r.name}')" style="padding: 4px 10px; font-size: 12px;"><i class="fa-solid fa-power-off"></i> Reboot</button>
        </td>
      </tr>
    `).join('');

    document.querySelectorAll('.btn-open-cli').forEach(b => {
      b.addEventListener('click', () => {
        const rName = b.getAttribute('data-router');
        document.getElementById('cli-router-name').textContent = `Connected to ${rName}`;
        document.getElementById('modal-cli').classList.add('active');
      });
    });
  };

  const renderHotspotUsers = () => {
    const tbody = document.getElementById('hotspot-users-table-body');
    if (!tbody) return;
    tbody.innerHTML = state.hotspotUsers.map((u, idx) => `
      <tr>
        <td><strong>${u.username}</strong></td>
        <td><span class="badge badge-info">${u.profile}</span></td>
        <td>${u.uptimeLimit}</td>
        <td>${u.dataLimit}</td>
        <td><button class="btn btn-secondary" onclick="alert('Reset counters for ${u.username}')" style="padding: 4px 10px; font-size: 12px;"><i class="fa-solid fa-rotate-left"></i> Reset</button></td>
        <td>
          <button class="btn btn-danger" onclick="alert('Removed user ${u.username}')" style="padding: 4px 10px; font-size: 12px;"><i class="fa-solid fa-trash"></i> Delete</button>
        </td>
      </tr>
    `).join('');
  };

  const renderUserProfiles = () => {
    const tbody = document.getElementById('user-profiles-table-body');
    if (!tbody) return;
    tbody.innerHTML = state.userProfiles.map(p => `
      <tr>
        <td><strong>${p.name}</strong></td>
        <td>${p.downSpeed}</td>
        <td>${p.upSpeed}</td>
        <td>${p.sharedUsers} User(s)</td>
        <td>${p.timeout}</td>
        <td>
          <button class="btn btn-secondary" onclick="alert('Editing profile ${p.name}')" style="padding: 4px 10px; font-size: 12px;"><i class="fa-solid fa-pen"></i> Edit</button>
        </td>
      </tr>
    `).join('');
  };

  const renderSessions = () => {
    const tbody = document.getElementById('sessions-table-body');
    tbody.innerHTML = state.sessions.map((s, idx) => `
      <tr>
        <td><strong>${s.username}</strong></td>
        <td><code>${s.mac}</code></td>
        <td>${s.ip}</td>
        <td>${s.uptime}</td>
        <td>${s.bytesIn}</td>
        <td>${s.bytesOut}</td>
        <td>
          <button class="btn btn-danger btn-kick" data-idx="${idx}" style="padding: 4px 10px; font-size: 12px;"><i class="fa-solid fa-user-xmark"></i> Disconnect</button>
        </td>
      </tr>
    `).join('');

    document.querySelectorAll('.btn-kick').forEach(b => {
      b.addEventListener('click', (e) => {
        const idx = b.getAttribute('data-idx');
        const user = state.sessions[idx].username;
        state.sessions.splice(idx, 1);
        renderSessions();
        showToast(`Disconnected hotspot user ${user}`, 'success');
      });
    });
  };

  const renderVouchers = (filter = '') => {
    const tbody = document.getElementById('vouchers-table-body');
    const filtered = state.vouchers.filter(v => v.code.toLowerCase().includes(filter.toLowerCase()));
    tbody.innerHTML = filtered.map(v => `
      <tr>
        <td><strong style="font-family: monospace; font-size: 15px; color: var(--primary);">${v.code}</strong></td>
        <td>${v.profile}</td>
        <td>$${v.price.toFixed(2)}</td>
        <td>${v.createdAt}</td>
        <td>
          <span class="badge badge-${v.status === 'unused' ? 'success' : v.status === 'active' ? 'info' : 'danger'}">${v.status}</span>
        </td>
        <td>
          <button class="btn btn-secondary" onclick="alert('Printing receipt preview for voucher ${v.code}')" style="padding: 4px 10px; font-size: 12px;"><i class="fa-solid fa-print"></i> Print</button>
        </td>
      </tr>
    `).join('');

    // Summary counters
    document.getElementById('total-vouchers-count').textContent = state.vouchers.length;
    document.getElementById('unused-vouchers-count').textContent = state.vouchers.filter(v => v.status === 'unused').length;
    document.getElementById('active-vouchers-count').textContent = state.vouchers.filter(v => v.status === 'active').length;
    document.getElementById('expired-vouchers-count').textContent = state.vouchers.filter(v => v.status === 'expired').length;
  };

  const renderCloudQueue = () => {
    const tbody = document.getElementById('cloud-queue-table-body');
    tbody.innerHTML = state.cloudQueue.map(q => `
      <tr>
        <td><code>${q.id}</code></td>
        <td><strong>${q.resourceType}</strong></td>
        <td>${q.resourceId}</td>
        <td>${q.operation}</td>
        <td><code>${q.idempotencyKey}</code></td>
        <td>${q.attempts}</td>
        <td>
          <span class="badge badge-${q.status === 'completed' ? 'success' : q.status === 'pending' ? 'warning' : 'danger'}">${q.status}</span>
        </td>
      </tr>
    `).join('');

    const pendingCount = state.cloudQueue.filter(q => q.status === 'pending').length;
    document.getElementById('queue-status-badge').textContent = `${pendingCount} Pending`;
    document.getElementById('kpi-pending-sync').textContent = pendingCount;
  };

  // Form Submit: Voucher Generation
  document.getElementById('voucher-form').addEventListener('submit', (e) => {
    e.preventDefault();
    const qty = parseInt(document.getElementById('v-quantity').value);
    const profile = document.getElementById('v-profile').value;
    const price = parseFloat(document.getElementById('v-price').value);
    const prefix = document.getElementById('v-prefix').value.toUpperCase();
    const length = parseInt(document.getElementById('v-length').value);

    for (let i = 0; i < qty; i++) {
      const randomStr = Math.random().toString(36).substring(2, 2 + length).toUpperCase();
      const code = `${prefix}-${randomStr}`;
      state.vouchers.unshift({
        code,
        profile,
        price,
        createdAt: new Date().toISOString().slice(0, 16).replace('T', ' '),
        status: 'unused'
      });
      // Queue cloud sync
      state.cloudQueue.unshift({
        id: `op_sync_${Math.floor(100 + Math.random() * 900)}`,
        resourceType: 'voucher',
        resourceId: `v_${code}`,
        operation: 'upsert',
        idempotencyKey: `idemp_${code}`,
        attempts: 0,
        status: 'pending'
      });
    }

    renderVouchers();
    renderCloudQueue();
    showToast(`Successfully generated batch of ${qty} vouchers!`, 'success');
  });

  // Cloud Actions
  document.getElementById('btn-trigger-sync').addEventListener('click', () => {
    state.cloudQueue.forEach(q => {
      if (q.status === 'pending') {
        q.status = 'completed';
        q.attempts += 1;
      }
    });
    renderCloudQueue();
    showToast('WireSpot Cloud Synchronization completed!', 'success');
  });

  document.getElementById('btn-retry-failed-sync').addEventListener('click', () => {
    state.cloudQueue.forEach(q => {
      if (q.status === 'failed') {
        q.status = 'pending';
      }
    });
    renderCloudQueue();
    showToast('Failed operations queued for retry.', 'success');
  });

  document.getElementById('btn-clear-completed-sync').addEventListener('click', () => {
    const before = state.cloudQueue.length;
    state.cloudQueue = state.cloudQueue.filter(q => q.status !== 'completed');
    renderCloudQueue();
    showToast(`Cleared ${before - state.cloudQueue.length} completed sync operations.`, 'success');
  });

  document.getElementById('btn-test-cloud').addEventListener('click', () => {
    showToast('Cloud connection verified! API base URL is healthy (200 OK).', 'success');
  });

  document.getElementById('btn-save-cloud').addEventListener('click', () => {
    showToast('Cloud settings saved successfully.', 'success');
  });

  document.getElementById('voucher-search').addEventListener('input', (e) => {
    renderVouchers(e.target.value);
  });

  // Charts Setup
  const ctxBandwidth = document.getElementById('bandwidthChart').getContext('2d');
  const bandwidthChart = new Chart(ctxBandwidth, {
    type: 'line',
    data: {
      labels: ['11:20', '11:22', '11:24', '11:26', '11:28', '11:30'],
      datasets: [
        { label: 'Download (Mbps)', data: [24, 38, 45, 52, 48, 62], borderColor: '#3b82f6', tension: 0.4, fill: true, backgroundColor: 'rgba(59, 130, 246, 0.1)' },
        { label: 'Upload (Mbps)', data: [6, 12, 10, 15, 14, 18], borderColor: '#10b981', tension: 0.4, fill: false }
      ]
    },
    options: {
      responsive: true,
      plugins: { legend: { labels: { color: '#94a3b8' } } },
      scales: {
        x: { ticks: { color: '#94a3b8' }, grid: { color: 'rgba(255, 255, 255, 0.05)' } },
        y: { ticks: { color: '#94a3b8' }, grid: { color: 'rgba(255, 255, 255, 0.05)' } }
      }
    }
  });

  const ctxCpu = document.getElementById('cpuChart').getContext('2d');
  new Chart(ctxCpu, {
    type: 'line',
    data: {
      labels: ['11:20', '11:22', '11:24', '11:26', '11:28', '11:30'],
      datasets: [
        { label: 'CPU %', data: [12, 18, 15, 24, 20, 16], borderColor: '#6366f1', tension: 0.4, backgroundColor: 'rgba(99, 102, 241, 0.15)', fill: true }
      ]
    },
    options: {
      responsive: true,
      plugins: { legend: { labels: { color: '#94a3b8' } } },
      scales: {
        x: { ticks: { color: '#94a3b8' }, grid: { color: 'rgba(255, 255, 255, 0.05)' } },
        y: { ticks: { color: '#94a3b8' }, grid: { color: 'rgba(255, 255, 255, 0.05)' } }
      }
    }
  });

  const ctxSales = document.getElementById('salesChart').getContext('2d');
  new Chart(ctxSales, {
    type: 'bar',
    data: {
      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'],
      datasets: [
        { label: 'Voucher Sales ($)', data: [450, 620, 890, 1100, 1350, 1280, 1420, 1485], backgroundColor: '#3b82f6', borderRadius: 6 }
      ]
    },
    options: {
      responsive: true,
      plugins: { legend: { labels: { color: '#94a3b8' } } },
      scales: {
        x: { ticks: { color: '#94a3b8' }, grid: { color: 'rgba(255, 255, 255, 0.05)' } },
        y: { ticks: { color: '#94a3b8' }, grid: { color: 'rgba(255, 255, 255, 0.05)' } }
      }
    }
  });

  // Initial Render
  renderEvents();
  renderRouters();
  renderSessions();
  renderVouchers();
  renderCloudQueue();

  // AUTH MODAL LOGIC
  const modalAuth = document.getElementById('modal-auth');
  document.getElementById('btn-open-auth').addEventListener('click', () => modalAuth.classList.add('active'));
  document.getElementById('btn-close-auth').addEventListener('click', () => modalAuth.classList.remove('active'));

  const tabLogin = document.getElementById('tab-auth-login');
  const tabReg = document.getElementById('tab-auth-register');
  const formLogin = document.getElementById('form-auth-login');
  const formReg = document.getElementById('form-auth-register');

  tabLogin.addEventListener('click', () => {
    tabLogin.className = 'btn btn-primary';
    tabReg.className = 'btn btn-secondary';
    formLogin.style.display = 'block';
    formReg.style.display = 'none';
  });

  tabReg.addEventListener('click', () => {
    tabReg.className = 'btn btn-primary';
    tabLogin.className = 'btn btn-secondary';
    formReg.style.display = 'block';
    formLogin.style.display = 'none';
  });

  formLogin.addEventListener('submit', (e) => {
    e.preventDefault();
    const email = document.getElementById('auth-email-login').value;
    modalAuth.classList.remove('active');
    showToast(`Signed in as ${email}. Mobile pairing active!`, 'success');
  });

  formReg.addEventListener('submit', (e) => {
    e.preventDefault();
    const org = document.getElementById('auth-org-reg').value;
    const email = document.getElementById('auth-email-reg').value;
    modalAuth.classList.remove('active');
    showToast(`Account created for ${org}! Mobile pairing code active.`, 'success');
  });

  // GUIDED SETUP WIZARD LOGIC
  const modalWizard = document.getElementById('modal-wizard');
  let currentStep = 1;
  let selectedPreset = 'cafe';

  const wizardPresets = {
    cafe: { ssid: 'StarCoffee_Free_WiFi', packageName: 'Café 1Hour Free Pass', speed: 3, duration: 60 },
    hotel: { ssid: 'GrandResort_Guest_WiFi', packageName: 'Hotel 24Hour VIP Pass', speed: 10, duration: 1440 },
    school: { ssid: 'Campus_Student_WiFi', packageName: 'Campus Daily Pass', speed: 5, duration: 480 },
    retail: { ssid: 'Store_Quick_Pass', packageName: 'Retail 30Min Express Pass', speed: 5, duration: 30 }
  };

  document.getElementById('btn-open-wizard').addEventListener('click', () => {
    currentStep = 1;
    updateWizardUI();
    modalWizard.classList.add('active');
  });

  document.getElementById('btn-close-wizard').addEventListener('click', () => modalWizard.classList.remove('active'));

  // Preset Card Selection
  document.querySelectorAll('.preset-card').forEach(card => {
    card.addEventListener('click', () => {
      document.querySelectorAll('.preset-card').forEach(c => c.classList.remove('selected'));
      card.classList.add('selected');
      selectedPreset = card.getAttribute('data-preset');
    });
  });

  const updateWizardUI = () => {
    // Update step bar
    for (let i = 1; i <= 4; i++) {
      const stepEl = document.getElementById(`wiz-step-${i}`);
      const paneEl = document.getElementById(`pane-step-${i}`);
      if (i < currentStep) {
        stepEl.className = 'wizard-step completed';
      } else if (i === currentStep) {
        stepEl.className = 'wizard-step active';
      } else {
        stepEl.className = 'wizard-step';
      }
      paneEl.style.display = i === currentStep ? 'block' : 'none';
    }

    // Auto-populate preset defaults when entering Step 3
    if (currentStep === 3) {
      const p = wizardPresets[selectedPreset];
      document.getElementById('wiz-ssid').value = p.ssid;
      document.getElementById('wiz-package-name').value = p.packageName;
      document.getElementById('wiz-speed-limit').value = p.speed;
      document.getElementById('wiz-duration').value = p.duration;
    }

    // Generate RouterOS script when entering Step 4
    if (currentStep === 4) {
      const vendor = document.getElementById('wiz-router-vendor').value;
      const host = document.getElementById('wiz-router-host').value;
      const ssid = document.getElementById('wiz-ssid').value;
      const pkg = document.getElementById('wiz-package-name').value;
      const speed = document.getElementById('wiz-speed-limit').value;
      const dur = document.getElementById('wiz-duration').value;

      const script = `# WireSpot Auto-Configuration Script
# Business Template: ${selectedPreset.toUpperCase()}
# Target Host: ${host} (${vendor})
/ip hotspot profile add name="${pkg}" rate-limit="${speed}M/${speed}M" session-timeout=${dur}m
/ip hotspot add name="${ssid}" profile="${pkg}" interface=ether2 disabled=no
/ip hotspot user profile add name="${pkg}-Profile" rate-limit="${speed}M"
/system script add name="WireSpotCloudSync" source="/tool fetch url=\\"https://cloud.wirespot.app/api/v1/ping\\""
:log info "WireSpot Auto-Setup Completed for ${ssid}"`;

      document.getElementById('wiz-script-preview').value = script;
    }
  };

  // Step Navigation Handlers
  document.getElementById('btn-wiz-next-1').addEventListener('click', () => { currentStep = 2; updateWizardUI(); });
  document.getElementById('btn-wiz-next-2').addEventListener('click', () => { currentStep = 3; updateWizardUI(); });
  document.getElementById('btn-wiz-next-3').addEventListener('click', () => { currentStep = 4; updateWizardUI(); });

  document.getElementById('btn-wiz-back-2').addEventListener('click', () => { currentStep = 1; updateWizardUI(); });
  document.getElementById('btn-wiz-back-3').addEventListener('click', () => { currentStep = 2; updateWizardUI(); });
  document.getElementById('btn-wiz-back-4').addEventListener('click', () => { currentStep = 3; updateWizardUI(); });

  // One-Click Auto Deploy
  document.getElementById('btn-wiz-deploy').addEventListener('click', () => {
    const host = document.getElementById('wiz-router-host').value;
    const ssid = document.getElementById('wiz-ssid').value;
    const vendorLabels = {
      'mikrotik': 'MikroTik RouterOS',
      'ruijie': 'Ruijie Cloud',
      'openwrt': 'OpenWrt LuCI / ubus',
      'omada': 'TP-Link Omada OpenAPI',
      'unifi': 'Ubiquiti UniFi REST',
      'generic': 'Generic Router API'
    };

    // Add new router to state
    state.routers.unshift({
      name: `AutoGateway-${ssid}`,
      vendor: vendorLabels[vendor] || 'MikroTik RouterOS',
      ip: host,
      port: vendor === 'mikrotik' ? 8728 : vendor === 'ruijie' ? 443 : vendor === 'openwrt' ? 80 : 8443,
      status: 'online',
      users: 0
    });

    state.events.unshift({
      time: new Date().toTimeString().slice(0, 8),
      source: 'AutoSetupWizard',
      desc: `Deploys preset [${selectedPreset.toUpperCase()}] (${vendorLabels[vendor] || vendor}) to router at ${host}`,
      status: 'success'
    });

    renderRouters();
    renderEvents();
    modalWizard.classList.remove('active');
    showToast(`Successfully deployed auto-configuration to ${vendorLabels[vendor] || vendor} at ${host}!`, 'success');
  });

  // CLI TERMINAL CONSOLE LOGIC
  const modalCli = document.getElementById('modal-cli');
  document.getElementById('btn-close-cli').addEventListener('click', () => modalCli.classList.remove('active'));

  const cliInput = document.getElementById('cli-command-input');
  const cliOutput = document.getElementById('cli-output-text');
  const sendCliCmd = () => {
    const cmd = cliInput.value.trim();
    if (!cmd) return;
    cliOutput.textContent += `\n[admin@WireSpot-Gateway] > ${cmd}\n`;

    if (cmd.includes('user print') || cmd.includes('ubus call hotspot') || cmd.includes('get_users')) {
      cliOutput.textContent += `Flags: X - disabled, A - active
 #   NAME                  PROFILE         UPTIME      BYTES-IN    BYTES-OUT
 0   operator_admin        VIP-10MBPS      0s          1.2GiB      450MiB
 1   guest_user_1          Café-1Hour      45m12s      14.2MiB     1.8MiB\n`;
    } else if (cmd.includes('resource print') || cmd.includes('system status') || cmd.includes('sysinfo')) {
      cliOutput.textContent += ` uptime: 4d18h22m
 version: 7.12 / v22.03 (Multi-Vendor API)
 cpu-load: 14%
 free-memory: 412.5MiB
 total-memory: 512.0MiB\n`;
    } else {
      cliOutput.textContent += ` API Dispatcher: '${cmd}' -> Action successful (200 OK - Active Connector).\n`;
    }
    cliInput.value = '';
    cliOutput.scrollTop = cliOutput.scrollHeight;
  };

  document.getElementById('btn-send-cli').addEventListener('click', sendCliCmd);
  cliInput.addEventListener('keydown', (e) => { if (e.key === 'Enter') sendCliCmd(); });

  // THERMAL PRINTER CUSTOMIZER LOGIC
  const modalThermal = document.getElementById('modal-thermal');
  document.getElementById('btn-open-thermal').addEventListener('click', () => modalThermal.classList.add('active'));
  document.getElementById('btn-close-thermal').addEventListener('click', () => modalThermal.classList.remove('active'));

  const tpHeader = document.getElementById('tp-header');
  const tpFooter = document.getElementById('tp-footer');
  const tpWidth = document.getElementById('tp-width');

  const syncReceiptPreview = () => {
    document.getElementById('prev-tp-header').textContent = tpHeader.value || 'STARCOFFEE HOTSPOT PASS';
    document.getElementById('prev-tp-footer').textContent = tpFooter.value || 'Connect & enter code at starcoffee.wifi';
  };

  tpHeader.addEventListener('input', syncReceiptPreview);
  tpFooter.addEventListener('input', syncReceiptPreview);

  document.getElementById('btn-print-sample').addEventListener('click', () => {
    showToast(`Sent test POS receipt (${tpWidth.value}mm width) to thermal printer!`, 'success');
  });

  // DATE RANGE ANALYTICS FILTER
  const reportRange = document.getElementById('report-range');
  if (reportRange) {
    reportRange.addEventListener('change', () => {
      showToast(`Updated revenue report filter to: ${reportRange.options[reportRange.selectedIndex].text}`, 'info');
    });
  }

  // Render New Components
  renderHotspotUsers();
  renderUserProfiles();
});


