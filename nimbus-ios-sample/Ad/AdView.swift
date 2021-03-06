//
//  AdView.swift
//  nimbus-ios-sample
//
//  Created by Victor Takai on 19/11/21.
//

import UIKit
import NimbusKit

final class AdView: UIView {
    
    private let ad: NimbusAd
    private let companionAd: NimbusCompanionAd?
    private let viewController: UIViewController
    private lazy var nimbusAdView = NimbusAdView(adPresentingViewController: viewController)
    private weak var delegate: AdControllerDelegate?
    
    init(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd? = nil,
        viewController: UIViewController,
        delegate: AdControllerDelegate? = nil
    ) {
        self.ad = ad
        self.companionAd = companionAd
        self.viewController = viewController
        self.delegate = delegate
        
        super.init(frame: CGRect.zero)
        
        setupAdView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func destroy() {
        nimbusAdView.destroy()
    }
    
    private func setupAdView() {
        addSubview(nimbusAdView)
        
        nimbusAdView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nimbusAdView.topAnchor.constraint(equalTo: topAnchor),
            nimbusAdView.bottomAnchor.constraint(equalTo: bottomAnchor),
            nimbusAdView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nimbusAdView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        nimbusAdView.delegate = delegate

        nimbusAdView.render(ad: ad, companionAd: companionAd)
        nimbusAdView.start()
    }
}
