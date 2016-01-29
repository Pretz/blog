---
layout: post
title: Swift Asset Code Generators
tags: [programming, swift]
description: A comparison of code generators for Swift
---

Programmers generally agree that using ["stringly-typed"][string] data is a recipe for pain, but vanilla iOS development requires [a lot of exactly that][square]: image names, localized strings, storyboard and segue identifiers, etc. Following in the footsteps of great projects like [mogenerator][], now there's a healthy selection of libraries that provide type-safe and IDE-friendly references to assets.

[string]: http://c2.com/cgi/wiki?StringlyTyped
[square]: https://corner.squareup.com/2014/02/objc-codegenutils.html
[mogenerator]: https://rentzsch.github.io/mogenerator/

I tried out four popular projects which support Storyboards and Segues, plus these other features: [^shark]

[^shark]: I've left the popular [Shark][Shark] library off of this list because it _only_ handles images, which are also handled by most of these libraries.

| -- 
| Library | Type Safe(ish) | Images | Localized Strings | Colors | Reuse Identifiers | Fonts |
| ------------------- |:-: | :----: | :-----:| :---:|:-:|:-:|
| [SwiftGen]          | ✔  | ✔      | ✔      | ✔   | ❌| ❌|
| [Natalie]           | ✔  | ❌     | ❌     | ❌  | ✔ | ❌|
| [R.swift]           | ✔ | ✔      | ✔      | ❌  | ✔ | ✔ |
| [objc-codegenutils] | ❌ | ✔      | ❌     | ✔   | ❌| ❌|
| --
{: .table .table-condensed .table-striped}

[^seg]: and segues
[SwiftGen]: https://github.com/AliSoftware/SwiftGen
[Shark]: https://github.com/kaandedeoglu/Shark
[Natalie]: https://github.com/krzyzanowskim/Natalie
[R.swift]: https://github.com/mac-cain13/R.swift
[objc-codegenutils]: https://github.com/puls/objc-codegenutils

When I say type safe, I'm specifically referring to storyboard segues: since segues with identifiers are tied to a specific view controller, it's possible to ensure the segue references are associated with the storyboard or view controller they are part of and push runtime crashes to become compiler crashes. 

To test out these tools, I decided to convert the default Xcode Master-Detail Application template (plus a little extra) to use each of them and try it out.

I've put them all in to a [github project you can check out](https://github.com/Pretz/SwiftCodeGenUtils) if you want to [see the code in action](https://github.com/Pretz/SwiftCodeGenUtils/blob/master/CodeGenExample/MasterViewController.swift#L60-L83).

## The Normal Way

There are two main Storyboard actions where I often use string based identifiers: `performSegue` and `prepareForSegue`. Here's a typical example of presenting a view controller showing an image:

```swift
@IBAction func someButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier("ImageView", sender: self)
}
```

and

~~~ swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch segue.identifier {
    case "ImageView"?:
        if let dest = segue.destinationViewController as? ImageViewController {
            dest.imageToShow = UIImage(named: "lolwut")
        }
    default:
        break
    }
}
~~~

## SwiftGen

I started with SwiftGen, as it looked like it would have the best combination of features and type-safety I was looking for.

Here's `performSegue` using SwiftGen's generated identifier enum:

```swift
@IBAction func swiftGenButtonPressed(sender: AnyObject) {
    performSegue(StoryboardSegue.Main.ImageView)
}
```

The `Main` there is the name of the storyboard where the segue is defined.

and `prepareForSegue`:

```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch StoryboardSegue.Main(rawValue: segue.identifier!) {
    case .ImageView?:
        if let dest = segue.destinationViewController as? ImageViewController {
            // This is a SwiftGen image asset reference
            dest.imageToShow = UIImage(asset: .Lolwut)
        }
    default:
        break
    }
}
```


There are a few things to note here that stand out to me. First, I have to force unwrap `segue.identifier`, even though `Main(rawValue:)` returns an optional. A helper initializer could have avoided that slight wart.

The main thing bugging me is that `default:` entry in the switch statement. It turns out SwiftGen lumps all the segues in a storyboard in to one `enum`. Since there will usually be different segues on different view controllers in one storyboard, a `default:` case will pretty much always be needed, which loses a lot of the compile time help enums are supposed to provide.

## Natalie

```swift
@IBAction func natalieButtonPressed(sender: AnyObject) {
    performSegue(Segue.ImageView)
}
```

```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let segueType: Segue = segue.selection() else { return }
    switch segueType {
    case .ImageView:
        if let dest = segue.destinationViewController as? ImageViewController {
            dest.imageToShow = UIImage(named: "lolwut")
        }
    }
}
```

Now this is getting somewhere. `Segue` is an enum defined as an internal class on the current view controller, so _only segues this view controller supports are present_. That means if I change the class of the view controller in the storyboard, this code will _rightfully_ break. Also, Xcode's code completion only offers me segues defined on this view controller in the storyboard. No `default:` clause is needed on the switch for the same reason. There's a guard here because `segue.selection()` returns an optional, but that seems a small price to pay for the compiler knowing about the possible segues.

## R.swift

At first `R.swift` didn't look like it had as strong type support., but it has just about the same number of stars on github as `SwiftGen` and I liked using the `R` system when I did Android development.

```swift
@IBAction func rButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier(R.segue.detailViewController.imageView, sender: self)
}
```

Actually, this is pretty clever. Even though I could call this segue from any view controller, if I _move the segue in the storyboard_, the compiler will catch it. If I copy and paste this code to a different view controller class, though, it'll crash at runtime.

```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let segueInfo = R.segue.detailViewController.imageView(segue: segue) {
        // This is how R references image assets
        segueInfo.destinationViewController.imageToShow = R.image.lolwut()
    }
}
```

R.swift takes a different approach to `UIStoryboardSegue`: it generates structs instead of enums. `R.segue.detailViewController.imageView` is smartly returns an optional struct which if present contains correctly typed view controller references. This avoids that annoying cast in all the other examples!

R.swift gives an interesting tradeoff: while it doesn't provide compiler-checked enum cases, it gives other ways to improve interaction with the type system and avoid unsafe casts.

## objc-codegenutils

For completeness sake, I wanted to look at a popular non-Swift code generation library. Square's [objc-codegenutils] looked well supported, even though it hasn't been touched in two years.

```swift
@IBAction func codeGenUtilsButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier(MainStoryboardImageViewIdentifier, sender: self)
}
```

```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch segue.identifier {
    case MainStoryboardImageViewIdentifier?:
        if let dest = segue.destinationViewController as? ImageViewController {
            dest.imageToShow = AssetsCatalog.lolwutImage()
        }
    default:
        break
    }
}
```

OK, it really doesn't give you that much. If you look at [the files it generates](https://github.com/Pretz/SwiftCodeGenUtils/blob/master/CodeGenExample/MainStoryboardIdentifiers.m) you can see how minimal it is. This is probably barely OK for an obj-c project, but in Swift I want something better.

## Which which which?

Honestly, I want a hybrid of `Natalie` and `R.swift`: I love the `Segue` inner enum Natalie uses to avoid repetitive boilerplate, but I really like the `TypedStoryboardSegueInfo` struct that `R.swift` constructs from a `UIStoryboardSegue`. It's also worth pointing out that all the libraries except `Natalie` allow you to choose which types of assets you want to generate code for, so it's perfectly reasonable to use a combination of libraries for different asset types.

I think for now I'm going to give Natalie a shot on a few projects and see how it goes. If I really miss the typed segue features of `R`, maybe I'll submit a pull request.