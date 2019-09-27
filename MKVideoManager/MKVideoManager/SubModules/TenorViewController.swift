//
//  TenorViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/7/10.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class TenorViewController: UIViewController {
	let tenorApiKey: String = "IFNJYKY20P0E"

	override func viewDidLoad() {
		super.viewDidLoad()
		/*
		If this is a returning user, grab their stored anonymous ID and jump directly to getting data
		Otherwise this is a new user, so start the flow by getting an anonymous id and having the callback store it & pass it to requestData
		*/
		if let anonymousID = UserDefaults.standard.string(forKey: "anonymousID") {
			requestData(anonymousID: anonymousID)
		} else {
			let anonymousIDRequest = URLRequest(url: URL(string: String(format: "https://api.tenor.com/v1/anonid?key=%@", tenorApiKey))!)
			makeWebRequest(urlRequest: anonymousIDRequest, callback: tenorAnonymousIDHandler)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	/**
	Execute web request to retrieve the top GIFs returned(in batches of 8) for the given search term.
	*/
	func requestData(anonymousID: String) {
		// the test search term
		let searchTerm = "excited"

		// Define the results upper limit
		let limit = 8

		// make initial search request for the first 8 items
		let searchRequest = URLRequest(url: URL(string: String(format: "https://api.tenor.com/v1/search?q=%@&key=%@&anon_id=%@&limit=%d",
															   searchTerm,
															   tenorApiKey,
															   anonymousID,
															   limit))!)

		makeWebRequest(urlRequest: searchRequest, callback: tenorSearchHandler)

		// Data will be loaded by each request's callback
	}

	/**
	Async URL requesting function.
	*/
	func makeWebRequest(urlRequest: URLRequest, callback: @escaping ([String: AnyObject]) -> Void) {
		// Make the async request and pass the resulting json object to the callback
		let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
			do {
				if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] {
					// Push the results to our callback
					callback(jsonResult)
				}
			} catch let error as NSError {
				print(error.localizedDescription)
			}
		}
		task.resume()
	}

	/**
	Web response handler for search requests.
	*/
	func tenorSearchHandler(response: [String: AnyObject]) {
		// Parse the json response
//		let responseGifs = response["results"]!
		// Load the GIFs into your view
		print("Result GIFS: (responseGifs)")
	}

	/**
	Web response handler for anonymous id -- for first time users
	*/
	func tenorAnonymousIDHandler(response: [String: AnyObject]) {
		// Read the anonymous id for the user
		let anonymousID = response["anon_id"] as! String

		// Store the anonymousID for use in later API calls
		UserDefaults.standard.setValue(anonymousID, forKey: "anonymousID")

		// Pass the id to the main processing function requestData
		requestData(anonymousID: anonymousID)
	}

	@IBAction func startclicked(_ sender: Any) {
	}
}
