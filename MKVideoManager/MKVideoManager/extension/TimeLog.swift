//
//  TimeLog.swift
//  MKVideoManager
//
//  Created by holla on 2019/6/14.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class TimeLog: NSObject {
	static func logTime(logString: String) {
//		let currentTime = Date().toString(style: .medium)
		let currentTime = Date().toString(format: .isoDateTimeMilliSec)
		print("\(currentTime) \(logString)")
	}
}
