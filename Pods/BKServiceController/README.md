# BKServiceController

A concurrent dependency-resolving code launcher intended for use at application startup. Currently beta quality.

## Installation

1. Add BKServiceController to your Podfile.
2. In your terminal, run `pod install`.

## Usage

1. Add `#import <BKServiceController/BKServiceController.h>` and `#import <BKServiceController/BKServiceRegistrar.h>` to your application delegate class. Add `#import <BKServiceController/BKService.h>` as needed in implementing classes.
2. Write your services to conform to `BKService`: implement the `loadServiceWithCallback:` method, and use the supplied `service_load_callback_t` callback to notify the service controller of your service's successful (or failed) loading. This method is (currently) callable from arbitrary queues.
3. Add calls to the service controller (documented below), typically in `application:willFinishLaunchingWithOptions:` or `application:didFinishLaunchingWithOptions:`, to your application delegate.

## FAQ

**Q:** Why should I use this?  
**A:** A couple of reasons:

* The faster you can start up, the more your users will like your app. Even better, avoid the main thread when doing so.
* Utilizing iOS devices' cores to the maximum extent possible in the shortest period of time is A Good Thing™ for power savings, since it can ramp down the CPU earlier. Even if there's slightly more total work, if the time to quiescence is faster, the hardware can potentially drop to a low-power state sooner, for less overall consumption.
* Rather than a gargantuan app delegate that has to change a lot every time you want to add something new at startup, you can keep stuff neatly organized.
* Simple dependency management for launching services, so you only ever start service C if service A and service B are available. **Services are uniquely identified by the key they are registered with.**

**Q:** Why register with some `BKServiceRegistrar` object?  
**A:** This forces the addition of multiple potentially interdependent services to be done atomically, allowing dependency resolution to happen immediately after the registration block executes. IMO, it makes for a simpler, more predictable, and more debuggable API.

**Q:** `registerServicesImmediately:forKey:` doesn't work right with dependencies!  
**A:** Right now, it's a straight-up sequential start. Resolving them into a linearized DAG is possible, but has not yet been done.

**Q:** Why does `BKServiceController` load services in waves, rather than as each node in the tree satisfying a service's dependency completes?  
**A:** At the time it was being written, it wasn't clear that an atomic, tree-based registration mechanism that dispatched out to background queues was going to work out. After a small amount of usage, it's proven to be pretty useful! The design doesn't prevent this; and it would definitely be an improvement.

## Documentation

This project is a work in progress; the interface may not remain totally stable (though it's unlikely to change very much at all). Documentation will come after some more iteration.