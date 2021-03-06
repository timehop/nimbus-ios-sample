//
//  AppDelegate.swift
//  nimbus-ios-sample
//
//  Created by Victor Takai on 08/11/21.
//

import UIKit

import NimbusKit
import NimbusRequestAPSKit
import NimbusRenderStaticKit
import NimbusRenderVideoKit
import NimbusRenderOMKit

import FBAudienceNetwork
import GoogleMobileAds

import AppTrackingTransparency

#if canImport(NimbusSDK)
import NimbusSDK
#endif

#if canImport(NimbusRenderFANKit)
import NimbusRenderFANKit
#endif

#if canImport(NimbusUnityKit)
import NimbusUnityKit
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNimbusSDK()
        setupFAN()
        setupGAM()
        
        return true
    }

    private func setupNimbusSDK() {
        Nimbus.shared.initialize(
            publisher: ConfigManager.shared.publisherKey,
            apiKey: ConfigManager.shared.apiKey
        )
        
        // This is only for testing environment, do NOT add this on production environment
        let url = URL(string: "https://dev-sdk.adsbynimbus.com/rta/test")!
        NimbusAdManager.requestUrl = url
        NimbusAdManager.additionalRequestHeaders = [
            "Nimbus-Test-No-Fill": String(UserDefaults.standard.forceNoFill)
        ]
        
        #if DEBUG
        Nimbus.shared.logLevel = .info
        #endif
        Nimbus.shared.testMode = UserDefaults.standard.nimbusTestMode
        Nimbus.shared.coppa = UserDefaults.standard.coppaOn

        NimbusAdManager.demandProviders = []
        
        // Demand Providers
        if let aps = DemoDemandProviders.shared.aps {
            NimbusAdManager.demandProviders?.append(aps)
        }
                        
        // Renderers
        let videoRenderer = NimbusVideoAdRenderer()
        videoRenderer.showMuteButton = true
        Nimbus.shared.renderers = [
            .forAuctionType(.static): NimbusStaticAdRenderer(),
            .forAuctionType(.video): videoRenderer,
            .forNetwork("facebook"): NimbusFANAdRenderer(),
            .forNetwork("unity"): NimbusUnityAdRenderer()
        ]

        // User
        var user = NimbusUser(age: 20, gender: .male)
        user.configureGdprConsent(didConsent: UserDefaults.standard.gdprConsent)
        NimbusAdManager.user = user
        
        // OM Viewability initialization
        // Verification providers can be added here
        // OMID flag can be turned ON (example in the Settings)
        Nimbus.shared.viewabilityProvider = .init(
            builder: NimbusAdViewabilityTrackerBuilder(verificationProviders: nil)
        )
    }

    private func setupFAN() {
        FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in () })
        }
        // Required for test ads
        FBAdSettings.setAdvertiserTrackingEnabled(true)
    }

    private func setupGAM() {
        /*
         In order to test GAM in real devices please follow the steps below.
         For more info please refer to https://developers.google.com/ad-manager/mobile-ads-sdk/ios/test-ads#enable_test_devices
         If you want to test ads in your app as you're developing, follow the steps below to programmatically register your test device.

         Load your ads-integrated app and make an ad request.
         Check the console for a message that looks like this:

         <Google> To get test ads on this device, set:
         GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers =
         @[ @"2077ef9a63d2b398840261c8221a0c9b" ];
         */
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}

