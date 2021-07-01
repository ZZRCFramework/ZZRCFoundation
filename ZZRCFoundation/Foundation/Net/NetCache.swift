//
//  DYNetCache.swift
//  Dayang
//
//  Created by 田向阳 on 2018/1/3.
//  Copyright © 2018年 田向阳. All rights reserved.
//

import UIKit

struct  NetCache {
    
    public static func store(request: NetTargetType, data: Data) {
        CacheTool.shared.store(obj: data, key: getCacheKey(request: request))
    }
    
    public static func getCache(request: NetTargetType, complete: DataRequestCompleteClosure?) {
        CacheTool.shared.getObject(key: getCacheKey(request: request)) { (data) -> (Void) in
            guard let data = data, let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] else {
                return
            }
            let error = NetError.throwError(code: ErrorCode.cache.rawValue, message: "")
            safeAsync {
                complete?(error,data,dict)
            }
        }
    }
    
    fileprivate static func getCacheKey(request: NetTargetType) -> String {
        let sortParams = request.params.sorted { (obj1,obj2) in
            return obj1.key < obj2.key
        }
        return "method:\(request.method.rawValue) url:\(request.baseURL.absoluteString + request.path) Argument:\(sortParams)".md5()
    }
}

let autoDeleteTime = 60 * 60 * 24 * 7; // 1 week
let defaultMemorySize = 10 * 1024 * 1024; //100M

enum CacheType {
    case `default`
    case onlyMemory
    case onlyDisk
}

class CacheTool {
    public static let shared = CacheTool()
    init() {
        let path = cachePathDirectory()
        if !SandboxFilePath.fileExists(at: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
        addNotification()
    }
    
    lazy var memoryCache: NSCache<AnyObject,AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = maxMemorySize
        cache.countLimit = maxMemoryCount
        return cache
    }()
    
    var maxMemorySize: Int = defaultMemorySize { // 内存的缓存空间大小
        didSet{
            memoryCache.totalCostLimit = maxMemorySize
        }
    }
    var maxMemoryCount: Int = 100 { //内存缓存最大数量
        didSet{
            memoryCache.countLimit = maxMemoryCount
        }
    }
    
    var maxDiskCacheSize: Int = 50 * 1024 * 1024 //硬盘最大存储空间

    lazy var ioQueue: DispatchQueue = {
        let queue = DispatchQueue.init(label: "cache.ioQueue")
        return queue
    }()
    
    fileprivate func cachePathDirectory() -> String {
        return SandboxFilePath.directoryPath(type: .APPCache)
    }
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] notify in
            guard let self = self else{ return }
            self.appDidEndterBackground()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { [weak self] notify in
            guard let self = self else{ return }
            self.clearMemory()
        }
    }
}

extension CacheTool {
    
    /// 缓存data
    ///
    /// - Parameters:
    ///   - obj: 对象
    ///   - key: key
    public func store(obj: Data,key: String, cacheType: CacheType = .default) {
        if cacheType == .default || cacheType == .onlyMemory {
            memoryCache.setObject(obj as AnyObject, forKey: key as AnyObject, cost: obj.count)
        }
        
        if cacheType == .default || cacheType == .onlyDisk {
            // 缓存到硬盘
            ioQueue.async {
                let path = self.getCachePath(key: key)
                FileManager.default.createFile(atPath: path, contents: obj, attributes: nil)
            }
        }
    }
    
    public func getObject(key: String, complete: ((_ data: Data?)->(Void))?) {
        if let data = self.memoryCache.object(forKey: key as AnyObject) {
            safeAsync {
                complete?(data as? Data)
            }
        }else{
            ioQueue.async {
                let path = self.getCachePath(key: key)
                if SandboxFilePath.fileExists(at: path) {
                    let data = try? Data(contentsOf: URL(fileURLWithPath: path))
                    safeAsync {
                        complete?(data)
                    }
                }else{
                    safeAsync {
                        complete?(nil)
                    }
                }
            }
        }
    }
    
    public func remove(key: String) {
        memoryCache.removeObject(forKey: key as AnyObject)
        ioQueue.async {
            let path = self.getCachePath(key: key)
            SandboxFilePath.removeFile(at: path)
        }
    }
    
    public func clearMemory(){
        memoryCache.removeAllObjects()
    }
    
    public func clearDisk() {
        ioQueue.async {
            SandboxFilePath.removeFile(at: self.cachePathDirectory())
        }
    }
    
    public func appDidEndterBackground() {
        checkIsNeedToClearDisk {}
    }
    
    public func checkIsNeedToClearDisk(_ complete: (() -> (Void))?) {
        self.ioQueue.async {
            let cacheURL = self.cachePathDirectory()
            let resourceKeys = [URLResourceKey.isDirectoryKey,URLResourceKey.contentModificationDateKey,URLResourceKey.totalFileAllocatedSizeKey]
            if let fileEnumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: cacheURL), includingPropertiesForKeys: resourceKeys){
                let expireDate = Date(timeIntervalSinceNow: TimeInterval(-autoDeleteTime))
                let cacheFiles = NSMutableDictionary()
                var cacheCurrentSize = 0
                var urlsToDel = [URL]()
                for url in fileEnumerator {
                    guard let url = url as? URL, let att = try? url.resourceValues(forKeys: Set(resourceKeys)) else {return}
                    if att.isDirectory ?? false{
                        continue
                    }
                    let fileDate = (att.contentModificationDate ?? Date()) as NSDate
                    let compareDate = fileDate.laterDate(expireDate) as NSDate
                    if compareDate.isEqual(to: expireDate) {
                        urlsToDel.append(url)
                        continue
                    }
                    let fileSize = att.totalFileAllocatedSize ?? 0
                    cacheCurrentSize += fileSize
                    cacheFiles.setObject(att, forKey: (url.path as NSString))
                }
                for url in urlsToDel {
                    SandboxFilePath.removeFile(at: url.path)
                }
                if self.maxDiskCacheSize > 0 && cacheCurrentSize > self.maxDiskCacheSize {
                   let desiredCacheSize = self.maxDiskCacheSize / 2
                    let sortFiles: [String] = cacheFiles.keysSortedByValue(options: NSSortOptions.concurrent, usingComparator: { (obj1, obj2) -> ComparisonResult in
                        if let obj1 = obj1 as? URLResourceValues,
                           let obj2 = obj2 as? URLResourceValues,
                           let date1 = obj1.contentModificationDate,
                           let date2 = obj2.contentModificationDate,
                           let result = ComparisonResult(rawValue: date1.compare(date2).rawValue){
                            return result
                        }
                        return .orderedDescending
                    }) as? [String] ?? [String]()
                    for url in sortFiles {
                        let att = cacheFiles[url] as? URLResourceValues
                        let size = att?.totalFileAllocatedSize ?? 0
                        SandboxFilePath.removeFile(at: url)
                        cacheCurrentSize -= size
                        if cacheCurrentSize < desiredCacheSize {
                            break
                        }
                    }
                }
            }
            safeAsync({
                complete?()
            })
        }
    }
    
    //获取Cache 缓存大小
    public func getLocalCacheSize() -> Int64 {
        return getPathSize(cachePathDirectory())
    }
    

    
    /// 获取网络加载图片的缓存
    ///
    /// - Returns: size
    public func getImageCacheSize() -> Int64 {
        return 0
    }
    
    
    /// 获取指定目录下文件大小
    ///
    /// - Parameter path: 路径
    /// - Returns: 文件大小
    public func getPathSize(_ path: String) -> Int64{
        var size = 0
        self.ioQueue.sync {
            if let enumerator = FileManager.default.enumerator(atPath: path) {
                for fileName in enumerator {
                    let aPath = path + "/\(fileName)"
                    do {
                        let att = try FileManager.default.attributesOfItem(atPath: aPath)
                        size += att[FileAttributeKey.size] as! Int
                    } catch _ {}
                }
            }
        }
        return Int64(size)
    }
    
    fileprivate func getCachePath(key: String) -> String {
        return self.cachePathDirectory() + "/\(key)"
    }
}
