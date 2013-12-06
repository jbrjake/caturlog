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