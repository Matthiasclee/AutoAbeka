# AutoAbeka

## It takes the "work" out of work

AutoAbeka is a script that can automatically watch Abeka Homeschool videos on mute in the background.

## Requirements

* Ruby 2.6.5
* selenium-webdriver
* chromedriver
* Decent internet access

## Setup

* Make a file called `.usr` and put your Abeka username in it
* Make a file called `.pass` and put your Abeka password in it
* Make a file called `.courses.rb` and put a list of courses it it like this:
```rb
COURSE_BTN_NUMS = {
  :pre_alg => 0,
  :bible => 1,
  :reading => 2,
  :math => 3,
  :activities => 4,
  :science => 5,
  :health => 6,
  :history => 7,
  :language => 8,
  :handwriting => 9
}
```

## How to use

Run the following command: `ruby watch.rb <course> <start_video> <end_video> <options>`

* \<course\> is the course you want to watch videos for
* \<start\_video\> is the video to start watching with 0 being the first video in the list
* \<end\_video\> is the video to stop watching on, starting at 0
* \<options\> can be `--browser` to show the browser and `--audio` to play the audio
