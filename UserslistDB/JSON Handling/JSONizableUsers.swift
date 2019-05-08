//
//  JSONizableUsers.swift
//  Charleston
//
//  Created by Я Чайка on 2019/05/07.
//  Copyright © 2019 Чайка. All rights reserved.
//

import Cocoa

public final class JSONizableUsers: NSObject, Codable {
		// MARK: - Properties
	public var anonymousComment: Bool
	public var monitor: Bool

		// MARK: - Member variables
	private var listener: Dictionary<String, JSONizableUser>

		// MARK: - Constructor/Destructor
	public convenience override init () {
		self.init(anonymousComment: true, enableMoonitor: false)
	}// end convenience init

	public init (anonymousComment anonymous: Bool, enableMoonitor monitor: Bool) {
		self.anonymousComment = anonymous
		self.monitor = monitor
		listener = Dictionary()
	}// end init

		// MARK: - Override
		// MARK: - Actions
		// MARK: - Public methods
	public func user (identifier id: String) -> JSONizableUser? {
		return listener[id]
	}// end func user of

	public func addUser (identifier id: String, with user: JSONizableUser)  {
		listener[id] = user
	}// end func id

		// MARK: - Internal methods
		// MARK: - Private methods
		// MARK: - Delegates
}// end class Users
