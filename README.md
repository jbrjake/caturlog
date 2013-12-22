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

Model Schema
----------------

Items have many-to-many users, tags, and characteristics.

Because different users can tag different items and different tags can relate to lots of different items, items, tags, and users also have many UserItemTags. Each UserItemTag relates one tag to one user for one item.

Characteristics are universal (if one user applies it, it's valid for all because it's the result of a deterministic image analysis) so they don't have to go through the same process to get associated with a user. *This might bite me in the ass, if I ever decide to add support for any non-deterministic analyses, like having different users train different neural networks on different image sets.*

### User ###

#### Properties ####
* User unique ID
* Username
* Password hash

#### Relationships ####
* Items (many)
* UserItemTags(many)

### Item ###

#### Properties #####
* Unique ID (this will also serve as the local link to the content binary)
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