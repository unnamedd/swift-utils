import Foundation

class FilePathAsserter {
    /**
     * Tests if a path is absolute /User/John/ or relative : ../../ or styles/design/
     */
    static func isAbsolute(path:String, pathSeperator:String = "/") -> Bool{
        return path.hasPrefix(pathSeperator)
    }
}
