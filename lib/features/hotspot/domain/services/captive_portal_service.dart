import '../entities/captive_portal_template.dart';

enum CaptivePortalVendor { mikrotik, openwrt, ruijie, generic }

class CaptivePortalService {
  const CaptivePortalService();

  String generateHtml(
    CaptivePortalTemplate template, {
    CaptivePortalVendor vendor = CaptivePortalVendor.mikrotik,
  }) {
    final actionUrl = switch (vendor) {
      CaptivePortalVendor.mikrotik => '\$(link-login-only)',
      CaptivePortalVendor.openwrt => '\$authtarget',
      CaptivePortalVendor.ruijie => '\$(link-login)',
      CaptivePortalVendor.generic => '/login',
    };

    final usernameField = switch (vendor) {
      CaptivePortalVendor.mikrotik => 'username',
      CaptivePortalVendor.openwrt => 'tok',
      CaptivePortalVendor.ruijie => 'username',
      CaptivePortalVendor.generic => 'username',
    };

    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${template.businessName} - Hotspot Login</title>
  <style>
    :root {
      --primary: ${template.primaryColorHex};
      --bg: ${template.backgroundColorHex};
      --card: ${template.cardColorHex};
      --text: ${template.textColorHex};
    }
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', system-ui, sans-serif; }
    body {
      background: var(--bg);
      color: var(--text);
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      padding: 16px;
    }
    .card {
      background: var(--card);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 16px;
      padding: 32px 24px;
      width: 100%;
      max-width: 420px;
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
      text-align: center;
    }
    .badge {
      display: inline-block;
      padding: 6px 12px;
      background: rgba(255, 255, 255, 0.08);
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
      color: var(--primary);
      margin-bottom: 16px;
    }
    h1 { font-size: 22px; font-weight: 700; margin-bottom: 8px; }
    p.tagline { font-size: 14px; opacity: 0.8; margin-bottom: 24px; }
    .form-group { margin-bottom: 16px; text-align: left; }
    label { font-size: 12px; font-weight: 600; opacity: 0.9; display: block; margin-bottom: 6px; }
    input {
      width: 100%;
      padding: 12px 14px;
      border-radius: 8px;
      border: 1px solid rgba(255, 255, 255, 0.2);
      background: rgba(0, 0, 0, 0.2);
      color: var(--text);
      font-size: 14px;
      outline: none;
    }
    input:focus { border-color: var(--primary); }
    button {
      width: 100%;
      padding: 14px;
      border-radius: 8px;
      border: none;
      background: var(--primary);
      color: #ffffff;
      font-size: 15px;
      font-weight: 700;
      cursor: pointer;
      margin-top: 12px;
    }
    .footer { font-size: 11px; opacity: 0.6; margin-top: 24px; line-height: 1.4; }
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">${template.businessName}</div>
    <h1>${template.welcomeHeadline}</h1>
    <p class="tagline">${template.tagline}</p>

    <form action="$actionUrl" method="post">
      ${template.showVoucherInput ? '''
      <div class="form-group">
        <label for="voucher">Voucher Code</label>
        <input type="text" id="voucher" name="$usernameField" placeholder="Enter voucher code (e.g. WS-8A2F)" required>
      </div>
      ''' : ''}
      <button type="submit">${template.loginButtonLabel}</button>
    </form>

    <div class="footer">
      <p>${template.termsAndConditions}</p>
      <p style="margin-top: 6px;">${template.supportContact}</p>
      <p style="margin-top: 6px; font-size: 10px;">Powered by WireSpot</p>
    </div>
  </div>
</body>
</html>''';
  }
}
