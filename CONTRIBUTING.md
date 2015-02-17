# Contribution Guidelines

## General Guidelines

- **Min iOS SDK**: 7.0
- **Language**: Objective-C only.
- **Tests**: Yes, please

#### Architecture guidelines

- Avoid singletons that don't encapsulate a finite resource
- Never expose mutable state
- Designed to be called from the main thread (this is a UI library)
- Keep classes/methods sharply focused
- Stay generic

## Style Guide

#### Base style:

Please add new code to this project based on the following style guidelines:

- [Apple's Coding Guidelines for Cocoa](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html)
- [NYTimes Objective C Style Guidelines](https://github.com/NYTimes/objective-c-style-guide)

Among other things, these guidelines call for:

- Open braces on the same line; close braces on their own line
- Always using braces for 'if' statements, even with single-liners
- No spaces in method signatures except after the scope (-/+) and between parameter segments
- Use dot-notation, not setXXX, for properties (e.g. self.enabled = YES)
- Asterisk should touch variable name, not type (e.g. NSString *myString)
- Prefer static const declarations over #define for numeric and string constants
- Prefer private properties to ‘naked’ instance variables wherever possible
- Prefer CGGeometry methods to direct access of CGRect struct

#### Additions:

- Prefix all class names with YMPrompt
- Prefix all constants with kYM<Class>
- Group related methods with #pragma mark
- Keep as much of the API private as practical
