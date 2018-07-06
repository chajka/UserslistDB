//
//  NicoLiveListeners.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/05.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa
import DeuxCheVaux

class NicoLiveListeners: NSObject {
	private var currentUsers: Dictionary<String, NicoLiveUser>
	private var knownUsers: Dictionary<String, Dictionary<String, String>>
	private var allKnownUsers: Dictionary<String, Bool>

	init (listeners: Dictionary<String, Dictionary<String, String>>, allKnownUsers:Dictionary<String, Bool>) {
		currentUsers = Dictionary()
		knownUsers = listeners
		self.allKnownUsers = allKnownUsers
	}// end init

	func user (identifier: String) throws -> NicoLiveUser {
		if let user:NicoLiveUser = currentUsers[identifier] {
			return user
		} else {
			if let _ = knownUsers[identifier] { throw UserslistError.entriedUser }
			else if let _ = allKnownUsers[identifier] {throw UserslistError.inDatabaseUser }
			else { throw UserslistError.unknownUser }
		}// end if current user is in current users dictionary
	}// end func user
}// end class NicoLiveListeners
