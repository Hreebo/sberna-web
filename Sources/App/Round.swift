//
//  Round.swift
//  App
//
//  Created by Lukas Hrebik on 13/12/2018.
//

import Async
import Leaf

public final class RoundNumberTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let number = tag.parameters[0].double
        let str = String(format: "%.6f", number!)
        return tag.container.future(.string(str))
    }
}
