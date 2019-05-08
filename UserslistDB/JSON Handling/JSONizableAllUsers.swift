//
//  JSONizableAllUsers.swift
//  Charleston
//
//  Created by Я Чайка on 2019/05/08.
//  Copyright © 2019 Чайка. All rights reserved.
//

import Cocoa

public final class JSONizableAllUsers: NSObject, Codable {
		// MARK: - Properties
		// MARK: - Member variables
	private var knownOwners: Dictionary<String, JSONizableUsers>
	private var knownUsersAnonymity: Dictionary<String, Bool>

		// MARK: - Constructor/Destructor
	public override init() {
		knownOwners = Dictionary()
		knownUsersAnonymity = Dictionary()
	}// end initt

		// MARK: - Override
	public override func isEqual(_ object: Any?) -> Bool {
		guard let rhs:JSONizableAllUsers = object as? JSONizableAllUsers else { return false }
		return knownOwners == rhs.knownOwners && knownUsersAnonymity == rhs.knownUsersAnonymity
	}
		// MARK: - Actions
		// MARK: - Public methods
	public func users (forOwner owner: String) -> JSONizableUsers {
		if let users: JSONizableUsers = knownOwners[owner] {
			return users
	}// end optional binding chek for owner identifier entry in owners dictionary
		
		return addUsers(forOwner: owner)
	}// end func users

	public func addUsers (forOwner identifier: String, to users: JSONizableUsers = JSONizableUsers()) -> JSONizableUsers {
		knownOwners[identifier] = users
	
		return users
	}// end addOwner
	
	public func isAnnonymousUser ( identifierOf identifier: String) -> Bool? {
		guard let anonymous: Bool = knownUsersAnonymity[identifier] else { return nil }
		return anonymous
	}// end known user

	public func addUser (identifier user: String, anonymity anon: Bool) {
		knownUsersAnonymity[user] = anon
	}// end addUser

		// MARK: - Internal methods
		// MARK: - Private methods
		// MARK: - Delegates
}// end class JSONizableAllUsers
