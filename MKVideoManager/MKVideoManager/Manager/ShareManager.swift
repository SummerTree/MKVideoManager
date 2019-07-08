//
//  ShareManager.swift
//  MKVideoManager
//
//  Created by holla on 2019/6/24.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class ShareManager: NSObject {
	typealias ShareVideoHandler = (URL?, Error?) -> Void

	static let shared = ShareManager()

	override init() {}

	func shareFamousVideoToWhatsApp(localUrl: URL, completionHandler: ShareVideoHandler? = nil) {
		let shareActivity = UIActivityViewController(activityItems: [localUrl], applicationActivities: nil)
		let backgroundVC: UIViewController = UIApplication.shared.keyWindow!.rootViewController!.presentedViewController!
		let sorceView: UIView = backgroundVC.view
		shareActivity.completionWithItemsHandler = { (activityType, result, _, error) in
			completionHandler?(localUrl, error)
		}
		shareActivity.popoverPresentationController?.sourceView = sorceView
		shareActivity.popoverPresentationController?.sourceRect = sorceView.bounds
		backgroundVC.present(shareActivity, animated: true, completion: nil)
	}

	func shareFamousVideoToWhatsAppUTI(localUrl: URL, completionHandler: ShareVideoHandler? = nil) {
		let documentIC = UIDocumentInteractionController(url: localUrl)
		documentIC.uti = "net.whatsapp.movie"
		documentIC.delegate = self
		let backgroundVC: UIViewController = UIApplication.shared.keyWindow!.rootViewController!.presentedViewController!
		let sourceView: UIView = backgroundVC.view
		documentIC.presentOpenInMenu(from: CGRect.zero, in: sourceView, animated: true)
	}
}

extension ShareManager: UIDocumentInteractionControllerDelegate {
}
