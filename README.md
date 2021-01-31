# QuerIt
## A CP2106 (Orbital) Project by Team S/UGong


### Tech Stack:
Flutter(Dart), Firebase

### Level of Achievement:
Project Gemini

![](/images/orbital_cert_joel.PNG)
![](/images/joven_cert.PNG)

### Contributions:

#### Joel (GitHub username: joelngyx):
- Implemented prototype 
- Refined UI elements
- Improved UI of the Home Page
- Implemented geolocation functions
- Implemented room creation 
- Implemented archive function
- Debugged for both front end and back end

#### Joven (GitHub username: CSMortal):
- Implemented prototype
- Refined UI elements
- Improved the login pages
- Implemented the Register page
- Implemented voting system 
- Implemented threads
- Debugged for both front end and back end

### Poster:
A brief overview of our app



![](/images/Poster.PNG)

### Scope of Project:

QuerIt is an android app that functions as a chat app that allows users to create chat rooms that can be joined by other users in the vicinity. These chat rooms will have various features, such as a voting system for messages that are deemed useful.

### Target Audience:

Anyone who is participating in a lecture/seminar, be it the speaker or the audience. We feel this would be especially useful in seminars when most people do not know each other (as well as each other’s contacts), because this app allows for people to ask questions and reply to them readily, optionally behind the veil of anonymity.

### Aim:

We hope to let people clarify doubts and provide feedback in a quick and anonymous manner through our app during lectures so as to have a more satisfactory experience in said lectures.

### Features:

#### Core Features:

1. User Authentication + Anonymous Sign In

- What it is: This allows users to login/sign up with their email and password, or sign in anonymously
- Status: Implemented. The back-end is functional. Might include other forms of sign-in like thru Google/Facebook in the future

2. Creating a Chat Room with geolocation

- What it is: Users can create a chat room. The chat room’s position depends on the User’s position when he creates the room. These chat rooms will delete themselves 5 seconds after the last person leaves the chat room
- Status: Implemented the setting up process. The back-end and the geolocation processes are functional
 
3. Creating a Thread + Commenting in the thread

- What it is: Once inside a room, users can create threads, where others can give their two cents on the topic. All users can upvote/downvote a thread at most once. Users can also comment on each thread, and upvote/downvote such comments.
- Status: Done. Back-end is functional. 

4. Use of geolocation to allow users to join chat rooms around them

- What it is: Upon creation of a chat room, people around the area where the chat room was created will be able to join and participate in the chat room. This would require GPS and geolocation to implement.
- Status: Implemented. Users are able to create chat rooms, and they are able to see and join these chatrooms if the chatroom positions are within a radius (set by the room's creator) from the users. The back-end and the geolocation processes are functional.

#### Additional features:

1. Voting System 

- What it is: Users can vote on questions as well as answers, to give more visibility to useful answers and popular questions
- Status: implemented. Threads will now appear in the list based on the number of votes they have. As you can see in the later part of the demo, the voting functionality does not appear for the comments (message) due to some issues when we merged our final branch to the default branch. We plan to fix this in the future.

2. Quickly view top comment for a thread

- What it is: Users will have the option to view the top comment in a thread. This is useful when a thread has many comments, since the comments are displayed in chronological order, and it can be hard for anyone to sift out the best comment if they are lazy to keep scrolling down.
- Status: Barely implemented. Might complete it before splashdown.

3. Archived Messages

- What it is: Users can bookmark comments for future reference
- Status: implemented. Bookmarked comments will now appear in the “archived messages” page. However, we ran into a problem when the final branch merge caused this functionality to fail. We will work on this.
    
### Approach and technology used:

#### General approach:

- Each page eg. The Sign in page, the Home page, are all in separate classes. Some classes depend on other classes. We separated our whole codebase into directories called Pages, Services, Models, Settings and Shared. Models refers to our abstract data types that we use to represent a comment, a room, a thread etc, while Services refers to classes that aid us in communicating with our database or in authentication.
- Use of navigator.push/pop to go between pages
- Use of streams to read/write information from/into our Firestore database

#### Geolocation to find rooms around the User

- We stream the User’s location using functions in the Geolocator plugin. 
- Then, using the User’s location provided from this stream, we stream the rooms around the User into the Home page (where the User sees the chat rooms around him). 
- This is achieved by using functions provided in the Cloud Firestore plugin and the GeoFlutterFire plugin


### Limitations/ Areas for improvement/Bugs arose from testing:

1. Bugs with locating the User’s position- sometimes, the app returns location = (0.0, 0.0). It usually resolves itself with a few taps on the refresh button
2. Users are unable to set the radius of the chat rooms. It is currently fixed at 50m. We would implement this feature in the future.
3. Security- we are unsure about how secure our app is
4. App is sometimes unable to toggle the sign in page to show the register page
5. Tested app on an actual Android Device, crashes on occasion.
6. Yet to capitalize on Flutter and implement the app on iOS
    
### Things that went well during testing:

1. Relatively bug-free when testing on actual Android devices. No overflow errors in general.
2. Validation for text fields like creating a thread, or making a comment works.
3. Geolocation works generally, and if bugs are encountered, they will be resolved with a few taps of the refresh button.


### Link to our demo video:

https://drive.google.com/drive/folders/1HxX19_DUvqI0dFxBBuCuVpyh9xhdyxTB?usp=sharing

### Further testing:

If you would like to test out our app, simply: 
1. Download the zip file in the release tab of our GitHub page. 
2. Have Android Studio installed, and have an Android Emulator running. 
3. Drag the apk file from the zip file into the emulator. The app will install immediately.
4. Run QuerIt on your emulator. Test it out with your friends!