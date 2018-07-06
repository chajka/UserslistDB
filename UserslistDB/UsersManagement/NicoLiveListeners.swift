//
//  NicoLiveListeners.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/05.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa

class NicoLiveListeners: NSObject {
	private var currentUsers: Dictionary<String, NicoLiveUser>
	private var knownUsers: Dictionary<String, Dictionary<String, String>>

	init (listeners: [String: [String: String]]) {
		currentUsers = Dictionary()
		knownUsers = listeners
	}// end init

	
}// end class NicoLiveListeners
