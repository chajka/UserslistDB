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

	public init (user: JSONizableUser, known: Bool, identifier: String, nickname: String, premium: Int, anonymous: Bool, lang: UserLanguage) {
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
		if known {
			if let knownUser: Bool = entry.known { friendship = knownUser ? Friendship.known : Friendship.met }
			else { friendship = Friendship.metOther }
		} else {
			friendship = Friendship.new
		}// end if known or new user
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
		let capableLength: Set = Set(arrayLiteral: RGBColorCount, RGBAColorCount)
		if capableLength.contains(colorString.count) && String(colorString.prefix(1)) == "#" {
			var red: CGFloat = 0
			var green: CGFloat = 0
			var blue: CGFloat = 0
			var alpha: CGFloat = 1.0
			if let range: Range = Range(NSRange(location: OffsetRed, length: ColorDigit), in: colorString) {
				if let hexRed: Int = Int(String(colorString[range]), radix: Radix) { red = CGFloat(hexRed) / MaxValue }
			}// end optional binding for red color hex vallue
			if let range: Range = Range(NSRange(location: OffsetGreen, length: ColorDigit), in: colorString) {
				if let hexGreen: Int = Int(String(colorString[range]), radix: Radix) { green = CGFloat(hexGreen) / MaxValue }
			}// end optional binding for green color hex vallue
			if let range: Range = Range(NSRange(location: OffsetBlue, length: ColorDigit), in: colorString) {
				if let hexBlue: Int = Int(String(colorString[range]), radix: Radix) { blue = CGFloat(hexBlue) / MaxValue }
			}// end optional binding for blue color hex vallue
			if let range: Range = Range(NSRange(location: OffsetAlpha, length: ColorDigit), in: colorString) {
				if let hexAlpha: Int = Int(String(colorString[range]), radix: Radix) { alpha = CGFloat(hexAlpha) / MaxValue }
			}// end optional binding for alpha blending hex vallue

			return NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
		}// end if string maybe hex color

		return NSColor.clear
	}// end hexcClorToColor

	private func rgbColorToHexColor (rgbColor color: NSColor) -> String {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		var colorString = "#"
		let padding: String = String(repeating: PaddingCharacter, count: ColorDigit)
		colorString += String((padding + String(Int(red * MaxValue), radix: Radix)).suffix(ColorDigit))
		colorString += String((padding + String(Int(green * MaxValue), radix: Radix)).suffix(ColorDigit))
		colorString += String((padding + String(Int(blue * MaxValue), radix: Radix)).suffix(ColorDigit))
		if alpha != 1.0 { colorString += String((padding + String(Int(alpha * MaxValue), radix: Radix)).suffix(ColorDigit)) }

		return colorString
	}// end rgbColorToHexColor

		// MARK: - Delegates
}// end class NicoLiveUser
