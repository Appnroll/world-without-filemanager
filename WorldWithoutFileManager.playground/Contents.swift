//: Playground - noun: a place where people can play

import Darwin

let username = "appnroll"
let path = "/Users/\(username)/Documents/Shared Playground Data/file.txt"

func printError() {
    let errorCode = errno
    let errorMessage = strerror(errorCode)!
    let error = String(cString: errorMessage)
    print("Error code \(errorCode): \(error)")
}

func printContent(atPath path: String) {
    var fileStatus = stat()
    let result = stat(path, &fileStatus)
    
    if result < 0 {
        printError()
        return
    }
    
    let fileSize = Int(fileStatus.st_size)
    
    let openFlags = O_RDONLY
    let fileDescriptor = open(path, openFlags)
    
    if fileDescriptor < 0 {
        printError()
        return
    }
    
    defer {
        close(fileDescriptor)
    }
    
    let data = malloc(fileSize)!
    
    defer {
        free(data)
    }
    
    var remainingBytesToRead = fileSize
    var totalBytesRead = 0
    
    while remainingBytesToRead > 0 {
        let bytesRead = read(fileDescriptor, data.advanced(by: totalBytesRead), remainingBytesToRead)
        
        if bytesRead < 0 {
            printError()
            return
        }
        
        remainingBytesToRead -= bytesRead
        totalBytesRead += bytesRead
    }
    
    let dataPointer = data.assumingMemoryBound(to: UInt8.self)
    let buffer = UnsafeBufferPointer(start: dataPointer, count: fileSize)
    let characters = buffer.map(UnicodeScalar.init).map(Character.init)
    let fileContent = String(characters)
    
    print(fileContent)
}

printContent(atPath: path)

