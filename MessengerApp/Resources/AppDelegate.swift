//
//  AppDelegate.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

// ‼️ Google sign in handled in AppDelegate.

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = TabBarViewController()
        self.window = window
        self.window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // reason of FirebaseApp.app() is 'optional'
        // incase is not able to find plist to grap my clientID. it will return nil
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // this function get from facebook SDK
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        // allow this app for open up google sign in webview
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    // automatically step out the function when added GIDSignInDelegate
    // this function is call when user is success sign in and it pass user object('didSignInFor user: GIDGoogleUser!')
    // c.f : similar how treat that access token from facebook for firebase credential
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Managed Error
        
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google: \(error)")
            }
            return
        }
        
        guard let user = user else {
            return
        }
        
        print("Did sign in with Google: \(user)")
        
        // get user email, name
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName
        else {
            return
        }
        
        // grap 'email' data from google sign in 'monstrosity google sign mehod'
        UserDefaults.standard.setValue(email, forKey: "email")
        
        // grap 'user's profile given name and family name' data from google sign method
        UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
        
        
        
        // MARK:- reason of cache user's email use by UserDefault
        // ‼️ why do I save user email?? (from fb, google, firebase) ‼️
        /*
         -> reason of saving user email use by UserDefault in the device,
         my firebase storage bucket has standardized format for their image
         so I can actually just the email to query out the image for the user
        */
        
        
        
        // check before firebase credendial
        // user email exists check
        DatabaseManager.shared.userExist(with: email) { exists in
            // if user email dosen't exists excute 'if statement'
            // if user already dose exists in database. skip this 'if statment' and treat cridential
            // insert to database
            if !exists {
                let userInfo = UserInfo(firstName: firstName,
                                        lastName: lastName,
                                        emailAddress: email)
                // gonna insert to database
                DatabaseManager.shared.insertUser(with: userInfo) { success in
                    if success {
                        /*
                         check if the google profile picture actually exist
                         */
                        
                        // -> if user have image
                        if user.profile.hasImage {
                            // -> if able to get a url image of dimension.
                            guard let url = user.profile.imageURL(withDimension: 200) else {
                                return
                            }
                            // want than download byte for the 'url'
                            URLSession.shared.dataTask(with: url) { data, urlResponse, error in
                                guard let data = data else {
                                    return
                                }
                                
                                guard let urlResponse = urlResponse else {
                                    return
                                }
                                print("url response result : \(urlResponse)")
                                
                                guard error == nil else {
                                    print("Can't get image url, error description : \(error)")
                                    return
                                }
                                
                                let fileName = userInfo.profilePictureFileName
                                
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                                    switch result {
                                    case .success(let downloadURL):
                                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture")
                                        print(downloadURL)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
        }
        
        // treat access token from google for a firebase cridential
        guard let authentication = user.authentication else {
            print("Missing auth object off of google user")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        
        
        // firebase auth actualy sign in
        FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
            guard authResult != nil, error == nil else {
                print("failed to sign in with google credential.")
                return
            }
            
            print("Successfully signed in with Google credential.")
            /*
             fire the notification when successfullt signed in with google, it will defer the controll rather
             it will telled login notification who is observing
             */
            
            // if sign in, it will be dismiss
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        }
    }
    
    // this is other delegate function for the google sign in delegate
    // disconnect user, log out
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
    }

}
