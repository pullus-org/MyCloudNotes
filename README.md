# MyCloudNotes

A macOS-client for the notes-app of [Nextcloud](https://nextcloud.com) and [Owncloud](https://owncloud.org).

![Screenshot](https://raw.githubusercontent.com/pullus-org/MyCloudNotes/master/Documentation/MyCloudNotes.png "MyCloudNotes")

## Features

* Optional synchronization at start and quit
* Automatic synchronization every 5, 15 or 60 minutes
* Favorites
* Categories
* Markdown
* Search for notes by content
* Import and export of notes

## Hint

MyCloudNotes is available in two Versions:

- *MyCloudNotes* with the [App Transport Security (ATS)](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33) at the AppStore and
- *MyCloudNotes (CustomSSL)* with an **optional** App Transport Security at GitHub

If you want to support the development select the version from the AppStore. If you are using an Nextcloud/Owncloud server and have trouble with a self signed certificate you should use the version from GitHub.

## Requirements

* macOS 10.12 
* HTTPS-Nextcloud-Server with the notes-app from the integrated marketplace or from [GitHub](https://github.com/nextcloud/notes)
* HTTPS-Owncloud-Server with the notes-app from the integrated marketplace or from [GitHub](https://github.com/owncloud/notes)

## Technology

* Xcode 9
* Swift 4
* [Alamofire](https://github.com/Alamofire/Alamofire)
* [Marklight](https://github.com/macteo/Marklight)
* [PDKeychainBindingsController](https://github.com/carlbrown/PDKeychainBindingsController)

## Sources and Build

The sources are free and hosted at [GitHub](https://github.com/pullus-org/MyCloudNotes). To build *MyCloudNotes* and *MyCloudNotes (CustomSLL)* load or clone the sources and build the executables with [XCode](https://developer.apple.com/xcode/).

    git clone https://github.com/pullus-org/MyCloudNotes.git
    cd MyCloudNotes/
    git submodule update --init
    open MyCloudNotes.xcodeproj/

## Copyright

© Frank Schuster 2017, 2018

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
