//
//  TemplateSource.swift
//  ApiCore
//
//  Created by Ondrej Rafaj on 16/04/2019.
//

import Foundation
import Templator


public protocol TemplateSource: Source where Self.Database == ApiCoreDatabase { }
