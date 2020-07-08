import 'dart:io';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:reply_flutter/core/data/repository/firebase_repository.dart';
import 'package:reply_flutter/core/services/AuthService.dart';
import 'package:reply_flutter/styles/colors.dart';
import 'package:reply_flutter/ui/screens/home.dart';
import 'package:reply_flutter/ui/screens/register.dart';
import 'package:reply_flutter/ui/screens/signin.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

class Welcomes extends StatefulWidget {
  @override
  _WelcomesState createState() => _WelcomesState();
}

class _WelcomesState extends State<Welcomes> {
  static final String routeName = 'welcomes';

  static String route = 'welcomes';

  final bool isAndroid = Platform.isAndroid;

  final FirebaseRepository firebaseRepository = FirebaseRepository();

  String appleSignInErrorMessage;

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      //check for ios if developing for both android & ios
      AppleSignIn.onCredentialRevoked.listen((_) {
        print("Apple Credentials revoked");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: kPrimaryColor,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Reply',
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      .copyWith(color: kPrimaryColor),
                ),
                Image.asset('images/icons8_comments_48.png'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      child: Material(
                        color: kPrimaryColorLight,
                        borderRadius: BorderRadius.circular(30.0),
                        elevation: 5.0,
                        child: MaterialButton(
                          minWidth: 400,
                          elevation: 16,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, SignIn.routeName);
                          },
                          child: Text(
                            'Sign in',
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      child: Material(
                        color: kPrimaryColor100,
                        borderRadius: BorderRadius.circular(30.0),
                        child: MaterialButton(
                          minWidth: 400,
                          child: Text(
                            'Register',
                            style: Theme.of(context).textTheme.button,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, Register.routeName);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0), // <= NEW
                    Text(
                      'OR',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Material(
                        child: MaterialButton(
                          color: Colors.grey.shade100,
                          minWidth: 400,
                          splashColor: Colors.grey,
                          onPressed: () async {
                            await Provider.of<AuthService>(context,
                                    listen: false)
                                .signInWithGoogle()
                                .then((FirebaseUser firebaseUser) async {
                              // If it is a new user (signing in for the first time), create a user in the database
                              if (firebaseUser.metadata.creationTime ==
                                  firebaseUser.metadata.lastSignInTime) {
                                firebaseRepository
                                    .createUserInDatabaseWithGoogleProvider(
                                        firebaseUser);
                              }
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => Home(
                                            firebaseUser: firebaseUser,
                                          )),
                                  (Route<dynamic> route) => false);
                            }).catchError((e) => print(e));
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          highlightElevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image(
                                    image: AssetImage("images/google_logo.png"),
                                    height: 30.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'Created by',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Image.asset(
                        'images/associate_android_developer_badge_small.png',
                        width: 96,
                        height: 96,
                      ),
                      GestureDetector(
                        onTap: _openPersonalWebsite,
                        child: Text('Ashton Jones',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: kPrimaryColor,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Reply',
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      .copyWith(color: kPrimaryColor),
                ),
                Image.asset('images/icons8_comments_48.png'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      child: Material(
                        color: kPrimaryColorLight,
                        borderRadius: BorderRadius.circular(30.0),
                        elevation: 5.0,
                        child: MaterialButton(
                          minWidth: 400,
                          elevation: 16,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, SignIn.routeName);
                          },
                          child: Text(
                            'Sign in',
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      child: Material(
                        color: kPrimaryColor100,
                        borderRadius: BorderRadius.circular(30.0),
                        child: MaterialButton(
                          minWidth: 400,
                          child: Text(
                            'Register',
                            style: Theme.of(context).textTheme.button,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, Register.routeName);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0), // <= NEW
                    Text(
                      'OR',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AppleSignInButton(
                        style: ButtonStyle.black,
                        type: ButtonType.continueButton,
                        onPressed: () {
                          signInWithApple(context);
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'Created by',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Image.asset(
                        'images/associate_android_developer_badge_small.png',
                        width: 96,
                        height: 96,
                      ),
                      GestureDetector(
                        onTap: _openPersonalWebsite,
                        child: Text('Ashton Jones',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  void signInWithApple(BuildContext context) async {
    // Sign In with Apple is only supported on iOS 13+
    if (await AppleSignIn.isAvailable()) {
      try {
        final AuthorizationResult result = await AppleSignIn.performRequests([
          AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
        ]);

        switch (result.status) {
          case AuthorizationStatus.authorized:
            try {
              print('${result.credential.user} signed in with Apple');
              final AppleIdCredential appleIdCredential = result.credential;

              OAuthProvider oAuthProvider =
                  new OAuthProvider(providerId: 'apple.com');
              final AuthCredential credential = oAuthProvider.getCredential(
                idToken: String.fromCharCodes(appleIdCredential.identityToken),
                accessToken:
                    String.fromCharCodes(appleIdCredential.authorizationCode),
              );

              // Sign into Firebase using Apple credentials

              final FirebaseAuth _auth = FirebaseAuth.instance;


              final AuthResult authResult = await _auth.signInWithCredential(credential);
              final FirebaseUser firebaseUser = authResult.user;
              print(
                  '${firebaseUser.uid} successfully signed in user with Apple Provider');

              // Get the current user, which should now be signed in with Apple
              // Update the UserInfo with Apple profile information
              FirebaseAuth.instance.currentUser().then((val) async {
                UserUpdateInfo updateUser = UserUpdateInfo();
                updateUser.displayName =
                    '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
                await val
                    .updateProfile(updateUser)
                    .catchError((error) => print(error));

                // Need to make this call to get the updated display name; or else display name will be null
                FirebaseUser updatedUser =
                    await FirebaseAuth.instance.currentUser();

                // refresh data
                updatedUser.reload();

                print(
                    'Updated user profile information: Name: ${updateUser.displayName}');

                // If it is a new user, created a user in the Database
                if (firebaseUser.metadata.creationTime ==
                    firebaseUser.metadata.lastSignInTime) {
                  firebaseRepository.createUserInDatabaseWithAppleProvider(
                      updatedUser);
                }

                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => Home(
                              firebaseUser: updatedUser,
                            )),
                    (Route<dynamic> route) => false);
              });
            } catch (e) {
              print('error');
            }
            break;
          case AuthorizationStatus.error:
            print("Sign in failed: ${result.error.localizedDescription}");
            break;

          case AuthorizationStatus.cancelled:
            print('User cancelled');
            break;
        }
      } catch (error) {
        print('error with apple sign in');
      }
    } else {
      print('Apple SignIn is not available for your device');
    }
  }

  void checkLoggedInState() async {
    final userId = await FlutterSecureStorage().read(key: "userId");
    if (userId == null) {
      print("No stored user ID");
      return;
    }

    final credentialState = await AppleSignIn.getCredentialState(userId);
    switch (credentialState.status) {
      case CredentialStatus.authorized:
        print("getCredentialState returned authorized");
        break;

      case CredentialStatus.error:
        print(
            "getCredentialState returned an error: ${credentialState.error.localizedDescription}");
        break;

      case CredentialStatus.revoked:
        print("getCredentialState returned revoked");
        break;

      case CredentialStatus.notFound:
        print("getCredentialState returned not found");
        break;

      case CredentialStatus.transferred:
        print("getCredentialState returned not transferred");
        break;
    }
  }

  _openPersonalWebsite() async {
    const url = 'https://ashtonjones.dev/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
