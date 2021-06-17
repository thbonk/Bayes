//
//  EventSpace.swift
//  Bayes
//
//  Created by Fabian Canas on 5/9/15.
//  Copyright (c) 2015 Fabian Canas. All rights reserved.
//

import Foundation

public struct EventSpace <C: Hashable & Codable, F: Hashable & Codable>: Codable {

  public typealias Category = C
  public typealias Feature = F

  public init() {}

  // MARK: - Codable

  enum CodingKeys: String, CodingKey {
    case categories      = "categories"
    case features        = "features"
    case featureCategory = "featureCategory"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    _categories = try container.decode(Bag.self, forKey: .categories)
    _features = try container.decode(Bag.self, forKey: .features)
    featureCategory = try container.decode(Bag<HashableTuple<C,F>>.self, forKey: .featureCategory)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(_categories, forKey: .categories)
    try container.encode(_features, forKey: .features)
    try container.encode(featureCategory, forKey: .featureCategory)
  }

  internal var categories :[Category] {
    get {
      return _categories.members
    }
  }

  fileprivate var _categories :Bag<C> = Bag<C>()
  fileprivate var _features :Bag<F> = Bag<F>()
  fileprivate var featureCategory :Bag<HashableTuple<C,F>> = Bag<HashableTuple<C,F>>()

  /// Add an observed event in a category with associated features to the
  /// event space.
  ///
  /// - Parameters:
  ///   - category: The category of the event to add to the event space
  ///   - features: A sequence of features observed with the event
  public mutating func observe <S: Sequence> (_ category: Category, features: S) where S.Iterator.Element == Feature {
    _categories.append(category)
    _features.append(features)
    featureCategory.append(features.map {
      HashableTuple(category,$0)
    })
  }

  /// The probability of observing the feature and category together
  /// P( feature, category)
  ///
  /// - Parameters:
  ///   - feature: feature
  ///   - category: category
  /// - Returns: The joint probability of feature and category
  public func P(_ feature: Feature, andCategory category: Category) -> Double {
    return Double(featureCategory.count(HashableTuple(category, feature))) / Double(_categories.count)
  }

  /// The probability of observing a feature given a category.
  /// P( feature | category )
  ///
  /// - Parameters:
  ///   - feature: feature
  ///   - category: category
  /// - Returns: The conditional probability of the feature given the category
  public func P(_ feature: Feature, givenCategory category: Category) -> Double {
    return P(feature, andCategory: category)/P(category)
  }

  /// Probability of observing a category
  /// P( category )
  ///
  /// - Parameter category: category
  /// - Returns: The base rate of the category
  public func P(_ category: Category) -> Double {
    return _categories.P(category)
  }
}
