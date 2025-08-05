//
//  EmailManager.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 09/05/25.
//

class EmailManager {
    
    static let shared = EmailManager()
    private init() {}
    
    @objc public static func syncEmail(email: String, fName: String, lName: String) {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: AppConstant.BUNDLE_IDENTIFIER) as? String ?? ""
        guard !email.isEmpty else {
            debugPrint("Email should not be blank")
            return
        }
        guard email != AppStorage.shared.getString(forKey: "email") else {
            debugPrint("Email id already exists")
            return
        }
        
        let maxLength = 50
        let firstname = String(fName.prefix(maxLength))
        let lastName = String(lName.prefix(maxLength))
        
        guard email.count < 100 else { return }
        guard EmailManager.shared.isValidEmail(email) else {
            print("Invalid Email Address")
            return
        }
        
        guard let token = AppStorage.shared.getString(forKey: AppConstant.IZ_DEVICE_TOKEN), !token.isEmpty,
            let pid = AppStorage.shared.getString(forKey: AppConstant.REGISTERED_ID),
            !pid.isEmpty else {
            //for the first time app install
            let emailAndName = ["email":email, "fName":fName, "lName": lName]
            UserDefaults.standard.set(emailAndName, forKey: AppConstant.FAILED_EMAIL)
            return
        }
        
        addEmailDetails(bundleName: bundleName, token: token, pid: pid, email: email, fName: firstname, lName: lastName)
    }
    
    
    @objc static func addEmailDetails(bundleName: String, token: String, pid: String, email: String, fName: String, lName: String) {
        guard !token.isEmpty, !pid.isEmpty else {
            return
        }
        guard let url = URL(string: ApiConfig.emailSubscriptionUrl) else {
            return
        }
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: AppConstant.IZ_BTYPE),
            URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: AppConstant.IZ_DTYPE),
            URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: ApiConfig.SDK_VERSION),
            URLQueryItem(name: AppConstant.iZ_KEY_OS, value: AppConstant.IZ_OS_TYPE),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "fn", value: fName),
            URLQueryItem(name: "ln", value: lName)
        ]

        let bodyData = components.query?.data(using: .utf8)

        let request = APIRequest(
            url: url,
            method: .POST,
            contentType: .formURLEncoded,
            body: bodyData
        )

        NetworkManager.shared.sendRequest(request) { result in
            switch result {
            case .success:
                debugPrint("Google sign in success!")
                AppStorage.shared.set(email, forKey: "email")
                UserDefaults.standard.removeObject(forKey: AppConstant.FAILED_EMAIL)
                iZooto.addUserProperties(data: ["nlo": "0"])

            case .failure(let error):
                Utils.handleOnceException(bundleName: bundleName, exceptionName: error.localizedDescription, className: "EmailManager", methodName: "addEmailDetails", rid: nil, cid: nil, userInfo: nil)
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        // Regular expression pattern for validating an email address
        let emailRegex = #"^\S+@\S+\.\S+$"#
        
        // Create an NSPredicate with the regex pattern to match the email string
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        // Evaluate the email string against the regular expression
        return emailPredicate.evaluate(with: email)
    }
    
}




