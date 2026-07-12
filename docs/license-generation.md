# WireSpot Device Licenses

WireSpot uses a local 7-day trial. After the trial, the app requires a
device-bound license key.

## Operator Flow

1. Open `Settings`.
2. Copy the `Device license ID`.
3. Generate a license for that exact ID.
4. Enter the generated key in `Settings`.

## Generate A License

From the project root:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\dart.bat run tools\license_generator.dart DEVICE_ID
```

Example:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\dart.bat run tools\license_generator.dart 1234567890ABCDEF
```

The output license works only for that device ID.

## Notes

This is an offline licensing foundation for testing and early distribution.
For Play Store production, use Google Play Billing plus server-side license
validation so keys cannot be forged from the app binary.
