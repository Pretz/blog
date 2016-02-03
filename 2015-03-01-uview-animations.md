---
layout: post
title: Let's Build UIView.&#8203;animate&#8203;With&#8203;Duration in Swift
tags : [programming]
---

One of the features of Swift 1.2 I find most exciting is the addition of the `@noescape` [attribute for block parameters][appledoc]:[^login]

[^login]: Requires apple developer account login.
[appledoc]: https://developer.apple.com/devcenter/download.action?path=/Developer_Tools/Xcode_6.3_beta_2/Xcode_6.3_beta_2_Release_Notes.pdf

> A new “@noescape” attribute may be used on closure parameters to functions. This indicates that the parameter is only ever called (or passed as an @noescape parameter in a call), which means that it cannot outlive the lifetime of the call. This enables some minor performance optimizations, but more importantly disables the “self.” requirement in closure arguments.

One of the places where the `self.` block requirement most frequently bothers me is in calls to `UIView.animateWithDuration`:

~~~ swift
UIView.animateWithDuration(0.5, animations: {
    self.view1.frame.size.width += 200
    self.view2.frame.origin.x = self.view1.frame.maxX + 20
})
~~~

You can see in the debugger that the `animations` block passed to `animateWithDuration` is always executed synchronously, so it _should_ be compatible with `@noescape`, but I'm not holding my breath waiting for Apple to add it.

I decided that instead, I would take a look at what it would take to implement my own `animateWithDuration`, method, using default parameters instead of the [three method variations defined on `UIView`][uiview]), and making the `animations` block noescape. `completion` can't be noescape as it _is_ called asynchronously when the animation completes.

[uiview]: https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/#//apple_ref/doc/uid/TP40006816-CH3-SW108

## Target Function

Let's start with how I think my method definition should look:

```swift
public func animateViews(
    duration duration: NSTimeInterval,
    delay: NSTimeInterval = 0,
    options: UIViewAnimationOptions = .allZeros,
    @noescape animations: () -> Void,
    completion: (Bool -> Void)? = nil) {
```

A call to this looks a lot like the built-in methods, but the optional parameters allow some flexibility:

```swift
animateViews(duration: 1.2, delay: 0.2,
    animations: { view1.frame.origin.x += 50 },
    completion: { self.animationDidComplete($0) }
)
```

I'm going to build my version on top of the old-style UIView [`beginAnimations` and `commitAnimations`][oldstyle] class methods. These were the standard way to do UIView animations in the days before blocks. They provide almost the same functionality as the block-based methods but with more verbose syntax.

[oldstyle]: https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/#//apple_ref/occ/clm/UIView/beginAnimations:context:

The normal way they are used is like so:

```swift
UIView.beginAnimations(nil, context: nil)
UIView.setAnimationDuration(1.2)

view1.frame.origin.x += 50

UIView.commitAnimations()
```

Our goal is to write a method that calls the right set-up functions for the animation parameters, calls the `animations()` block, then commits the animations. Additionally, we will ensure the `completion` block gets called when the animation completes.

Let's ignore the completion block for now and focus on setting up the basic animation:

```swift
public func animateViews(
    duration duration: NSTimeInterval,
    delay: NSTimeInterval = 0,
    curve: UIViewAnimationCurve? = nil,
    @noescape animations: () -> Void {

    UIView.beginAnimations(nil, context: nil)

    UIView.setAnimationDuration(duration)
    UIView.setAnimationDelay(delay)
    if let curve = curve {
        UIView.setAnimationCurve(curve)
    }
    
    animations()
    
    UIView.commitAnimations()
}
```

I decided to only support animation curves rather than all of `UIViewAnimationOptions`. Most `UIViewAnimationOptions` can be implemented via UIView calls, but I find I very rarely use them.

## The Completion Block

The old animation methods only support delegates, as they predate blocks completely. Not just that, but they support delegates in a very weird way: rather than defining a protocol, you provide a reference to _any_ object, and then declare what selector on that object to call when the animation starts or ends. I need a small wrapper class to act as the delegate and call through to the provided completion block. I'll call it `AnimationDelegate`, and to begin with, I need a static `Set<AnimationDelegate>`, as the animation does not retain its delegate. I'll insert a delegate in the set when beginning an animation, and remove it when the animation completes and `completion` has been called:

```swift
private var delegates = Set<AnimationDelegate>()
```

```swift
final class AnimationDelegate: NSObject {
    let callback: Bool -> Void
    init(callback: Bool -> Void) {
        self.callback = callback
    }
```

then implement the standard signature for the animation completion delegate callback:

```swift
    func animationDidStop(
        animationId: String?, 
        finished: NSNumber, 
        context: UnsafeMutablePointer<Void>) {

        self.callback(finished.boolValue)
        delegates.remove(self)
    }
}
```

Finally, I need to instantiate an `AnimationDelegate` whenever a `completion` block is provided to `animateViews`, and add it to the delegates Set:

```swift
public func animateViews(
    duration duration: NSTimeInterval,
    delay: NSTimeInterval = 0,
    curve: UIViewAnimationCurve? = nil,
    @noescape animations: () -> Void,
    completion: (Bool -> Void)? = nil) {
        
        UIView.beginAnimations(nil, context: nil)
        
        if let completion = completion {
            let wrapper = AnimationDelegate(callback: completion)
            delegates.insert(wrapper)
            UIView.setAnimationDelegate(wrapper)
            UIView.setAnimationDidStopSelector("animationDidStop:finished:context:")
        }
        ...
```

I originally tried to use the `context` parameter to reference the block itself and avoid a wrapper class, but I couldn't figure out how to get an `UnsafeMutablePointer<Void>` from a Swift block, and wasn't sure I could trust the memory semantics with block copying even if I could.

So there you have it, UIView animation with default parameters and a `@noescape` animations block!

You can see the full example project [on github.](https://github.com/Pretz/NoEscapeAnimation/blob/master/NoEscapeAnimation/NoEscapeAnimation.swift)