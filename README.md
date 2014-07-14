caturlog
========

A smart library app for memes

Overview
--

A Mac app designed to store, organize, analyze, and categorize still and animated meme images. Its goal is to put the perfect reaction gif for any situation at your fingertips.

Right now, I'm storing this sort of content in Pocket, which is risky: if the original link dies, I lose the gif.

Feature Wishlist
----------------

### Content Acquisition 

What I want is an app where I can simply paste the link to an animated GIF, and it will copy the actual image into the library.

It should also integrate with Pocket and Twitter, to spider the user's feed for content.

### Storage

Images should be stored in a file hierarchy, named with a hash of the content.

Core Data should be used to build a database with all the metadata for the content: its hash, when and where it was obtained, tags, analysis results, etc.

### Tagging

All images will be taggable so that, for example, you can look for images tagged "funny+cat". Ideally, the tags someone uses for content, plus a hash of the content, should be sent upstream to a server so the same tags can be suggested to other users who curate the same content

### Analysis

It's not feasible to thoroughly tag everything, though. The app should do what it can to help connect things. This is the analysis phase, where the content is visually inspected (frame by frame if animation):

* Cat recognition
* Smile and frown recognition
* Facial recognition
* Optical character recognition
* Neural network classification based on tags
	* i.e., build Haar 

The text of tweets that reference the same image should be added as metadata to them.

A filter chain needs to be established that can run independent analyses in parallel, but with the option of running filters in serial when so desired. 

### Sharing

The app needs to support uploading to image sharing services like imgur.

Version 1.0 Milestones: Minimum Viable Product
----------------------

### Version 0.1: Image storage and presentation ###
* I want to be able to enter URLs of images so that I can store copies of them locally
* I want to be able to see a list of stored images so that I can view them

### Version 0.5: Tagging ###
* I want to be able to tag images so that I can find them later
* I want to be able to search the images via tags so that I can find appropriate images for a given situation

### Version 0.9: Sharing ###
* I want to be able to share existing links to the images

Version 1.1 Milestones: Strong search and imgur
----------------------

* I want to be able to generate complex search predicates based on tags so that I can do searches other than tagA AND tagB. For example, (tagA AND tagB) NOT (tagC OR tagD).
* I want to be able to upload images to imgur for sharing so that I don't have to depend on the original image URL still being around.

Version 1.2 Milestones: Twitter and Pocket integration
---------------------- 

* I want to be able to automatically import images from my Twitter feed so that I don't have to manually add them
* I want to be able to automatically import images from my Pocket library so that I don't have to manually add them
* I want to be able to post images to Twitter
* I want to be able to save images to Pocket

Version 1.5 Milestones: Crowd-tagging
-------------------------

* I want to be able to send tags to a server so that every unique piece of content has a centralized record of every tag applied to it by every user
* I want to be able to receive tags from the server so that I can see what other tags other users have applied to an image
* I want to be able to search my library by tags other users have applied to images in my library
* I want to be able to see other tags users have applied to a particular image in my library and apply those tags myself

Version 2.0 Milestones: Analysis
--------------------------------

* I want to be able to add plugins that analyze images in my library and associate them with characteristics, so that I can build up metadata about my images, like OCR'd text
* I want to be able to see what characteristics other users have found for my images
* I want to be able to search based off these characteristics

Model Schema
----------------

Items have many-to-many users, tags, and characteristics.

Because different users can tag different items and different tags can relate to lots of different items, items, tags, and users also have many UserItemTags. Each UserItemTag relates one tag to one user for one item.

Characteristics are universal (if one user applies it, it's valid for all because it's the result of a deterministic image analysis) so they don't have to go through the same process to get associated with a user. *This might bite me in the ass, if I ever decide to add support for any non-deterministic analyses, like having different users train different neural networks on different image sets.*

### User ###

#### Properties ####
* Username
* Password hash

#### Relationships ####
* Items (many)
* UserItemTags(many)

### Item ###

#### Properties #####
* Content ID (this will also serve as the local link to the content binary)
* Timestamp

#### Relationships ####
* Tags (many)
* Characteristics (many)
* Users (many)
* UserItemTags (many)

### Tag ###

#### Properties #####
* Name

#### Relationships ####
* Items (many)
* UserItemTags (many)

### Characteristic ###

#### Properties #####
* Name
* Value

#### Relationships ####
* Items (many)

This design is inherently pretty open. The idea is that everyone shares all their tags with the backend. This is vulnerable to DoS and general fuckery. 

TODO
------

* Import
	* Direct download images from URL
	* Store images on disk
	* Represent the image in Core Data
	* Display the image on screen
* Filtering
	* Inspect frames and bitmaps
	* Filter chain design
		* Run filters in serial and parallel
	* Filter results reporters to synchronize writing to the database
	
Design
------

UI should be like 10.10 Spotlight:
* Search bar at the upper left, to enter tags or gif urls
* Tableview to show results on a left sidebar
* Main view should show gif, with tags below it


So UI wise we're really talking:

* OmnibarView 
	* OmnibarViewController
	* OmnibarViewDelegate
* ResultsTableView
	* ResultsTableViewController
	* ResultsTableViewDelegate
	* Results TableViewDataSource
* DetailView
	* ImageView
		* ImageViewDataSource
	* TagView
		* TagViewDelegate
		* TagViewDatasource

### OmnibarView

An NSTokenField instance. The tokenfield delegate will be the target handling the textDidChange: IBAction. It will use the tokenField's tokens to query the CD store for items matching the comma-separated list of tags.

The view model has the following properties:
* searchTags (an array of objects (strings), empty by default, updated whenever the textfield textdidChange is fired)
* placeholder (a placeholder text string, "Search")

### ResultsTableView

An NSTableView instance. Its datasource will be the result of the omnibarview's search. When an item is selected, the delegate will pass it to the imageview datasource for display.

The view model has the following properties:
* results

### DetailView

The imageview datasource will update the imageview with the URL of a new image to display. 

The view model has the following properties:
* resultImage

### TagView

This one will be the most complicated. It needs to display a list of tags as blue labels, but also show suggested tags as grayed-out/dotted round labels that can be clicked to assign them and make them blue/solid. And accept text input, separating tags by comma value.

A lot of this is really going to need to go in a category so it can be reused to display tags entered in the search bar as well.

One way to handle it may be to have it in three separate views, at least at first: text field for entering new tags, list of existing tags, list of suggested tags.

This view will need to use NSTokenField.

The view model has the following properties:
* resultTags

Data Flow
---------

*Pulling from http://www.raywenderlich.com/74106/mvvm-tutorial-with-reactivecocoa-part-1 ...*

View -> ViewController -> ViewModel -> ModelServices -> Service Protocols -> Service Implementations -> Model Collection -> Model

So for example...

Omnibar -> OmbibarViewController -> OmnibarViewModel -> CaturlogServices -> TagSearchServiceProtocol -> TagSearchService -> TagSearchResults -> Item
 
ResultsTableView -> ResultsTableViewController -> ResultsTableViewDataSource -> TagSearchResults -> Item

DetailView -> DetailViewController -> DetailViewModel -> ItemImage

TagView -> TagViewController -> TagViewModel -> ItemTags

Image Downloading
-----------------

Image downloading will be handled by a member of CaturlogServices, ResourceLoader, which will implement a ResourceLoadingServiceProtocol.

CaturlogServices:
* Has a property that's an object adhering to the ResourceLoadingServiceProtocol.

ResourceLoadingServiceProtocol has one method:
func getResource(url: NSURL, completion: (data: NSData?) -> () ) 

The ResourceLoader implementation will first look to see if it has a copy of the file on disk. It will look based off info from Core Data and the model. It will expect images to be in the Application Support/items/ directory, with the  name being a hash of the image.

It will also store an NSCache of images, in hopes of not duplicating space in memory.


