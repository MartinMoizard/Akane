//
// This file is part of Akane
//
// Created by JC on 20/10/15.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

import Foundation

public protocol Converter {
    typealias ValueType
    typealias ConvertValueType

    init()

    func convert(value: ValueType) -> ConvertValueType
}
