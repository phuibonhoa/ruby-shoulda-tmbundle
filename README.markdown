#Shoulda TextMate Bundle

##Description
Adds Shoulda support to Textmate.  To use all features you'll need to use my Ruby and Rails bundles (see the My Other Textmate Bundles section below)

Please Note: If you use my Rails bundle, you do not have to set Shoulda as the active bundle, you may continue to have the Rails bundle set and still gain fully shoulda support.

####Changes
 * Added rvm / bundler support for `⌘+R`, `⇧⌘+R`, `⌃⇧⌘+R`
   * If you have an [rvm wrapper for textmate](https://rvm.io/integration/textmate/) in env `TM_RUBY`, it will try to bundle exec using the same ruby and gemset as your wrapper.
   * You may explicitly set the path to a bundle executable in `TM_BUNDLE` to force it to always use that executable to bundle exec.
 * Support for [Shared Should](http://github.com/michaelgpearce/shared_should) an awesome extension to shoulda for DRYing your tests
   * `ss`, `ssh` for `share_should` snippet and `us` for `use_should`
   * `sc`, `scon` for `share_context` snippet and `uc` for `use_context`
   * `sset` for `share_setup` snippet and `uset` for `use_setup`
   * `⌃⌘+S`  -  Save share_should, share_context, share_setup  (cursor should be in line of defined shared_xxx)
   * `⌃⇧⌘+S`  -  Output use_should, use_context, use_setup based on last saved item
 * Updated the 'Go To Symbol' so it reads just like test output
   * For shared_shoulds this means you can type when ... should ... (as you would read in the test output) in the `⇧⌘+T` menu
 * Added more snippets for context, should, etc.
 * Improved support for running individual shoulds and contexts inside Textmate
 * Context name has the same syntax coloring as method definitions (better readability)
  
  
##Installation

1. $ `cd ~/Library/Application\ Support/TextMate/Bundles/`
2. $ `git clone git://github.com/phuibonhoa/ruby-shoulda-tmbundle.git Shoulda.tmbundle`
3. $ `osascript -e 'tell app "TextMate" to reload bundles'`

If you'd like to install all my bundles, check out this [script](http://gist.github.com/443129) written by [mkdynamic](http://github.com/mkdynamic).  It installs all bundles and backups any existing bundles with conflicting names.  Thanks Mark!

###Using [Spork](https://github.com/timcharper/spork) with focus tests:
* gem install spork --pre (requires spork-0.9.rc9)
* open TextMate preferences and set environment variable SPORK_TESTUNIT=true
* initialize your app for spork (see spork README)
* open a terminal window, cd to the root of your rails app and run spork command.
* focus tests will be run through spork.

##My Other Textmate Bundles
My bundles work best when use in conjunction with my other bundles:

 * Rails - [http://github.com/phuibonhoa/ruby-on-rails-tmbundle](http://github.com/phuibonhoa/ruby-on-rails-tmbundle)
 * Ruby - [http://github.com/phuibonhoa/ruby-tmbundle](http://github.com/phuibonhoa/ruby-tmbundle)
 * Shoulda - [http://github.com/phuibonhoa/ruby-shoulda-tmbundle](http://github.com/phuibonhoa/ruby-shoulda-tmbundle)
 * HAML - [http://github.com/phuibonhoa/handcrafted-haml-textmate-bundle](http://github.com/phuibonhoa/handcrafted-haml-textmate-bundle)
 * Sass - [http://github.com/phuibonhoa/ruby-sass-tmbundle](http://github.com/phuibonhoa/ruby-sass-tmbundle)
 * JavaScript - [http://github.com/phuibonhoa/Javascript-Bundle-Extension](http://github.com/phuibonhoa/Javascript-Bundle-Extension)
 * CTags - [http://github.com/phuibonhoa/tm-ctags-tmbundle](http://github.com/phuibonhoa/tm-ctags-tmbundle)

##Credits

![BookRenter.com Logo](http://assets0.bookrenter.com/images/header/bookrenter_logo.gif "BookRenter.com")

Additions by [Philippe Huibonhoa](http://github.com/phuibonhoa) and funded by [BookRenter.com](http://www.bookrenter.com "BookRenter.com").

Original bundle can be found [here](http://github.com/drnic/ruby-shoulda-tmbundle)
