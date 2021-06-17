//
//  HashableTuple.swift
//  Bayes
//
//  Created by Fabian Canas on 5/9/15.
//  Copyright (c) 2015 Fabian Canas. All rights reserved.
//

/** 
 A (Hashable, Hashable) isn't Hashable. But representing conditional
 probabilities in a Set or Dictionary is easier if they are.
 */
internal struct HashableTuple<A : Hashable & Codable, B : Hashable& Codable> : Hashable, Codable {
  let a :A
  let b :B

  init(_ a: A, _ b: B) {
    self.a = a
    self.b = b
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(a)
    hasher.combine(b)
  }

  // MARK: - Codable

  enum CodingKeys: String, CodingKey {
    case a = "a"
    case b = "b"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    a = try container.decode(A.self, forKey: .a)
    b = try container.decode(B.self, forKey: .b)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(a, forKey: .a)
    try container.encode(b, forKey: .b)
  }
}

internal func == <A, B> (lhs: HashableTuple<A,B>, rhs: HashableTuple<A,B>) -> Bool {
  return lhs.a == rhs.a && lhs.b == rhs.b
}
