## Summary

Describe what changed and why.

## Type

- [ ] Feature
- [ ] Bug fix
- [ ] Documentation
- [ ] Security
- [ ] Build/configuration
- [ ] Refactor
- [ ] Release preparation

## Area

- [ ] Authentication / PIN / biometric
- [ ] Router connectors / router management
- [ ] WireGuard / VPN
- [ ] Hotspot users / profiles / sessions
- [ ] Vouchers / receipts / QR
- [ ] Bluetooth printing
- [ ] Reports / export
- [ ] Settings / licensing / co-branding
- [ ] Android platform code
- [ ] Documentation / governance

## Verification

- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Android debug APK build
- [ ] Manual app test on Android phone
- [ ] Real MikroTik RouterOS test
- [ ] Real non-MikroTik router/controller test
- [ ] WireGuard tunnel test
- [ ] Bluetooth printer test
- [ ] Not applicable

## Router / Android Notes

Mention affected RouterOS commands, router brand connectors, Android
permissions, VPN behavior, database migrations, platform-channel calls, or Play
Store/release behavior.

## Screenshots Or Logs

Attach screenshots when UI changed. Remove router credentials, WireGuard keys,
license secrets, customer data, and private IP details if they are sensitive.

## Security Checklist

- [ ] No real router credentials committed.
- [ ] No WireGuard private keys committed.
- [ ] No customer or sales data committed.
- [ ] No Android keystore or signing passwords committed.
- [ ] No Play Billing, server license, or production API secrets committed.
- [ ] No copied proprietary code/assets/templates included.
