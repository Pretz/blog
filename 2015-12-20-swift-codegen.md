---
layout: post
title: Swift Asset Code Generators
tags: [programming, swift]
description: A comparison of code generators for Swift
---

Programmers generally agree that using ["stringly-typed"][string] data is a recipe for pain, but vanilla iOS development requires [a lot of exactly that][square]: image names, localized strings, storyboard and segue identifiers, etc. Following in the footsteps of great projects like [mogenerator][], there's a healthy variety of libraries that provide type-safe and IDE-friendly references to different assets.

[string]: http://c2.com/cgi/wiki?StringlyTyped
[square]: https://corner.squareup.com/2014/02/objc-codegenutils.html
[mogenerator]: https://rentzsch.github.io/mogenerator/

So far I've found four[^shark] popular projects, all of which support Storyboards and Segues, with these additional features:

[^shark]: I've left the popular [Shark][Shark] library off of this list because it _only_ handles images, which are also handled by most of these libraries.

| -- 
| Library | Type Safe(ish) | Images | Localized Strings | Colors | Reuse Identifiers | Fonts |
| ------------------- |:-: | :----: | :-----:| :---:|:-:|:-:|
| [SwiftGen]          | ✔  | ✔      | ✔      | ✔   | ❌| ❌|
| [R.swift]           | ❌ | ✔      | ✔      | ❌  | ✔ | ✔ |
| [Natalie]           | ✔️  | ❌     | ❌     | ❌  | ✔ | ❌|
| [objc-codegenutils] | ❌ | ✔      | ❌     | ✔   | ❌| ❌|
| --
{: .table .table-condensed .table-striped}

[^seg]: and segues
[SwiftGen]: https://github.com/AliSoftware/SwiftGen
[Shark]: https://github.com/kaandedeoglu/Shark
[Natalie]: https://github.com/krzyzanowskim/Natalie
[R.swift]: https://github.com/mac-cain13/R.swift
[objc-codegenutils]: https://github.com/puls/objc-codegenutils

When I say type safe, I'm specifically referring to storyboard segues: since segues with identifiers are tied to a specific view controller, `SwiftGen` and `Natalie` ensure the segue references are attached to the view controller class they are part of, reducing (but not eliminating) the chance of using the wrong segue in a given view controller. `R.swift` and `objc-codegenutils` just generate constant strings that can be used as storyboard/segue identifiers.

To test out these tools, I decided to convert the default Xcode Master-Detail Application template to use each of them.

## SwiftGen

I started with SwiftGen, as it looked like it had the best combination of features and type-safety I'm looking for.


