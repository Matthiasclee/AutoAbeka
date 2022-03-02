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
    sleep(0.5)
    videos = driver.find_element(id: "vlistNOTVOD").find_element(tag_name: "ul").find_elements(tag_name: "li")
    driver.execute_script("arguments[0].style.border='2px solid red'", videos[v])

    $stdin.gets if ARGV.include?("--confirmvideo")

    driver.execute_script("arguments[0].click()", videos[v])
    begin
      sleep(1)
      driver.find_element(id: "restartVideo").click
      sleep(10)
    rescue
      sleep(10)
    end
  end

  begin
    play_video_task_name = "Play video #{(v - START_LESSON) + 1}/#{(END_LESSON - START_LESSON) + 1} (#{driver.execute_script('return document.getElementsByClassName("fp-duration")[0].innerHTML')})"
    redo_i = false
  rescue
    puts "Unable to read video time - trying again. Press CTRL+C to cancel"
    redo_i = true
  end
  redo if redo_i

  run play_video_task_name do
    video_length = driver.execute_script('return document.getElementsByClassName("fp-duration")[0].innerHTML')
    time_secs = (video_length.split(":")[0].to_i * 60) + (video_length.split(":")[1].to_i)

    driver.execute_script('document.getElementsByTagName("video")[0].play()')

    for x in (0..time_secs).to_a do
      print "\r" + ("▒" * (time_secs / 30))
      play_video_task_name = "Play video #{(v - START_LESSON) + 1}/#{(END_LESSON - START_LESSON) + 1} (#{driver.execute_script('return document.getElementsByClassName("fp-remaining")[0].innerHTML')})" + ": "
      print ("\r" + play_video_task_name + "▓" * (x/30))
      sleep(1)
    end
    while (driver.execute_script('return document.getElementsByClassName("fp-remaining")[0].innerHTML') != "00:00") do
      sleep(1)
    end
    sleep(10)
  end
end

driver.close
