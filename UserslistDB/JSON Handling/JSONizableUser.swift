//
//  JSONizableUser.swift
//  Charleston
//
//  Created by Я Чайка on 2019/05/07.
//  Copyright © 2019 Чайка. All rights reserved.
//

import Cocoa

public final class JSONizableUser: NSObject, Codable {
		// MARK: static methods
	public override func isEqual(_ object: Any?) -> Bool {
		guard let rhs: JSONizableUser = object as? JSONizableUser else { return false }

		var same : Bool = true
		same = self.handle == rhs.handle ? same && true : same && false
		same = self.known == rhs.known ? same && true : same && false
		same = self.lock == rhs.lock ? same && true : same && false
		same = self.color == rhs.color ? same && true : same && false
		same = self.voice == rhs.voice ? same && true : same && false
		same = self.note == rhs.note ? same && true : same && false
		same = self.lastMet == rhs.lastMet ? same && true : same && false

		return same
	}// end override func isEqual

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
	public init (_ handle: String, _ known: Bool? = nil, _ lock: Bool? = nil, _ color: String? = nil, _ voice: String? = nil) {
		self.handle = handle
		if let known: Bool = known { self.known = known }
		if let lock: Bool = lock { self.lock = lock }
		if let color: String = color { self.color = color }
		if let voice: String = voice { self.voice = voice }
		let formatter:DateFormatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		formatter.timeStyle = DateFormatter.Style.short
		self.lastMet = formatter.string(from: Date())
	}// end init

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
