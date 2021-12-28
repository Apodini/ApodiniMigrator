// COPYRIGHT NOTICE TODO

import _PB_GENERATED


@dynamicMemberLookup
public struct GreeterMessage: SwiftProtobufWrapper {
  public var __wrapped: _PB_GENERATED.GreeterMessage

  public init() {
    __wrapped = .init()
  }
}


@dynamicMemberLookup
public struct GreetingMessage: SwiftProtobufWrapper {
  public var __wrapped: _PB_GENERATED.GreetingMessage

  public init() {
    __wrapped = .init()
  }

  var greet: String {
    __wrapped.greet2
  }
}
