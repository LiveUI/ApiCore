//
//  Data+MediaType.swift
//  ImageCore
//
//  Created by Ondrej Rafaj on 13/05/2018.
//

import Foundation
import Vapor


extension Data {
    
    /// Image file extension
    /// Recognizes jpg, png, gif & tiff
    ///
    /// - returns:
    ///     - String enxtension or nil if not valid image type
    public var imageFileExtension: String? {
        var values = [UInt8](repeating:0, count:1)
        copyBytes(to: &values, count: 1)
        switch (values[0]) {
        case 0xFF:
            return "jpg"
        case 0x89:
            return "png"
        case 0x47:
            return "gif"
        case 0x49, 0x4D :
            return "tiff"
        default:
            return nil
        }
    }
    
    /// Image file MediaType
    ///
    /// - returns:
    ///     - MediaType or nil if not valid image type
    public func imageFileMediaType() -> MediaType? {
        guard let ext = imageFileExtension else {
            return nil
        }
        return MediaType.fileExtension(ext)
    }
    
    /// Check if data is a web image
    ///
    /// - returns:
    ///     - Bool
    public func isWebImage() -> Bool {
        guard let ext = imageFileExtension else {
            return false
        }
        return ext == "jpg" || ext == "png" || ext == "gif"
    }
    
}
