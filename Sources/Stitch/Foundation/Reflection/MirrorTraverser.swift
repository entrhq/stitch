//
//  MirrorTraverser.swift
//  Stitch
//
//  Created by Justin Wilkin on 20/1/2025.
//

struct MirrorTraverser {
    var mirror: Mirror
    var mirrorValue: Any? = nil
    
    func traverse(by label: String) -> MirrorTraverser? {
        guard let child = mirror.children.first(where: { $0.label == label }) else {
            return nil
        }
        return MirrorTraverser(mirror: Mirror(reflecting: child.value), mirrorValue: child.value)
    }
    
    func value<T>() -> T? {
        return mirrorValue as? T
    }
}

extension Optional where Wrapped == MirrorTraverser {
    func traverse(by label: String) -> Wrapped? {
        self?.traverse(by: label)
    }
    
    func value<T>() -> T? {
        self?.value()
    }
}
