//
//  JSONizableUser.swift
//  Charleston
//
//  Created by Я Чайка on 2019/05/07.
//  Copyright © 2019 Чайка. All rights reserved.
//

import Cocoa

public final class JSONizableUser: NSObject, Codable {
		// MARK: - Properties
	public var handle: String
	public var known: Bool?
	public var lock: Bool?
	public var color: String?
	public var voice: String?
	public var note: String?
	public var lastMet: String
	
		// MARK: - Member variables
		// MARK: - Constructor/Destructor
	init (_ handle: String, metAt met: Date = Date()) {
		self.handle = handle
		let formatter:DateFormatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		formatter.timeStyle = DateFormatter.Style.short
		self.lastMet = formatter.string(from: met)
	}// end init

	init(_ handle: String, metAt met: String) {
		self.handle = handle
		lastMet = met
	}// end init
	
		// MARK: - Override
		// MARK: - Actions
		// MARK: - Public methods
		// MARK: - Internal methods
		// MARK: - Private methods
		// MARK: - Delegates
}// end class User
