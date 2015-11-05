---
layout: post
title: Type-Safe Mock Models in Swift
tags: [programming]
description: A technique for simplifying creation of model objects from mock data in Swift.
---

I've been writing API-based iOS apps since 2009. From [users][github-api] to [restaurants][yelp-api] to [car reservations][silvercar], API data models are what drive UI in these applications. Frequently when writing tests for an application, it's necessary to construct a sample data model to test the way the application behaves for that model.

[github-api]: https://developer.github.com/v3/users/#get-a-single-user
[yelp-api]: https://www.yelp.com/developers/documentation/v2/business
[silvercar]: https://www.silvercar.com/#/

Projects like [Mantle][mantle] and [Argo][argo] make it easy to construct model objects from the JSON data returned by most common APIs. 

[argo]: https://github.com/thoughtbot/Argo
[mantle]: https://github.com/Mantle/Mantle