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
	private var knownUsersOnymity: Dictionary<String, Bool>

		// MARK: - Constructor/Destructor
	public override init () {
		knownOwners = Dictionary()
		knownUsersOnymity = Dictionary()
	}// end initt

		// MARK: - Override
	public override func isEqual (_ object: Any?) -> Bool {
		guard let rhs:JSONizableAllUsers = object as? JSONizableAllUsers else { return false }
		return knownOwners == rhs.knownOwners && knownUsersOnymity == rhs.knownUsersOnymity
	}// end isEqual

		// MARK: - Actions
		// MARK: - Public methods
	public func users (forOwner owner: String, anonymousCommentDefault: Bool = true, monitorDefault: Bool = false) -> JSONizableUsers {
		if let users: JSONizableUsers = knownOwners[owner] {
			return users
		}// end optional binding chek for owner identifier entry in owners dictionary

		let users: JSONizableUsers = JSONizableUsers()
		users.anonymousComment = anonymousCommentDefault
		users.monitor = monitorDefault
		return addUsers(forOwner: owner, to: users)
	}// end func users

	public func addUsers (forOwner identifier: String, to users: JSONizableUsers = JSONizableUsers()) -> JSONizableUsers {
		knownOwners[identifier] = users

		return users
	}// end addOwner

	public func onymoity (ofUserIdentifier identifier: String) -> Bool? {
		guard let anonymous: Bool = knownUsersOnymity[identifier] else { return nil }
		return anonymous
	}// end known user

	public func addUser (identifier user: String, onymity signed: Bool) {
		knownUsersOnymity[user] = signed
	}// end addUser

	public func cleanupOutdatedUser (before date: String) {
		for owner in knownOwners {
			owner.value.cleanupOutdatedUser(before: date, onymityDict: &knownUsersOnymity)
		}// end foreach all owners
	}// end cleanupOutdatedUser

		// MARK: - Internal methods
		// MARK: - Private methods
		// MARK: - Delegates
}// end class JSONizableAllUsers
