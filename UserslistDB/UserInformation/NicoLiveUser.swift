//
//  NicoLiveUser.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/01.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa
import DeuxCheVaux

public enum Friendship {
	case new
	case known
	case met
	case metOther
}// end enum Friendship

public enum Privilege {
	case listener
	case owner
	case guide
	case cruise
	case official
}// end enum Privilege

public final class UserName {
	public let identifier: String
	public var nickname: String
	public var handle: String
	public var firstCommentNumber: String?
	public var isValidHandle: Bool {
		get {
			return (handle == String(identifier.prefix(handle.count))) ? false : true
		}// end get
	}// end read only property get
	
	
	init (identifier: String, nickname: String = "", handle: String = "") {
		self.identifier = identifier
		self.nickname = nickname.isEmpty ? String(identifier.prefix(10)) : nickname
		self.handle = handle.isEmpty ? self.nickname : handle
	}// end init

	init (identifier: String, nickname: String = "") {
		self.identifier = identifier
		if nickname.isEmpty { self.nickname = String(identifier.prefix(10)) }
		else { self.nickname = nickname }
		self.handle = self.nickname
	}// end init
}// end struct UserName

public final class NicoLiveUser: NSObject {
        // MARK:   Outlets
        // MARK: - Properties
    public var name: UserName
	public var handle: String {
		get {
			return name.handle
		}// end get
		set (newHandle) {
			name.handle = newHandle
			entry.handle = newHandle
			update(friendship: .known)
		}// end set
	}// end property handle
	public let premium: Int
	public let anonymous: Bool
	public let isPremium: Bool
	public var privilege: Privilege!
	public let language: UserLanguage
	public var friendship: Friendship
	@objc public dynamic var thumbnail: NSImage?
	public var lock: Bool = false {
		didSet {
			entry.lock = lock
			update(friendship: .known)
		}// end didSet
	}// end property lock
	public let lastMet: Date
	public var color: NSColor?
	public var voice: String? {
		didSet {
			entry.voice = voice
			update(friendship: .known)
		}// end didSet
	}// end property voice
	public var note: String? {
		didSet {
			entry.note = note
			update(friendship: .known)
		}// end didSet
	}// end property note
	
        // MARK: - Member variables
	private(set) unowned var entry: JSONizableUser
	
        // MARK: - Constructor/Destructor
	public init (owner  identifier: String, ownerEntry entry: JSONizableUser, nickname ownerNickname: String) {
		self.entry = entry
		self.name = UserName(identifier: identifier, nickname: ownerNickname)
		self.premium = 3
		anonymous = false
		isPremium = true
		privilege = Privilege.owner
		language = UserLanguage.ja
		friendship = Friendship.known
		lastMet = Date()
		super.init()
		handle = ownerNickname
	}// end init owner user

	public init (user: JSONizableUser, identifier: String, nickname: String, premium: Int, anonymous: Bool, lang: UserLanguage) {
		entry = user
		language = lang
		let handlename: String = entry.handle
		name = UserName(identifier: identifier, nickname: nickname, handle: handlename)
		self.premium = premium
		isPremium = (premium & (0x01 << 0)) != 0x00 ? true : false
		if premium ^ 0b11 == 0 { privilege = Privilege.owner }
		else if premium ^ 0b10 == 0 { privilege = Privilege.cruise }
		else if premium ^ 0b110 == 0 { privilege = Privilege.official }
		else { privilege = Privilege.listener }
		self.anonymous = anonymous
		if let known: Bool = entry.known { friendship = known ? Friendship.known : Friendship.met }
		else { friendship = Friendship.metOther }
		if let lock: Bool = entry.lock { self.lock = lock }
		// update time
		let formatter: DateFormatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		formatter.timeStyle = DateFormatter.Style.short
		if let date: Date = formatter.date(from: entry.lastMet) { lastMet = date }
		else { lastMet = Date() }
		entry.lastMet = formatter.string(from: Date())
		super.init()
		if let colorString: String = entry.color { color = hexcClorToColor(hexColor: colorString) }
		if let voiceName: String = entry.voice { voice = voiceName }
		if let noteString: String = entry.note { note = noteString }
	}// end init from entry
	
		// MARK: - Override
		// MARK: - Actions
		// MARK: - Public methods
	public func setColor (hexColor: String) -> Void {
		color = hexcClorToColor(hexColor: hexColor)
		entry.setValue(hexColor, forKey: JSONKey.user.color.rawValue)
		update(friendship: .known)
	}// end setColor
	
	public func setColor (rgbColor: NSColor) -> Void {
		color = rgbColor
		entry.setValue(rgbColorToHexColor(rgbColor: rgbColor), forKey: JSONKey.user.color.rawValue)
		update(friendship: .known)
	}// end setColor
	
	public func addEntryTo (listensers: NSMutableDictionary) {
		let identifier = name.identifier
		listensers.setValue(entry, forKey: identifier)
	}// end func addEntryTo

	public func invert(lockStatus identifier: String) {
		self.lock = !self.lock
	}// end invert lock status

	public func update (friendship newFriendship:Friendship) {
		self.friendship = newFriendship
	}// end update friendship
	
		// MARK: - Private methods
	private func hexcClorToColor (hexColor: String) -> NSColor {
		guard hexColor.count == 7, hexColor.prefix(1) == "#" else { return NSColor.white }
		let redStr: String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 1) ... hexColor.index(hexColor.startIndex, offsetBy: 2)].description
		let greenStr: String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 3) ... hexColor.index(hexColor.startIndex, offsetBy: 4)].description
		let blueStr: String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 5) ..< hexColor.endIndex].description
		
		let red: CGFloat = CGFloat(Int(redStr)!) / 0xff
		let green: CGFloat = CGFloat(Int(greenStr)!) / 0xff
		let blue: CGFloat = CGFloat(Int(blueStr)!) / 0xff
		
		return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
	}// end func hexColorToColor
	
	private func rgbColorToHexColor (rgbColor: NSColor) -> String {
		var red: CGFloat = 1.0
		var green: CGFloat = 1.0
		var blue: CGFloat = 1.0
		var alpha: CGFloat = 1.0
		rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		
		let intRed: Int = Int(red * 0xff)
		let intGreen: Int = Int(green * 0xff)
		let intBlue: Int = Int(blue * 0xff)
		let hexColor: String = String(format: "#%02x%02x%02x", intRed, intGreen, intBlue)
		
		return hexColor
	}// end func rgbColorToHexColor

		// MARK: - Delegates
}// end class NicoLiveUser
