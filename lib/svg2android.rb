require "selenium-webdriver"
require 'fileutils'

class TestRunner
  def initialize(config)
    @config = config
    @driver = ""
    @time = Hash.new
    @index = config['keyIndex']
    @testCase = ""
    # @screenshotPath = "#{Dir.pwd}/log/#{@config['browsers']}/#{@config['screenshotPath']}/#{@index+1}"
    @screenshotPath = "#{Dir.pwd}/log/#{@config['browsers']}/screenshot/#{@index+1}"
  end
  def init()
    start = Time.new

    case @config['browsers']
    when "firefox"
      @driver = Selenium::WebDriver.for :firefox, :profile => "Driver"
    when "safari"
      # opts = Selenium::WebDriver::Safari::Options.new
      # opts.add_extension "#{Dir.pwd}/../selenium/SafariDriver.safariextz"
      @driver = Selenium::WebDriver.for :safari
    when "opera"
      Selenium::WebDriver::Chrome.driver_path = "#{Dir.pwd}/../selenium/operadriver.exe"
      @driver = Selenium::WebDriver.for :chrome
    when "chrome"
      @driver = Selenium::WebDriver.for :chrome
    when "ie"
      @driver = Selenium::WebDriver.for :ie
    when "phantomjs"
      @driver = Selenium::WebDriver.for :phantomjs
    else
      puts "Browser you specified not supported yet"
    end

    finish = Time.new

    logTime "initialize", start, finish
  end
  def start(testCase=nil)
    @testCase = testCase

    beforeExecution

    loadUrl(@config['startingUrl'])

    mainTest(testCase)

    afterExecution
  end
  def stop
    @driver.quit
    @testCase['time'] = @time
    puts "====================== Finish : Test Case Number #{@index+1}"
    return @testCase
  end
  def config
    @config
  end

  private #Private method dibawah
  def logTime(index,start,finish)
    @time[index] = Hash.new
    @time[index]['start'] = start
    @time[index]['finish'] = finish
    @time[index]['time'] = finish - start
  end
  def loadUrl(url)
    puts "- Load Url"
    takeScreenshot(@screenshotPath,'loadUrl','start')

    start = Time.new

    if url
      @driver.get url
    end

    finish = Time.new

    logTime "load", start, finish

    takeScreenshot(@screenshotPath,'loadUrl','finish')
  end
  def mainTest(testCase)
    puts "- Executing Main Test"
    takeScreenshot(@screenshotPath,'MainExecution','start')

    start = Time.new

    if @config['scenario'] and File.exist?(@config['scenario'])
      load "#{Dir.pwd}/#{@config['scenario']}" #work LOL
      test = Test.new(testCase,@driver).run
      @testCase['assertion'] = test
    end

    finish = Time.new

    logTime "main", start, finish

    takeScreenshot(@screenshotPath,'MainExecution','finish')
  end
  def beforeExecution
    puts "- Executing Pre Script"
    takeScreenshot(@screenshotPath,'PreExecution','load')

    start = Time.new

    if @config['before'] and File.exist?(@config['before'])
      load "#{Dir.pwd}/#{@config['before']}" #work LOL
      test = BeforeTest.new(@testCase,@driver).run
    end

    finish = Time.new

    logTime "before", start, finish

    takeScreenshot(@screenshotPath,'PreExecution','finish')
  end
  def afterExecution
    puts "- Executing After Execution Script"
    takeScreenshot(@screenshotPath,'AfterExecution','load')

    start = Time.new

    if @config['after'] and File.exist?(@config['after'])
      load "#{Dir.pwd}/#{@config['after']}"
      test = AfterTest.new(@testCase,@driver).run
    end

    finish = Time.new

    logTime "after", start, finish

    takeScreenshot(@screenshotPath,'AfterExecution','finish')
  end
  def takeScreenshot(folderPath,prefix=nil,sufix=nil)
    if @config['screenshot']
      if !Dir.exist? "#{folderPath}/"
        FileUtils::mkdir_p "#{folderPath}/"
      end
      # @driver.save_screenshot("#{folderPath}/#{prefix}-#{sufix}.png")
      picture = @driver.screenshot_as :png
      File.open("#{folderPath}/#{prefix}-#{sufix}.png","wb") do |f|
        f.write(picture)
      end
    end
  end
end
