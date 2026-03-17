//
//  LayoutEngine.swift
//  BanglaType
//
//  Protocol for layout engines (phonetic, fixed). Data-driven .avrolayout.
//

import AppKit

enum LayoutOutput {
    case commit(String)
    case compose(String)
    case passthrough
    case consumed
}

protocol LayoutEngineProtocol: AnyObject {
    func process(key: String, modifiers: NSEvent.ModifierFlags) -> LayoutOutput
}

/// Does nothing; use when input should pass through to the client.
final class PassthroughLayoutEngine: LayoutEngineProtocol {
    func process(key: String, modifiers: NSEvent.ModifierFlags) -> LayoutOutput {
        .passthrough
    }
}
