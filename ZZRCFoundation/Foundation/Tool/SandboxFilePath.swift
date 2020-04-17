//
//  LocalFilePathServer.swift
//  UMICHAT
//
//  Created by 田向阳 on 2019/8/13.
//  Copyright © 2019 田向阳. All rights reserved.
//

import UIKit

public enum SandBoxDirectoryType: String {
    //系统层级 目录
    case Documents = "Documents"
    case Library = "Library"
    case Caches = "Caches"
    case Tmp = "tmp"
    //用户自定义层级目录
    case APPCache = "APPCache"
    case CommonImage = "CommonImage"
    
}

public struct SandboxFilePath {

    public static func sandBoxPath() -> String {
        return NSHomeDirectory()
    }
    
    public static func directoryPath(type: SandBoxDirectoryType) -> String {
        switch type {
        case .Documents,.Library,.Tmp:
            return sandBoxPath() + "/\(type.rawValue)"
        case .Caches:
            return self.directoryPath(type: .Library) + "/\(type.rawValue)"
        case .APPCache:
            let path = self.directoryPath(type: .Caches) + "/\(type.rawValue)"
            _ = createDirectory(at: path)
            return path
        case .CommonImage:
            let path = self.directoryPath(type: .APPCache) + "/\(type.rawValue)"
            _ = createDirectory(at: path)
            return path
        }
    }
    
    public static func cachePath() -> String {
        let cachePath = directoryPath(type: .APPCache)
        if createDirectory(at: cachePath) {
            return cachePath
        }
        return directoryPath(type: .Caches)
    }
    
    //MARK: FileManager
    public static func fileExists(at path: String) -> Bool{
       return FileManager.default.fileExists(atPath: path)
    }
    
    public static func removeFile(at path: String) {
        if !fileExists(at: path) {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            Print("文件删除失败:\(error.localizedDescription)")
        }
    }
    
    public static func move(from: String, to: String) {
        if !fileExists(at: from) {
            return
        }
        do {
            SandboxFilePath.removeFile(at: to)
            try FileManager.default.moveItem(atPath: from, toPath: to)
        } catch {
            
        }
    }
    
    public static func copy(from: String, to: String) {
        if !fileExists(at: from) {
            return
        }
        do {
            SandboxFilePath.removeFile(at: to)
            try FileManager.default.copyItem(atPath: from, toPath: to)
        } catch {

        }
    }
    
    public static func createDirectory(at path: String) -> Bool {
        if fileExists(at: path) {
            return true
        }
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            Print("创建文件夹失败:\(error.localizedDescription)")
            return false
        }
    }
    
    /// 清除所有缓存
    public static func clearAllCache(){
        SandboxFilePath.removeFile(at: directoryPath(type: .APPCache))
    }
}

public extension String {
    
    func documentPath() -> String {
        return SandboxFilePath.directoryPath(type: .Documents) + "/\(self)"
    }
    
    func cachePath() -> String {
        return SandboxFilePath.directoryPath(type: .Caches) + "/\(self)"
    }
}
