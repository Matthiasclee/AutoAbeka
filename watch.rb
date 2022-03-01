require "selenium-webdriver"
require "./.courses.rb"

exit if !(ARGV[0] && ARGV[1] && ARGV[2])

#Define settings
USERNAME = File.read(".usr").chomp
PASSWORD = File.read(".pass").chomp
SUBJECT = ARGV[0]
START_LESSON = ARGV[1].to_i
END_LESSON = ARGV[2].to_i
opts = Selenium::WebDriver::Chrome::Options.new
opts.add_argument("--headless") if !ARGV.include?("--browser")
opts.add_argument("--mute-audio") if !ARGV.include?("--audio")
driver = Selenium::WebDriver.for :chrome, options: opts
driver.manage.window.resize_to(2000, 1000)

def run(description = "Unnamed action")
  print "#{description}: "
  begin
    yield
    puts "✅"
  rescue => err
    puts "❎ (#{err})"
  end
end

run "Visit login page" do
  driver.navigate.to "https://www.abeka.com/ABekaOnline/CustomerService/CustomerLogin.aspx"
  sleep(3)
end
run "Log in" do
  userinput = driver.find_element(name: "ctl00$cphMainContent$txtEmailAddress")
  userinput.send_keys USERNAME
  passinput = driver.find_element(name: "ctl00$cphMainContent$txtPassword")
  passinput.send_keys PASSWORD
  loginbtn = driver.find_element(id: "lbnLogin")
  loginbtn.click
end

for v in (START_LESSON..END_LESSON).to_a do
  run "Go to videos page" do
    driver.navigate.to "https://athome.abeka.com/Video2/Streaming/Default.aspx"
    sleep(10)
    driver.execute_script("location.reload()")
  end
  run "Open subjects menu" do
    driver.find_element(id: "subjectsDropDown").click
  end
  run "Select course" do
    courses = driver.find_element(id: "subjectsDropDown").find_element(tag_name: "ul", class: "dropdown").find_elements(tag_name: "li")
    courses[COURSE_BTN_NUMS[ARGV[0].to_sym]].click
  end

  run "Select video" do
    sleep(3)
    videos = driver.find_element(id: "vlistNOTVOD").find_element(tag_name: "ul").find_elements(tag_name: "li")
    sleep(3)
    driver.execute_script("arguments[0].style.border='2px solid red'", videos[v])
    sleep(3)
    $stdin.gets if ARGV.include?("--confirmvideo")
    driver.execute_script("arguments[0].click()", videos[v])
    sleep(10)
    begin
      driver.find_element(id: "restartVideo").click
      sleep(10)
    rescue
    end
  end
  play_video_title = "NO_TITLE"
  redo_i = false
  loop do
    begin
      play_video_title = "Play video #{(v - START_LESSON) + 1}/#{(END_LESSON - START_LESSON) + 1} (#{driver.execute_script('return document.getElementsByClassName("fp-duration")[0].innerHTML')})"
      break
    rescue
      puts "Unable to read video time - trying again. Press CTRL+C to cancel"
      redo_i = true
      break
    end
  end
  redo if redo_i
  run play_video_title do
    time_remaining = driver.execute_script('return document.getElementsByClassName("fp-duration")[0].innerHTML')
    time_secs = (time_remaining.split(":")[0].to_i * 60) + (time_remaining.split(":")[1].to_i) + 45
    sleep(5)
    print "▒" * (time_secs / 30)
    driver.execute_script('document.getElementsByTagName("video")[0].play()')
    for x in (0..time_secs).to_a do
      play_video_title = "Play video #{(v - START_LESSON) + 1}/#{(END_LESSON - START_LESSON) + 1} (#{driver.execute_script('return document.getElementsByClassName("fp-remaining")[0].innerHTML')})" + ": "
      print ("\r" + play_video_title) 
      print ("\r" + play_video_title + "▓" * (x/30)) if (x % 30) == 0
      sleep(1)
    end
  end
end

driver.close
