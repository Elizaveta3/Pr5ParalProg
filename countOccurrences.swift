import Foundation

// Функція для підрахунку кількості входжень строки в файл
func countOccurrences(of searchString: String, inFile filePath: String) -> Int {
    guard let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        return 0
    }
    return fileContents.components(separatedBy: searchString).count - 1
}

// Функція для рекурсивного знаходження всіх файлів у директорії
func getAllFiles(in directory: URL) -> [URL] {
    let fileManager = FileManager.default
    guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) else {
        return []
    }

    var files: [URL] = []
    for case let fileURL as URL in enumerator {
        if fileURL.hasDirectoryPath == false {
            files.append(fileURL)
        }
    }
    return files
}

// Головна функція для підрахунку входжень строки в усіх файлах директорії
func countOccurrencesInDirectory(searchString: String, directory: URL) {
    guard searchString.count >= 3 && searchString.count <= 5 else {
        print("Search string must be between 3 and 5 characters long.")
        return
    }

    let files = getAllFiles(in: directory)
    
    let dispatchGroup = DispatchGroup()
    let queue = DispatchQueue.global(qos: .userInitiated)
    var totalOccurrences = 0
    let lock = NSLock()

    for file in files {
        dispatchGroup.enter()
        queue.async {
            let count = countOccurrences(of: searchString, inFile: file.path)
            if count > 0 {
                print("Occurrences in \(file.lastPathComponent): \(count)")
                lock.lock()
                totalOccurrences += count
                lock.unlock()
            }
            dispatchGroup.leave()
        }
    }

    dispatchGroup.notify(queue: .main) {
        if totalOccurrences > 0 {
            print("Total occurrences of \"\(searchString)\": \(totalOccurrences)")
        } else {
            print("No occurrences found.")
        }
        CFRunLoopStop(CFRunLoopGetMain())
    }
}

let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
countOccurrencesInDirectory(searchString: "label", directory: currentDirectory)

RunLoop.main.run()

