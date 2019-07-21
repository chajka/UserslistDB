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

fileprivate let Radix: Int = 0x10
fileprivate let OffsetRed: Int = 1
fileprivate let OffsetGreen: Int = 3
fileprivate let OffsetBlue: Int = 5
fileprivate let OffsetAlpha: Int = 7
fileprivate let ColorDigit: Int = 2
fileprivate let MaxValue: CGFloat = 0xff
fileprivate let RGBColorCount: Int = 7
fileprivate let RGBAColorCount: Int = 9
fileprivate let PaddingCharacter: Character = "0"

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
			if lock { return }
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
	public var friendship: Friendship {
		didSet {
			switch friendship {
			case .known:
				entry.known = true
			default:
				entry.known = nil
			}// end switch case by friendship
		}// end 
	}// end property friendship
	@objc public dynamic var thumbnail: NSImage?
	public var lock: Bool = false {
		didSet {
			entry.lock = lock
			update(friendship: .known)
		}// end didSet
	}// end property lock
	public let lastMet: Date
	public var color: NSColor? {
		willSet {
			if lock { return }
		}// end willSet
	}// end side effect with stored property
	public var voice: String? {
		willSet {
			if lock { return }
		}// end willSet
		didSet {
			entry.voice = voice
			update(friendship: .known)
		}// end didSet
	}// end side effect with stored property voice
	public var note: String? {
		didSet {
			entry.note = note
			update(friendship: .known)
		}// end didSet
	}// end side effect with stored property note

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
		if let lock: Bool = entry.lock { self.lock = lock }
		lastMet = Date()
		super.init()
		if let colorString: String = entry.color { color = hexcClorToColor(hexColor: colorString) }
		if let voiceName: String = entry.voice { voice = voiceName }
		if let noteString: String = entry.note { note = noteString }
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
	private func hexcClorToColor (hexColor colorString: String) -> NSColor {
		var rangeFrom: String.Index
		var rangeTo: String.Index
		let hexColortMax: CGFloat = CGFloat(0xff)
		let length: Int = colorString.count
		let capableLength: Set = Set(arrayLiteral: 7, 9)
		if capableLength.contains(length) {
			var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 1.0
			rangeFrom = colorString.index(colorString.startIndex, offsetBy: 1)
			rangeTo = colorString.index(rangeFrom, offsetBy: 1)
			let hexRed: String = String(colorString[rangeFrom ... rangeTo])
			red = CGFloat(UInt(hexRed, radix: 16) ?? 0) / hexColortMax

			rangeFrom = colorString.index(colorString.startIndex, offsetBy: 3)
			rangeTo = colorString.index(rangeFrom, offsetBy: 1)
			let hexGreen: String = String(colorString[rangeFrom ... rangeTo])
			green = CGFloat(UInt(hexGreen, radix: 16) ?? 0) / hexColortMax

			rangeFrom = colorString.index(colorString.startIndex, offsetBy: 5)
			rangeTo = colorString.index(rangeFrom, offsetBy: 1)
			let hexBlue: String = String(colorString[rangeFrom ... rangeTo])
			blue = CGFloat(UInt(hexBlue, radix: 16) ?? 0) / hexColortMax
			if length == 9 {
				rangeFrom = colorString.index(colorString.startIndex, offsetBy: 7)
				rangeTo = colorString.index(rangeFrom, offsetBy: 1)
				let hexAlpha: String = String(colorString[rangeFrom ... rangeTo])
				alpha = CGFloat(UInt(hexAlpha, radix: 16) ?? 0) / hexColortMax
			}// end if have alpha string
			let color: NSColor = NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)

			return color
		}// end if length of color string is 7 or 9

		return NSColor.clear
	}// end hexcClorToColor

	private func rgbColorToHexColor (rgbColor color: NSColor) -> String {
		var red: CGFloat = 0.0
		var green: CGFloat = 0.0
		var blue: CGFloat = 0.0
		var alpha: CGFloat = 0.0
		color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

		var hexColor: String = "#"
		for elem: CGFloat in [red, green, blue] {
			let colorLevel: UInt = UInt(elem * CGFloat(0xff))
			let element: String = String(colorLevel, radix: 16)
			hexColor.append(element)
		}// end foreach color element
		if alpha != 1.0 {
			let alphaLevel: UInt =  UInt(alpha * CGFloat(0xff))
			let element: String = String(alphaLevel, radix: 16)
			hexColor.append(element)
		}// end if color have alpha element

		return hexColor
	}// end rgbColorToHexColor

		// MARK: - Delegates
}// end class NicoLiveUser
