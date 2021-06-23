platform :ios, '13.0'

target 'MessengerApp' do
  use_frameworks!

# Firebase

	pod 'Firebase/Core'
	pod 'Firebase/Storage'
	pod 'Firebase/Database'
	pod 'Firebase/Auth'
	pod 'Firebase/Analytics'
	pod 'Firebase/Crashlytics'

# Facebook

	pod 'FBSDKCoreKit'
	pod 'FBSDKLoginKit'
	pod 'FBSDKShareKit'

# Google
	
	pod 'GoogleSignIn'

# Allow message user inteface, make manually but this is useful.

	pod 'MessageKit'

# This is allow showing looking good spiner overlay had display any activity going on, Apple has own UIACtivityindicator

	pod 'JGProgressHUD'

# Realm is Database similary with core data, basically save to the device, when we open up the app internet we can still have cache data, we can also use this improve performance of app general reduce number of times reads firebase reduce our database cost.

	pod 'RealmSwift'
	
# allows a lot of image loading capabilities, traditionally when you load image from url download it and showing in image view but not cache involve as you can cache yourself all that manage yourself, SDWebImage is give to a lot fo that additional feature for you

	pod 'SDWebImage'

end
