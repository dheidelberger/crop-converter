# Crop Converter

##### What is it?
Crop Converter is a simple Ruby script to convert horizontal guides in a PSD file into a series of crop effects in Adobe Premiere.

##### Why would I need that?
In a word (or two), *bullet points.* In a few more words, I often do work for a client where I have a lot of bullet points that need to incrementally appear. I make a PSD of the bullet points, very quickly make a series of horizontal guides between each line, and then run it through this script. The script generates an XML file that can be brought into Premiere. The XML consists of a timeline with several copies of the PSD file. Each clip is cropped to one of the guides that I set up in Photoshop.

##### I still don't understand
It's kind of hard to describe, but here's a quick video demonstrating the concept:
*video tbd*

#
#
### Requirements
Crop Converter requires Ruby. If you're on a Mac, you're in luck, Macs include Ruby by default. However, Macs running an OS X version that's older than Mavericks (10.9), may have an older version of Ruby installed that won't work with this script. If you're in that situation, upgrading to a new version of Ruby is quite easy using  [RVM](https://rvm.io/), which is the way I recommend working with Ruby anyway. If you're on Windows, er, honestly, you're kind of [on your own](http://rubyinstaller.org/).

Crop Converter also requires two Ruby gems in order to work. Gems are add-on libraries that other people have written for Ruby. See the Installation section for how to install gems. Crop Converter uses:
- [PSD](https://github.com/layervault/psd.rb) - A gem for parsing PSD files
- [Addressable](https://github.com/sporkmonger/addressable) - A gem for doing some URI manipulation

#
#
### Installation
Copy the CropConverter.rb file to any convenient folder. Then, install the gems.

##### Mac
To install the gems, on the Mac, go to the Terminal, which is in Applications>Utilities. Then type each of the following lines, pressing enter between each:
```Bash
gem install psd
gem install addressable
```
If you get an error message about insufficient permissions, try typing:
```Bash
sudo gem install psd
sudo gem install addressable
```
In that case, it will prompt you for your password. Enter your password and press enter. Although it will be registering the keystrokes of your password, the cursor won't move.

Once the gems are installed, you shouldn't need to install them again unless you change your Ruby version.

##### Windows
If you're on Windows, um, yeah, install the gems...however it is you do that on Windows (can you tell I'm a Mac guy?). You should be able to follow the same steps as above from the command prompt.

#
#
### Usage
Usage is quite simple.
- Open the Terminal on a Mac or the Command Prompt on Windows. For Macs, this is in Applications>Utilities.
- At the prompt, type `ruby` and then a space
- Drag-and-drop the CropConverter.rb file onto the terminal window. This will paste in some text showing the path to the Ruby file.
- Optionally, set the framerate with the `-f` or `--framerate` flags. Acceptable values are: 23.976, 23.98, 24, 25, 29.97, 30, 50, 59.94, or 60. If you don't set the framerate, by default, it will be 29.97, There is also a way to change the default value, see below. So, for example, if you wanted the XML to be 59.94fps, right after ```ruby [PATH TO RUBY FILE]```, put a space and type `-f 59.94 `.
- Make another space
- Drag-and-drop as many PSD files as you like onto the Termianl window. It will paste in a list of files separated by spaces.
- Press enter
- When the program is done, there will be an XML file next to every PSD file. Just drag those XMLs into Premiere and you'll be all set.

As an example, here is a full command from my computer. In this example, we'll assume that the CropConverter.rb file is in my Documents folder, I want a framerate of 24, and I'm using two files on my Desktop called `Bullet 1.psd` and `Bullet 2.psd`. The username on my computer is `davidheidelberger`. Obviously, this will be different on your computer and you'll have to change the username accordingly. By dragging and dropping the various files in, you should be able to avoid having to type any sort of username or folder structure at all.
```Bash
ruby /Users/davidheidelberger/Documents/CropConverter.rb -f 24  /Users/davidheidelberger/Desktop/Bullet\ 1.psd /Users/davidheidelberger/Desktop/Bullet\ 2.psd
```

#
#
### Changing Defaults
There are three defaults that are meant to be user configurable at the top of the script. Open the CropConverter.rb file in a text editor. On a Mac, use TextEdit, on Windows, Notepad. Please do not use Microsoft Word. It can mess up plain text files. You'll see three lines towards the top of the file that say:
```Ruby
DEFAULT_FRAMERATE = 29.97
SHOT_LENGTH = 3
IN_PAD = 5*60
```

Feel free to adjust the number values.
- `DEFAULT_FRAMERATE` is the framerate of the XML if you don't specify it at the command prompt.
- `SHOT_LENGTH` is the duration of the clips in the XML in seconds.
- `IN_PAD` is the duration of the left handle in seconds of the clips in your timeline. It's set to five minutes by default, so you probably don't need to adjust it, but this line is there in case you do.

After you've adjusted the values, save the file.

#
#
### Todos

 - Add more customization options and flags
 - Bundler support
 - Maybe make a Premiere Panel adaptation
 - Better (read: any) error handling
 - Profit?

#
#
### License
Distributed under an MIT license. See [LICENSE.txt](LICENSE.txt) for more details. In addition, if you use or adapt this program for anything, I'd love an email to see what you're doing with it. Any feedback is also welcome.