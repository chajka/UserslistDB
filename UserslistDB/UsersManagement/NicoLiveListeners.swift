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
	private var knownUsers: NSMutableDictionary
	private var allKnownUsers: NSMutableDictionary

	init (listeners: NSMutableDictionary, allKnownUsers: NSMutableDictionary) {
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

	func activateUser (identifier: String, anonymous: Bool, lang: UserLanguage) throws -> NicoLiveUser {
		guard let entry: NSMutableDictionary = knownUsers.object(forKey: identifier) as? NSMutableDictionary else { throw UserslistError.canNotUserActivate }
		let user: NicoLiveUser = NicoLiveUser(user: entry, identifier: identifier, anonymous: anonymous, lang: lang)
		allKnownUsers.setValue(anonymous, forKey: identifier)
		return user
	}// end func activateUser
}// end class NicoLiveListeners
