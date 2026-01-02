#!/bin/bash

# Notarization script for RestNow app
# This script will submit the DMG to Apple for notarization

echo "RestNow Notarization Script"
echo "==========================="
echo ""
echo "Please enter your Apple ID email:"
read -r APPLE_ID
echo ""
echo "Please enter your app-specific password:"
echo "(Get one from: https://appleid.apple.com/account/manage)"
read -s APP_PASSWORD
echo ""

echo "Submitting RestNow.dmg for notarization..."
echo "This may take a few minutes..."
echo ""

xcrun notarytool submit RestNow.dmg \
  --apple-id "$APPLE_ID" \
  --password "$APP_PASSWORD" \
  --team-id X58RRVF448 \
  --wait

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Notarization successful!"
    echo ""
    echo "Now stapling the notarization ticket to the DMG..."
    xcrun stapler staple RestNow.dmg

    if [ $? -eq 0 ]; then
        echo ""
        echo "✓ Notarization ticket stapled successfully!"
        echo ""
        echo "Verifying the DMG..."
        spctl --assess --type open --context context:primary-signature -vv RestNow.dmg
        echo ""
        echo "✓ All done! Your DMG is now notarized and ready for distribution."
        echo ""
        echo "Calculating SHA256 checksum for Homebrew formula..."
        shasum -a 256 RestNow.dmg
    else
        echo ""
        echo "✗ Failed to staple notarization ticket."
        exit 1
    fi
else
    echo ""
    echo "✗ Notarization failed. Check the output above for errors."
    exit 1
fi
