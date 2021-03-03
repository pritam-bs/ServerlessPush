// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Alert {
    /// Sign in
    internal static let sessionExpiredActionTitle = L10n.tr("Alert", "SessionExpiredActionTitle")
  }
  internal enum Common {
  }
  internal enum Error {
    /// Failed to load content
    internal static let loadingErrorMessage = L10n.tr("Error", "LoadingErrorMessage")
    /// Loading Error
    internal static let loadingErrorTitle = L10n.tr("Error", "LoadingErrorTitle")
    /// Your internet connection seems to be unavailable
    internal static let networkErrorMessage = L10n.tr("Error", "NetworkErrorMessage")
    /// Network Error
    internal static let networkErrorTitle = L10n.tr("Error", "NetworkErrorTitle")
    /// Session expired please login again
    internal static let sessionExpiredMessage = L10n.tr("Error", "SessionExpiredMessage")
    /// Session Expired
    internal static let sessionExpiredTitle = L10n.tr("Error", "SessionExpiredTitle")
    /// Something went wrong please try again
    internal static let unknownErrorMessage = L10n.tr("Error", "UnknownErrorMessage")
    /// Unknown Error
    internal static let unknownErrorTitle = L10n.tr("Error", "UnknownErrorTitle")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
