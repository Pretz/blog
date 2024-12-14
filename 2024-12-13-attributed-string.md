---
layout: post
title: Custom Attributes in Swift AttributedString and NSAttributedString
tags: [programming, swift, ios]
description: How to define custom attributes for attributed strings and preserve them when converting between attributed string types.
---

In a reasonably sized iOS app, it can often be convenient to add custom attributes to [NSAttributedStrings](https://developer.apple.com/documentation/foundation/nsattributedstring) to pass additional metadata for whatever reason associated with a specific part of a string. ([Previously in my AttributedString adventures](https://mastodon.social/@pretz/110387345531733187))

This is straightforward with NSAttributedString since its attributes are a dictionary that can hold anything (I'm ignoring serialization here). You add your own key to NSAttributedString.Key, and go:

```swift
extension NSAttributedString.Key {
    static let userID = NSAttributedString.Key("UserID")
}

let nsAttributedString = NSAttributedString(
    string: "Good morning!",
    attributes: [.userID: "12345",
                 .foregroundColor: UIColor.orange,
                 .link: "https://mastodon.social"])
print(nsAttributedString)
/* Prints
Good morning!{
    NSColor = "UIExtendedSRGBColorSpace 1 0.5 0 1";
    NSLink = "https://mastodon.social";
    UserID = 12345;
}
*/
```

However, if you need to convert this to the newer Swift-native [AttributedString](https://developer.apple.com/documentation/foundation/attributedstring) struct for whatever reason (hint: AttributedString is Sendable!), your custom attributes will get lost.

```swift
let swiftAttributedString = AttributedString(nsAttributedString)
print(swiftAttributedString)
/* Prints
Good morning! {
    NSLink = https://mastodon.social
    NSColor = UIExtendedSRGBColorSpace 1 0.5 0 1
}
*/
```

There is a way to add custom attributes to Swift's AttributedString, and credit to [@toomasvahter](https://mastodon.social/@toomasvahter) for [one of the few posts I found that goes in to detail on doing this](https://augmentedcode.io/2021/06/21/exploring-attributedstring-and-custom-attributes/).

The equivalent to my original example for Swift AttributedString is ... this.
It's pretty verbose, but it's actually really clever. AttributedString uses a Swift feature called [dynamic member lookup](https://www.hackingwithswift.com/articles/55/how-to-use-dynamic-member-lookup-in-swift) to let developers extend its own API by adding new "properties" to it. Notice also how the new properties are strongly typed: the value for `link` has to be a URL now, when previously I incorrectly used a String:

```swift
enum UserIDAttribute: AttributedStringKey {
    typealias Value = String
    static let name = "UserID"
}

extension AttributeScopes {
    public struct MyAttributedStringAttributes: AttributeScope {
        let userID: UserIDAttribute
    }
    
    var myAttributes: MyAttributedStringAttributes.Type { MyAttributedStringAttributes.self }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.MyAttributedStringAttributes, T>) -> T {
        self[T.self]
    }
}

var myAttributedString = AttributedString("Good morning Swift!")
myAttributedString.userID = "12345"
myAttributedString.link = URL(string: "https://mastodon.social")
print(myAttributedString)
/* Prints
Good morning Swift! {
    UserID = 12345
    NSLink = https://mastodon.social
}
*/
```

Unfortunately, even after all this work, converting between `NSAttributedString` and `AttributedString` will lose the custom attribute moving in either direction:

```swift
var myAttributedString = AttributedString("Good morning Swift!")
myAttributedString.userID = "12345"
myAttributedString.link = URL(string: "https://mastodon.social")
let newNSAttributedString = NSAttributedString(myAttributedString)
print(newNSAttributedString)
/* Prints
 Good morning Swift!{
    NSLink = "https://mastodon.social";
 }
*/

let nsAttributedString = NSAttributedString(
    string: "Good morning!",
    attributes: [.userID: "12345",
                 .link: URL(string: "https://mastodon.social")])
let newSwiftAttributedString = AttributedString(nsAttributedString)
print(newSwiftAttributedString)
/* Prints
 Good morning! {
    NSLink = https://mastodon.social
 }
*/
```

Here's the key. Look closely at the [AttributedString(_: NSAttributedString) initializer documentation:](https://developer.apple.com/documentation/foundation/attributedstring/3856542-init)

> This initializer includes all attribute scopes defined by the SDK, such as `AttributeScopes.FoundationAttributes`, `AttributeScopes.SwiftUIAttributes`, and `AttributeScopes.AccessibilityAttributes`. To use third-party attribute scopes, use the initializers `init(_:including:)` or `init(_:including:)`.

Ahh, I have to pass my attribute scope explicitly!!

Let's try it:

```swift
let nsAttributedString = NSAttributedString(
    string: "Good morning!",
    attributes: [.userID: "12345",
                 .link: URL(string: "https://mastodon.social")])
let newSwiftAttributedString = try AttributedString(nsAttributedString,
                                                    including: \.myAttributes)
print(newSwiftAttributedString)
/* Prints
 Good morning! {
    UserID = 12345
 }
*/
```

Well shit. What happened to my `link` attribute?
Well, it's not part of the scope I passed. The only thing in my scope is "userID".

[Back to the documentation:](https://developer.apple.com/documentation/foundation/attributedstring/3787693-init)

> **scope**<br>
A key path that identifies the attribute scope of the attributes in nsStr. This can be a nested scope that contains several scopes.

What is a nested scope? What does that mean?
Finally I track down [some notes from WWDC 2021](https://mackuba.eu/notes/wwdc21/whats-new-in-foundation/), thanks [@mackuba](https://mastodon.social/@mackuba@martianbase.net)! 

> However, attribute scopes can be nested in one another, so you can include e.g. a scope of all SwiftUI attributes inside your scope (which in turn includes Foundation attributes)

OK, looking at the example, I literally just include the existing Foundation or UIKit attribute scopes in my own. This seems super weird, but fine.

```swift
extension AttributeScopes {
    public struct MyAttributedStringAttributes: AttributeScope {
        let userID: UserIDAttribute
        let uiKit: UIKitAttributes
        let foundation: FoundationAttributes
    }
    
    var myAttributes: MyAttributedStringAttributes.Type { MyAttributedStringAttributes.self }
}
```

```swift
let nsAttributedString = NSAttributedString(
    string: "Good morning NextStep!",
    attributes: [.userID: "12345",
                 .link: URL(string: "https://mastodon.social")!])
let newSwiftAttributedString = try AttributedString(nsAttributedString,
                                                    including: \.myAttributes)
print(newSwiftAttributedString)
/* Prints
 Good morning NextStep! {
    NSLink = https://mastodon.social
    UserID = 12345
 }
*/
let nsAttributedString2 = try NSAttributedString(newSwiftAttributedString,
                                                 including: \.myAttributes)
nsAttributedString2 == nsAttributedString // True!
print(nsAttributedString2)
/* Prints
 Good morning NextStep!{
    NSLink = "https://mastodon.social";
    UserID = 12345;
 }
*/
```

It works! My custom key AND the existing `link` key transfer in both directions, and the attributed strings come out equal after the conversion.

This was originally [posted as a thread on Mastodon](https://mastodon.social/@pretz/113644018734976838), please chime in if you have any feedback!
