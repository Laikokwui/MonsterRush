require 'gosu'

# Order of my elements on the window
module ZOrder
	BACKGROUND, MIDDLE, TOP = *0..2
end

class Colour
	
	attr_reader :white, :black, :green 
	
	def initialize # Colour codes
		@white = 0xffffffff
		@black = 0xff000000
		@green = 0xff00ff00
	end
end

class Game < Gosu::Window
    
	def initialize
		super 700, 540 # Window size
		self.caption = "Monster Rush" # Title of the window
		
		# Link the class
		@colour = Colour.new
		@sprites = Sprites.new
        
		# Link and load all of the image file
		@background_image = Gosu::Image.new("assets/gui/mainmenu.jpg")
		@playmenu_image = Gosu::Image.new("assets/gui/playmenu.png")
		@tree = Gosu::Image.new("assets/gui/tree.png")
		@recordmenu_image = Gosu::Image.new("assets/gui/recordmenu.png")
		@gameover_image = Gosu::Image.new("assets/gui/gameover.png")
		@startmenu_image = Gosu::Image.new("assets/gui/startmenu.png")
        @tutorialmenu_image = Gosu::Image.new("assets/gui/tutorialmenu.png")
		@logo = Gosu::Image.new("assets/gui/MONSTERRUSH.png")
		
		# Create different text size
		@info_font40 = Gosu::Font.new(40)
		@info_font25 = Gosu::Font.new(25)
		
		# Placement of the text
		@center_x = 700 / 2
		@linespace = 70
		
		# Link and load all of the music file
		@bgm = Gosu::Song.new("Music/bgm/Thunderstorm.wav")
		@bgm2 = Gosu::Song.new("Music/bgm/London_Fog.wav")
        @bgm3 = Gosu::Song.new("Music/effect/player_hurt.wav")
		@effect1 = Gosu::Sample.new("Music/effect/player_hurt.wav")
        @effect2 = Gosu::Sample.new("Music/effect/zombie_hurt.wav")
        @effect3 = Gosu::Sample.new("Music/effect/heal.wav")
		
		@selection = ["Start", "Record", "Quit"] # Use array to store options for user to choose
		
      	@highlighted = 0 # Check which option is selected
		@kill = 0 # Number of kills
        @playerhealth = 100 # Player's health
        
		mainmenu() # Open mainmenu
	end
	
	def mainmenu()
		@bgm.play(looping=true) # Play music
		
		def selection_highlighted?(x) # Check whether the option is highlighted or not
			@highlighted == x
		end

		def next_selection # Highlight the next menu option as selected
			@highlighted = (@highlighted + 1) % @selection.length
		end

		def previous_selection # Highlight the previous menu option as selected
			@highlighted = (@highlighted - 1) % @selection.length
		end

		def selected # Executes the highlighted option after the user input
			case @selection[@highlighted]
				when "Start" then tutorialmenu() # Go to startmenu
				when "Record" then recordmenu() # Go to recordmenu
				when "Quit" then close() # Quit
			end
		end
		
		def draw
			@background_image.draw(0, 0, ZOrder::BACKGROUND) # Background mainmenu
			@logo.draw(80,100, ZOrder::BACKGROUND) # Logo Monster Rush
			
			for x in 0..2 # Render the texts from the array using for loop
				colour = selection_highlighted?(x) ? @colour.black : @colour.white # When option is highlighted font colour change from white to black
				@info_font40.draw_text_rel(@selection[x], @center_x, 324 + x * @linespace, ZOrder::TOP, 0.5, 0.5, 1, 1, colour)
			end

			case @selection[@highlighted] # Render the shapes to highlight the current selection
				when "Start" then Gosu.draw_rect(275, 300, 150, 45, @colour.green, ZOrder::BACKGROUND, mode=:default)
				when "Record" then Gosu.draw_rect(275, 370, 150, 45, @colour.green, ZOrder::BACKGROUND, mode=:default)
				when "Quit" then Gosu.draw_rect(275, 440, 150, 45, @colour.green, ZOrder::BACKGROUND, mode=:default)
			end
		end
	
		def button_down(id) # Call the function after the user presses down a button
			case id
				when Gosu::KbEscape then close # Quit
			end
		end
		
		def button_up(id) # Call the function after the user release a button
			case id
				when Gosu::KbDown then next_selection # Choose previous option
				when Gosu::KbUp then previous_selection # Choose next option
				when Gosu::KbReturn then selected # Select the option
			end
		end
	end
	
	def recordmenu()
		@bgm2.play(looping=true) # Play the music
		
		def readname # Read name.txt
			@nfile = File.new("txtfile/name.txt", "r") # Read txt file
			@read_name = @nfile.read # Read whole file
			@nfile.close # Close the file
		end
        
        def readrecord # Read kill.txt
			@rfile = File.new("txtfile/kill.txt", "r") # Read txt file
			@read_record = @rfile.read # Read whole file
			@rfile.close # Close the file
		end
        
        def readfiles # Read two files
            readname() 
            readrecord()
        end
		
		def deleterecord # Delete the content of the file.
			@nfile = File.truncate("txtfile/name.txt", 0)
            @rfile = File.truncate("txtfile/kill.txt", 0)
		end
		
		def draw
            readfiles
			@recordmenu_image.draw(0, 0, ZOrder::BACKGROUND) # Render out the images
			@info_font25.draw_text(@read_name,95,125,1,1,ZOrder::MIDDLE,@colour.black,mode = :default) # texts from txt file
            @info_font25.draw_text(@read_record,500,125,1,1,ZOrder::MIDDLE,@colour.black,mode = :default) # texts from txt file
		end
		
		def button_down(id) # Call the function after the user presses down a button
			case id
				when Gosu::KbEscape then mainmenu() # Back to main menu
				when Gosu::KbD then deleterecord() && readfiles # Delete the records
			end
    	end
		
		def button_up(id) # Call the function after the user release a button
			case id
				when Gosu::KbReturn then mainmenu() # Back to main menu
			end
    	end
	end
                
    def tutorialmenu()
        def draw
			@tutorialmenu_image.draw(0, 0, ZOrder::BACKGROUND) # Background image
		end
        
        def button_down(id) # Call the function after the user presses down a button
			case id
				when Gosu::KbEscape then mainmenu() # Back to main menu
			end
    	end
        
        def button_up(id) # Call the function after the user release the button
			case id
				when Gosu::KbReturn then startmenu() # sgo to startmenu
			end
		end
    end
		
	def startmenu()
        @name = "ANONYMOUS" # Default name
        
		def storename
			@nfile = File.new("txtfile/name.txt", "a") # Write text file
			@nfile.puts(@name) # Store player name
			@nfile.close # Close file
		end
        
        def storerecord
            @rfile = File.new("txtfile/kill.txt", "a") # Write text file
			@rfile.puts(@kill.to_s) # Store player's number of kills
			@rfile.close # Close file
		end
		
		def temparary
			@tfile = File.new("txtfile/temparary.txt", "w") # Write text file
			@tfile.puts(@name) # Store player name temporary
			@tfile.close # Close file
		end
            
		def draw
			@startmenu_image.draw(0, 0, ZOrder::BACKGROUND) # Background image
            @info_font40.draw_text(@name,75,220,1,1,ZOrder::MIDDLE,@colour.black,mode = :default) # texts from txt file
		end
		
		def button_down(id) # Call the function after the user presses down a button
			case id
				when Gosu::KbEscape then mainmenu() # Back to main menu
				when Gosu::KbA then @name << "A"
				when Gosu::KbB then @name << "B"
				when Gosu::KbC then @name << "C"
				when Gosu::KbD then @name << "D"
				when Gosu::KbE then @name << "E"
				when Gosu::KbF then @name << "F" 
				when Gosu::KbG then @name << "G" 
				when Gosu::KbH then @name << "H" 
				when Gosu::KbI then @name << "I" 
				when Gosu::KbJ then @name << "J" 
				when Gosu::KbK then @name << "K" 
				when Gosu::KbL then @name << "L" 
				when Gosu::KbM then @name << "M" 
				when Gosu::KbN then @name << "N" 
				when Gosu::KbO then @name << "O" 
				when Gosu::KbP then @name << "P" 
				when Gosu::KbQ then @name << "Q" 
				when Gosu::KbR then @name << "R" 
				when Gosu::KbS then @name << "S" 
				when Gosu::KbT then @name << "T" 
				when Gosu::KbU then @name << "U" 
				when Gosu::KbV then @name << "V" 
				when Gosu::KbW then @name << "W" 
				when Gosu::KbX then @name << "X" 
				when Gosu::KbY then @name << "Y" 
				when Gosu::KbZ then @name << "Z" 
				when Gosu::Kb1 then @name << "1" 
				when Gosu::Kb2 then @name << "2" 
				when Gosu::Kb3 then @name << "3" 
				when Gosu::Kb4 then @name << "4" 
				when Gosu::Kb5 then @name << "5" 
				when Gosu::Kb6 then @name << "6" 
				when Gosu::Kb7 then @name << "7" 
				when Gosu::Kb8 then @name << "8"
				when Gosu::Kb9 then @name << "9"
				when Gosu::Kb0 then @name << "0"
                when Gosu::KbBackspace then @name.chop!
			end
    	end
		
		def button_up(id) # Call the function after the user release the button
			case id
				when Gosu::KbReturn then playmenu() && temparary() # start the game and store user input
			end
		end
	end
			
	def playmenu()
        @bgm2.play(looping=true) # Play music
        @sprites.start # Sprites start moving
		@sprites.reposition # Reposition all the sprite everytimes
        @playerhealth = 100 # Player's health
        @kill = 0 # Number of kills
		
		def checkplayerhealth
			if @sprites.hurt
                @effect1.play_pan(pan = 0, volume = 1, speed = 1, looping = false)
				@playerhealth = @sprites.reducehealth(@playerhealth)
				if @playerhealth == 50
					@spawn = true
				end
			end
			if @sprites.hit
                @effect2.play_pan(pan = 0, volume = 1, speed = 1, looping = false)
				@kill = @sprites.increasekill(@kill)
			end
            if @sprites.collect
                @effect3.play_pan(pan = 0, volume = 1, speed = 1, looping = false)
				@playerhealth = @sprites.increasehealth(@playerhealth)
			end
		end
        
        def theend?
            case @playerhealth 
                when 0 then gameover() && @sprites.stop #sprite stop moving 
            end
        end
        
		def update
			if Gosu.button_down? Gosu::KbLeft
				@sprites.movebackward # player turn to left
			end
			if Gosu.button_down? Gosu::KbRight
				@sprites.moveforward # player turn to right
			end
			if Gosu.button_down? Gosu::KbUp
				@sprites.moveup # player move backward
			end
			if Gosu.button_down? Gosu::KbDown
				@sprites.movedown # player move backward
			end
			if Gosu.button_down? Gosu::KbSpace
				@sprites.shootbullet # Shoot bullet
			else
				@sprites.hidebullet # Hide the bullet
			end
            if @spawn # Check whether the player need a supplydrop
				@sprites.spawnsupplydrop
				@spawn = false
			end
            
            checkplayerhealth # Check player's health
			@sprites.zombiemove # Zombie can move
			@sprites.collision? # Check collision between each sprite
		end
		
		def draw
			@playmenu_image.draw(0, 0, ZOrder::BACKGROUND) # Background image playmenu
			@tree.draw(0,0, ZOrder::TOP) # Trees
			@info_font40.draw_text(@kill,500,483,1,1,ZOrder::MIDDLE,@colour.white,mode = :default) # Player score
            @info_font40.draw_text(@playerhealth,80,483,1,1,ZOrder::MIDDLE,@colour.white,mode = :default) # Player health
			@sprites.draw # Draw all the sprite
            theend? # Check whether the game end
		end
		
		def button_down(id) # Call the function after the user presses down a button
			case id
				when Gosu::KbEscape then gameover() && @sprites.stop # Back to main menu
			end
    	end
			
		def button_up(id) # Call the function after the user release the button
			case id
				when Gosu::KbReturn then gameover() && @sprites.stop # Open Gameover screen
			end
		end
	end
	
	def gameover()
        storename() # Store the player's into name.txt
        storerecord() # Store the number of kills into kill.txt
        @bgm3.play(looping = false) # Play the music
        
		def draw
			@gameover_image.draw(0, 0, ZOrder::BACKGROUND) # Render out the images
			@info_font25.draw_text("Player: " + @name,250,220,1,1,ZOrder::MIDDLE,@colour.black,mode = :default) # Player name
			@info_font25.draw_text("Kill: " + @kill.to_s,250,250,1,1,ZOrder::MIDDLE,@colour.black,mode = :default) # Player score
		end
		
		def button_down(id) # Call the function after the user presses down a button
			case id
				when Gosu::KbEscape then mainmenu() # Back to main menu
			end
    	end
			
		def button_up(id) # Call the function after the user release the button
			case id
				when Gosu::KbReturn then mainmenu() # Back to main menu
			end
    	end
	end
end
		
class Sprites
	
	attr_reader :hurt, :collect, :hit
    
	def initialize
        # Link the class
		@colour = Colour.new
		
        # Link all the images for sprites
		@zombie = Gosu::Image.new("assets/sprites/zombie_4.png")
		@player = Gosu::Image.new("assets/sprites/player.png")
		@bullet = Gosu::Image.new("assets/sprites/bullet.png")
		@supplydrop = Gosu::Image.new("assets/sprites/supplydrop.png")
        
		# Create different text size
		@info_font40 = Gosu::Font.new(40)
        @info_font15 = Gosu::Font.new(15)
        
		# Variables
        @speed = 16
		@hurt = @collect = @hit = false
  	end
    
    def readfile # Read temparary.txt file
		@tfile = File.new("txtfile/temparary.txt","r")
		@readname = @tfile.read
		@tfile.close
	end
	
	def reposition # Positions for each sprites
		@bx, @by, @px, @py = 340, 500, 320, 240
		@sx, @sy = 100, 700
		@zx1, @zy1, @zx2, @zy2, @zx3, @zy3 = 660, rand(25..410), 660, rand(25..410), 660, rand(25..410)
	end
	
	def spawnsupplydrop
		@sx, @sy = rand(75..660), rand(25..400)
	end
	
	def hidebullet # Hide the bullet to prevent killing zombie when zombie touch the player
		@bx,@by = 699,600
	end
  
  	def movebackward  # Player move backward
		if @px > 5
			@px -= 3
		else
			@px -= 0
		end
  	end
  
  	def moveforward # Player move forward
		if @px < 645
			@px += 3
		else
			@px += 0
		end
  	end
  
  	def moveup # Player move up
		if @py > 5
			@py -= 3
		else
			@py -= 0
		end
  	end
	
	def movedown # Player move down
		if @py < 410
			@py += 3
		else
			@py += 0
		end
	end
	
	def zombiemove # Zombies move
 		if @zx1 > 0
			@zx1 -= @zombie1speed
		else
			killzombie1
			@hurt = true
		end
		if @zx2 > 0
			@zx2 -= @zombie2speed
		else
			killzombie2
			@hurt = true
		end
		if @zx3 > 0
			@zx3 -= @zombie3speed
		else
			killzombie3
			@hurt = true
		end
  	end
	
	def shootbullet # Player shoots bullet
		if @bx < 700
			@bx += @speed
		else
			killbullet
		end
	end
	
	def killbullet # Reposition the bullet
		@bx,@by = @px+8,@py
	end
	
	def killzombie1 # Reposition the zombie 1
		@zombie1speed = rand(1..3)
		@zx1, @zy1 = 660, rand(25..410)
	end
	
	def killzombie2 # Reposition the zombie 2
		@zombie2speed = rand(1..3)
		@zx2, @zy2 = 660, rand(25..410)
	end
	
	def killzombie3 # Reposition the zombie 3
		@zombie3speed = rand(1..3)
		@zx3, @zy3 = 660, rand(25..410)
	end
    
    def killsupplydrop # Reposition the supplydrop
		@sx, @sy = 100, 700
		@collect = true
	end
	
	def killplayer # Reposition the player
		@px, @py = rand(25..300), rand(25..410)
		@hurt = true
	end
	
	def collision? # Check collision
		if Gosu::distance(@px,@py,@sx,@sy) < 30
			killsupplydrop
		end
		if Gosu::distance(@px,@py,@zx1,@zy1) < 30 || Gosu::distance(@px,@py,@zx2,@zy2) < 30 || Gosu::distance(@px,@py,@zx3,@zy3) < 30
			killplayer
		end
		if Gosu::distance(@bx,@by,@zx1,@zy1) < 25
			killzombie1
			killbullet
			@hit = true
		end
		if Gosu::distance(@bx,@by,@zx2,@zy2) < 25
			killzombie2
			killbullet
			@hit = true
		end
		if Gosu::distance(@bx,@by,@zx3,@zy3) < 25
			killzombie3
			killbullet
			@hit = true
		end
	end
	
	def reducehealth(playerhealth) # Reduce player's health
        if playerhealth > 0
            playerhealth -= 10
        end
		@hurt = false
		return playerhealth
	end
	
	def increasehealth(playerhealth) # Increase player's health
		playerhealth += 40
		@collect = false
		return playerhealth
	end
	
	def increasekill(kill) # Increase the number of kills
		kill += 1
		@hit = false
		return kill
	end
    
    def start # Sprits start moving
        @zombie1speed = @zombie2speed = @zombie3speed = rand(1..2)
    end
    
    def stop # Sprites stop moving
        @zombie1speed = @zombie2speed = @zombie3speed = 0
    end
	
	def draw
		readfile() # Read name.txt file
		@supplydrop.draw(@sx, @sy, ZOrder::MIDDLE) # Supply drop
		@zombie.draw(@zx1, @zy1, ZOrder::MIDDLE) # Zombie1
		@zombie.draw(@zx2, @zy2, ZOrder::MIDDLE) # Zombie2
		@zombie.draw(@zx3, @zy3, ZOrder::MIDDLE) # Zombie3
		@bullet.draw(@bx, @by, ZOrder::MIDDLE) # Bullet
		@player.draw(@px, @py, ZOrder::MIDDLE) # Player
		@info_font15.draw_text(@readname,@px-20,@py-20,1,1,ZOrder::MIDDLE,@colour.black,mode = :default) # Player name
	end
end
        
window = Game.new
window.show # Show the window